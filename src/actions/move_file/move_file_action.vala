namespace Ginko.Actions {

// this shouldn't extend AbstractFileAction.
// this is file operation indeed but it doesn't need scanning as AbstractFileAction provides.
class MoveFileAction : AbstractAction {
    
    private MoveFileConfig m_config;
    
    public MoveFileAction(ActionDescriptor p_action_descriptor) {
        base(p_action_descriptor);
        show_progress_dialog = true;
    }
    
    protected override bool verify(ActionContext p_context) {
        if (p_context.source_selected_files.length == 0) {
            show_error("You must select at least one file.");
            return false;
        }
        
        return true;
    }
    
    protected override bool configure(ActionContext p_context) {
        var config_dialog = new MoveFileConfigureDialog(p_context);
        
        int return_code = config_dialog.run();
        m_config = config_dialog.get_config();
        
        config_dialog.close();
        
        return return_code == MoveFileConfigureDialog.Response.OK;
    }
    
    protected override bool prepare_t(ActionContext p_context) {
        return true;
    }
    
    protected override void execute_t() {
        
    }
}
    
} // namespace
