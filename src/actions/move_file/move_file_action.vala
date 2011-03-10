using Ginko.IO;

namespace Ginko.Actions {

// this shouldn't extend AbstractFileAction.
// this is file operation indeed but it doesn't need scanning as AbstractFileAction provides.
class MoveFileAction : AbstractAction {
    
    private MoveFileConfig m_config;
    
    private Renamer m_renamer = new Renamer();
    private bool m_first_file = true;
    
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
        
        m_renamer.source_base_directory = p_context.source_dir;
        m_renamer.toplevel_source_file_count = p_context.source_selected_files.length;
        m_renamer.rename_string = m_config.destination;
        
        return return_code == MoveFileConfigureDialog.Response.OK;
    }
    
    protected override bool prepare_t(ActionContext p_context) {
        return true;
    }
    
    protected override void execute_t() {
        bool error = false;
        
        foreach (File source_file in context.source_selected_files) {
            File destination_file = m_renamer.rename(source_file);
            if (m_first_file) {
                try {
                    Files.with(destination_file).make_parents_if_not_exists();
                } catch (IOError e) {
                    show_error(e.message);
                    error = true;
                    break;
                }
                
                m_first_file = false;
            }
            
            try {
                source_file.move(
                    destination_file,
                    FileCopyFlags.NOFOLLOW_SYMLINKS,
                    null,
                    null
                    );
            } catch (IOError e) {
                if (e is IOError.WOULD_RECURSE) {
                    // use copy fallback
                }
                debug("%d", e.code);
                show_error(e.message);
                error = true;
                break;
            }
        }
        
        refresh_active_directory_t();
        refresh_unactive_directory_t();
    }
}
    
} // namespace
