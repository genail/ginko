using Ginko.Dialogs;
using Ginko.Util;
using Ginko.IO;

namespace Ginko.Actions {

public class DeleteFileAction : Object {
    
    private enum FileAction {
        NONE,
        SUCCEED,
        SKIP,
        CANCEL,
        ERROR
    }
    
    private ActionContext m_context;
    private ProgressDialog m_progress_dialog;
    private bool m_progress_dialog_visible;
    
    private int m_config_return_code;
    private FileAction m_file_action = FileAction.NONE;
    
    private int m_file_count_processed;
    private int m_file_count_total;
    
    public void execute(ActionContext p_context) {
        if (!verify(p_context)) {
            return;
        }
        
        m_context = p_context;
        
        m_progress_dialog = new ProgressDialog(m_context);
        m_progress_dialog.set_title("Delete files");
        
        //m_progress_dialog.cancel_button_pressed.connect(() => m_copy_op.cancel());
        
        prompt_configuration();
        if (configuration_done()) {
            execute_async();
        }
    }
    
    private bool verify(ActionContext context) {
        if (context.source_selected_files.length == 0) {
            Messages.show_error(context, "Nothing to delete", "You must select at least one file.");
            return false;
        }
        
        return true;
    }
    
    private void prompt_configuration() {
        var config_dialog = new DeleteFileConfigureDialog(m_context);
        m_config_return_code = config_dialog.run();
        config_dialog.close();
    }
    
    private bool configuration_done() {
        return m_config_return_code == DeleteFileConfigureDialog.Response.YES;
    }
    
    private void execute_async() {
        var async_task = new AsyncTask();
        async_task.run(execute_async_t, this);
    }
    
    private void execute_async_t(AsyncTask p_async_task) {
        show_progress_preparing_t();
        calculate_file_count_t();
        delete_recurse_t();
        
    }
    
    private void show_progress_preparing_t() {
        GuiExecutor.run(() => {
                m_progress_dialog.set_status_text_1("Preparing...");
                
                if (!m_progress_dialog_visible) {
                    m_progress_dialog.show();
                    m_progress_dialog_visible = true;
                }
        });
    }
    
    private void calculate_file_count_t() {
        foreach (var infile in m_context.source_selected_files) {
            m_file_count_total = Files.calculate_file_count_recurse(infile, false);
        }
    }
    
    private void delete_recurse_t() {
        var scanner = new TreeScanner();
        
        foreach (var infile in m_context.source_selected_files) {
            scanner.scan(infile, delete_t, delete_empty_directory_t);
        }
        
        show_progress_finished_t();
    }
    
    private bool delete_t(File p_file, FileInfo p_fileinfo) {
        var file_type = p_fileinfo.get_file_type();
        if (file_type != FileType.DIRECTORY) {
            debug("about to delete %s", p_file.get_path());
            delete_file_t(p_file);
            m_file_action = FileAction.SUCCEED;
        } else {
            m_file_action = FileAction.SKIP;
        }
        
        assert (m_file_action != FileAction.NONE);
        
        return m_file_action == FileAction.SUCCEED || m_file_action == FileAction.SKIP;
    }
    
    // called when leaving from directory in tree scanner
    private void delete_empty_directory_t(File p_dir) {
        debug("about to delete empty dir %s", p_dir.get_path());
        delete_file_t(p_dir);
        m_file_action = FileAction.SUCCEED;
    }
    
    private bool delete_file_t(File p_file) {
        show_progress_deleting_t(p_file.get_path());
        
        //p_file.delete(null);
        m_file_count_processed++;
        
        return true;
    }
    
    private void show_progress_deleting_t(string p_filename) {
        double value = m_file_count_processed / (double) m_file_count_total;
        
        GuiExecutor.run(() => {
                m_progress_dialog.set_status_text_1("Deleting %s".printf(p_filename));
                m_progress_dialog.set_progress(value);
        });
    }
    
    private void show_progress_finished_t() {
        GuiExecutor.run(() => {
                m_progress_dialog.set_status_text_1("Operation finished!");
                m_progress_dialog.set_progress(1);
                m_progress_dialog.set_done();
        });
    }
}

} // namespace
