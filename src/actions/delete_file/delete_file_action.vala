using Ginko.Dialogs;

namespace Ginko.Actions {

public class DeleteFileAction {
    
    private ActionContext m_context;
    private ProgressDialog m_progress_dialog;
    
    private int m_config_return_code;
    
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
            //execute_async();
            debug("time to delete!");
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
}

} // namespace
