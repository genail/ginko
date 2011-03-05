using Ginko.IO;
using Ginko.Util;
using Ginko.Dialogs;

namespace Ginko.Actions {


public abstract class AbstractFileAction : AbstractAction {
    
    protected enum Status {
        NONE,
        SUCCESS,
        TRY_AGAIN,
        SKIP,
        CANCEL,
        ERROR
    }
    
    private ActionDescriptor m_action_descriptor;
    private Status m_status;
    private TreeScanner m_tree_scanner;
    
    //private unowned Thread m_async_thread;
    
    
    protected AbstractFileAction(ActionDescriptor p_action_descriptor) {
        base(p_action_descriptor);
        m_tree_scanner = new TreeScanner();
        
        show_progress_dialog = true;
    }
    
    
    protected abstract bool on_file_found_t(ActionContext p_context,
        File p_file, FileInfo p_fileinfo,
        AbstractAction.ProgressCallback p_callback);
    
    protected virtual void on_directory_leaved_t(ActionContext p_context,
        File p_dir, AbstractAction.ProgressCallback p_callback) {
        set_status(Status.SUCCESS);
    }
    
    
    protected TreeScanner get_tree_scanner() {
        return m_tree_scanner;
    }
    
    protected void set_follow_symlinks(bool p_follow_symlinks) {
        m_tree_scanner.follow_symlinks = p_follow_symlinks;
    }
    
    protected Status get_status() {
        return m_status;
    }
    
    protected void set_status(Status p_status) {
        m_status = p_status;
    }
    
    protected override void execute_t() {
        foreach (var infile in context.source_selected_files) {
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
                show_progress_succeed_t();
                break;
        }
        
        
        refresh_active_directory_t();
        refresh_unactive_directory_t();
    }
    
    private bool is_terminated() {
        return m_status == Status.CANCEL || m_status == Status.ERROR;
    }
    
    private bool on_file_found_inner_t(File p_file, FileInfo p_fileinfo) {
        if (Config.debug) {
            debug("file found %s", p_file.get_path());
        }
        
        m_status = Status.NONE;
        bool result = on_file_found_t(context, p_file, p_fileinfo, on_progress_callback_t);
        assert(m_status != Status.NONE);
        
        if (is_terminated()) {
            return false;
        }
        
        return result;
    }
    
    private bool on_directory_leaved_inner_t(File p_dir) {
        if (Config.debug) {
            debug("dir leaved %s", p_dir.get_path());
        }
        
        on_directory_leaved_t(context, p_dir, on_progress_callback_t);
        assert(m_status != Status.NONE);
        
        if (is_terminated()) {
            return false;
        }
        
        return true;
    }
    
    private void on_progress_callback_t(float p_percent, string? p_stage) {
        GuiExecutor.run(() => {
                if (p_stage != null) {
                    progress_dialog.set_status_text_1(p_stage);
                }
                
                progress_dialog.set_progress(p_percent);
        });
    }
    
    private void refresh_active_directory_t() {
        var dircontroller = context.active_controller;
        GuiExecutor.run(() => dircontroller.refresh());
    }
    
    private void refresh_unactive_directory_t() {
        var dircontroller = context.unactive_controller;
        GuiExecutor.run(() => dircontroller.refresh());
    }
    
}
    
} // namespace
