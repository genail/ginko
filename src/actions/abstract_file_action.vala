using Ginko.IO;
using Ginko.Util;
using Ginko.Dialogs;

namespace Ginko.Actions {

public abstract class AbstractFileAction : Object {
    
    protected delegate void ProgressCallback(float p_percent, string p_stage);
    
    protected enum Status {
        NONE,
        SUCCEED,
        TRY_AGAIN,
        SKIP,
        CANCEL,
        ERROR
    }
    
    private ActionDescriptor m_action_descriptor;
    private ActionContext m_context;
    private Status m_status;
    private ProgressDialog m_progress_dialog;
    private TreeScanner m_tree_scanner;
    
    
    protected AbstractFileAction(ActionDescriptor p_action_descriptor) {
        m_action_descriptor = p_action_descriptor;
        m_tree_scanner = new TreeScanner();
    }
    
    
    protected abstract bool verify(ActionContext p_context);
    protected abstract bool configure(ActionContext p_context);
    
    protected abstract bool prepare_t(ActionContext p_context);
    
    protected abstract bool on_file_found_t(File p_file, FileInfo p_fileinfo,
        ProgressCallback p_callback);
    protected virtual void on_directory_leaved_t(File p_dir, ProgressCallback p_callback) {
        // empty
    }
    
    
    protected TreeScanner get_tree_scanner() {
        return m_tree_scanner;
    }
    
    protected Status get_status() {
        return m_status;
    }
    
    protected void set_status(Status p_status) {
        m_status = p_status;
    }
    
    protected void show_error(string p_message) {
        Messages.show_error(m_context, m_action_descriptor.name, p_message);
    }
    
    protected void show_error_t(string p_message) {
        Messages.show_error_t(m_context, m_action_descriptor.name, p_message);
    }
    
    public void execute(ActionContext p_context) {
        m_context = p_context;
        
        if (verify(m_context)) {
            m_progress_dialog = new ProgressDialog(m_context);
            m_progress_dialog.set_title(m_action_descriptor.name);
            
            if (configure(m_context)) {
                execute_async();
            }
        }
    }
    
    private void execute_async() {
        var async_task = new AsyncTask();
        async_task.run(execute_async_t, this);
    }
    
    private void execute_async_t(AsyncTask p_async_task) {
        show_progress_preparing_t();
        if (prepare_t(m_context)) {
            
            foreach (var infile in m_context.source_selected_files) {
                m_tree_scanner.scan(infile, on_file_found_inner_t, on_directory_leaved_inner_t);
                
                // break if last scanning was terminated (cancel or error)
                if (is_terminated()) {
                    break;
                }
            }
            
            switch (m_status) {
                case Status.CANCEL:
                    show_progress_canceled_t();
                    break;
                case Status.ERROR:
                    show_progress_failed_t();
                    break;
                default:
                    show_progress_suceed_t();
                    destroy_progress_with_delay_t();
                    break;
            }
        }
    }
    
    private bool is_terminated() {
        return m_status == Status.CANCEL || m_status == Status.ERROR;
    }
    
    private void show_progress_preparing_t() {
        GuiExecutor.run(() => {
                m_progress_dialog.set_status_text_1("Preparing...");
                m_progress_dialog.show();
        });
    }
    
    private void show_progress_suceed_t() {
        GuiExecutor.run(() => {
                m_progress_dialog.set_status_text_1("Finished!");
                m_progress_dialog.set_progress(1);
                m_progress_dialog.show();
        });
    }
    
    private void show_progress_canceled_t() {
        GuiExecutor.run(() => {
                m_progress_dialog.set_status_text_1("Operation canceled by user.");
                m_progress_dialog.show();
        });
    }
    
    private void show_progress_failed_t() {
        GuiExecutor.run(() => {
                m_progress_dialog.set_status_text_1("Operation failed!");
                m_progress_dialog.show();
        });
    }
    
    private void destroy_progress_with_delay_t() {
        Posix.usleep(1000000);
        GuiExecutor.run(() => {
                m_progress_dialog.destroy();
        });
    }
    
    private bool on_file_found_inner_t(File p_file, FileInfo p_fileinfo) {
        m_status = Status.NONE;
        bool result = on_file_found_t(p_file, p_fileinfo, on_progress_callback);
        assert(m_status != Status.NONE);
        
        if (is_terminated()) {
            return false;
        }
        
        return result;
    }
    
    private void on_directory_leaved_inner_t(File p_dir) {
        on_directory_leaved_t(p_dir, on_progress_callback);
    }
    
    private void on_progress_callback(float p_percent, string p_stage) {
        GuiExecutor.run(() => {
                m_progress_dialog.set_status_text_1(p_stage);
                m_progress_dialog.set_progress(p_percent);
        });
    }
    
}
    
} // namespace
