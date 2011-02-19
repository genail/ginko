using Gtk;
using Ginko.IO;
using Ginko.Util;
using Ginko.Dialogs;
using Ginko.Operations;


namespace Ginko.Actions {

class CopyFileAction : GLib.Object {
    
    private ActionContext m_context;
    private CopyFileConfig m_config;
    private int m_config_return_code;
    private ProgressDialog m_progress_dialog;
    
    
    public void execute(ActionContext p_context) {
        if (!verify(p_context)) {
            return;
        }
        
        m_context = p_context;
        
        m_progress_dialog = new ProgressDialog();
        m_progress_dialog.set_title("Copy operation");
        
        prompt_configuration();
        if (configuration_done()) {
            execute_async();
        }
    }
    
    private bool verify(ActionContext context) {
        if (context.source_selected_files.length() == 0) {
            Messages.show_error(context, "Nothing to copy", "You must select at least one file.");
            return false;
        }
        
        return true;
    }
    
    private void prompt_configuration() {
        var config_dialog = new CopyFileConfigureDialog(m_context);
        m_config_return_code = config_dialog.run();
        config_dialog.close();
        
        m_config = config_dialog.get_config();
    }
    
    private bool configuration_done() {
        return m_config_return_code == ResponseType.OK;
    }
    
    private void execute_async() {
        var async_task = new AsyncTask();
        async_task.run(execute_async_t, this);
    }
    
    // executed in new thread
    private void execute_async_t(AsyncTask p_async_task) {
        show_progress_preparing_t();
        
        var infile = m_context.source_selected_files.data;
        double progress_f = 0.0;
        
        // calculate used space first
        uint64 bytes_total = Files.calculate_space_recurse(infile, m_config.follow_symlinks);
        uint64 bytes_copied = 0;
        
        var scanner = new TreeScanner();
        scanner.m_follow_symlinks = m_config.follow_symlinks;
        
        if (Config.debug) {
            scanner.add_attribute(FILE_ATTRIBUTE_STANDARD_SIZE);
        }
        
        scanner.scan(infile, (file, fileinfo) => {
                var filename = fileinfo.get_name();
                show_progress_copying_t(filename, progress_f);
                
                
                var copy_file_op = new CopyFileOperation();
                copy_file_op.source = file;
                copy_file_op.destination = Files.rebase(
                    file, m_context.source_dir, m_context.target_dir);
                
                if (Config.debug) {
                    
                    debug("dry copy: %s => %s",
                        copy_file_op.source.get_path(), copy_file_op.destination.get_path());
                    Posix.sleep(1);
                    bytes_copied += fileinfo.get_size();
                } else {
                    
                    debug("checking copy operation from %s to %s",
                        copy_file_op.source.get_path(), copy_file_op.destination.get_path());
                    
                    if (copy_file_op.check_if_possible()) {
                        debug("copy possible");
                        
                        
                        
                    } else {
                        debug("copy impossible of reason: %d", copy_file_op.get_fail_reason());
                        
                        var fail_reason = copy_file_op.get_fail_reason();
                        switch (fail_reason) {
                            case CopyFileOperation.FAIL_REASON_NOT_EXISTS:
                                Messages.show_error(m_context,
                                    "Source not found!", "Source file doesn't exists!");
                                return;
                            case CopyFileOperation.FAIL_REASON_OVERWRITE:
                                var dialog = new Ginko.Dialogs.OverwriteDialog(m_context,
                                    copy_file_op.source, copy_file_op.destination);
                                dialog.run();
                                break;
                        }
                        
                    }
                }
                
                progress_f = bytes_copied / (double) bytes_total;
        });
        
        show_progress_finished_t();
    }
    
    private void show_progress_preparing_t() {
        Idle.add(() => {
                m_progress_dialog.set_status_text_1("Preparing...");
                m_progress_dialog.show_all();
                return false;
        });
    }
    
    private void show_progress_copying_t(string p_filename, double p_value) {
        Idle.add(() => {
                m_progress_dialog.set_status_text_1("Copying %s".printf(p_filename));
                m_progress_dialog.set_progress(p_value);
                return false;
        });
    }
    
    private void show_progress_finished_t() {
        Idle.add(() => {
                m_progress_dialog.set_status_text_1("Operation finished!");
                m_progress_dialog.set_progress(1);
                m_progress_dialog.set_done();
                return false;
        });
    }
}

} // namespace
