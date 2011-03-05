using Ginko.IO;
using Ginko.Util;
using Ginko.Dialogs;

namespace Ginko.Actions {

public abstract class AbstractAction : Object {
    /** pass null to leave current stage unchanged */
    protected delegate void ProgressCallback(float p_percent, string? p_stage=null);
    
    protected ActionContext context {get; private set;}
    protected ProgressDialog progress_dialog {get; private set;}
    protected ActionDescriptor action_descriptor {get; private set;}
    
    protected bool show_progress_dialog {get; set;}
    protected bool cancel_requested {get; set;}
    
    
    protected AbstractAction(ActionDescriptor p_action_descriptor) {
        action_descriptor = p_action_descriptor;
    }
    
    
    protected abstract bool verify(ActionContext p_context);
    protected abstract bool configure(ActionContext p_context);
    protected abstract bool prepare_t(ActionContext p_context);
    protected abstract void execute_t();
 
    
    public void execute(ActionContext p_context) {
        context = p_context;
        
        if (verify(context)) {
            progress_dialog = new ProgressDialog(context);
            progress_dialog.set_title(action_descriptor.name);
            
            progress_dialog.cancel_button_pressed.connect(() => on_cancel_request_inner());
            
            if (configure(context)) {
                execute_async();
            }
        }
    }
    
    private void execute_async() {
        var async_task = new AsyncTask();
        async_task.run(execute_inner_t, this);
    }
    
    private void execute_inner_t(AsyncTask p_async_task) {
        if (show_progress_dialog) {
            show_progress_preparing_t();
        }
        
        if (prepare_t(context)) {
            execute_t();
            
            if (show_progress_dialog) {
                destroy_progress_t();
            }
        }
    }
    
    private void on_cancel_request_inner() {
        cancel_requested = true;
        on_cancel_request();
    }
    
    protected virtual void on_cancel_request() {
        // empty
    }
    
    protected void show_error(string p_message) {
        if (Thread.self<void*>() == Application.gui_thread) {
            Messages.show_error(context, action_descriptor.name, p_message);
        } else {
            show_error_t(p_message);
        }
    }
    
    protected void show_error_t(string p_message) {
        Messages.show_error_t(context, action_descriptor.name, p_message);
    }
    
    protected void show_progress_preparing_t() {
        GuiExecutor.run(() => {
                progress_dialog.set_status_text_1("Preparing...");
                progress_dialog.show();
        });
    }
    
    protected void show_progress_succeed_t() {
        GuiExecutor.run(() => {
                progress_dialog.set_status_text_1("Finished!");
                progress_dialog.set_progress(1);
                progress_dialog.show();
        });
    }
    
    protected void show_progress_canceled_t() {
        GuiExecutor.run(() => {
                progress_dialog.set_status_text_1("Operation canceled by user.");
                progress_dialog.show();
        });
    }
    
    protected void show_progress_failed_t() {
        GuiExecutor.run(() => {
                progress_dialog.set_status_text_1("Operation failed!");
                progress_dialog.show();
        });
    }
    
    protected void destroy_progress_t() {
        GuiExecutor.run(() => {
                progress_dialog.destroy();
        });
    }
}
    
} // namespace
