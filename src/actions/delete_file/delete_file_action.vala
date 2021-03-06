using Ginko.IO;
using Ginko.Util;
using Ginko.Operations;

namespace Ginko.Actions {

public class DeleteFileAction : AbstractFileAction {
    
    private int m_file_count_processed;
    private int m_file_count_total;
    
    protected DeleteFileAction(ActionDescriptor p_action_descriptor) {
        base(p_action_descriptor);
    }
    
    protected override bool verify(ActionContext p_context) {
        if (p_context.source_selected_files.length == 0) {
            show_error("You must select at least one file.");
            return false;
        }
        
        return true;
    }
    
    protected override bool configure(ActionContext p_context) {
        var config_dialog = new DeleteFileConfigureDialog(p_context);
        int return_code = config_dialog.run();
        config_dialog.close();
        
        return return_code == DeleteFileConfigureDialog.Response.YES;
    }
    
    protected override bool prepare_t(ActionContext p_context) {
        foreach (var infile in p_context.source_selected_files) {
            m_file_count_total = Files.calculate_file_count_recurse(infile, false);
        }
        
        return true;
    }
    
    protected override bool on_file_found_t(ActionContext p_context,
        File p_file, FileInfo p_fileinfo,
        AbstractAction.ProgressCallback p_callback) {
    
        var file_type = p_fileinfo.get_file_type();
        if (file_type != FileType.DIRECTORY) {
            delete_file_t(p_file, p_callback);
        } else {
            set_status(Status.SKIP);
        }
        
        return true;
    }
    
    protected override void on_directory_leaved_t(ActionContext p_context,
        File p_dir,
        AbstractAction.ProgressCallback p_callback) {
        delete_file_t(p_dir, p_callback);
    }
    
    private void delete_file_t(File p_file, AbstractAction.ProgressCallback p_callback) {
        float percent = m_file_count_processed / (float)m_file_count_total;
        p_callback(percent, "Deleting %s".printf(p_file.get_path()));
        
        try {
            var op = new DeleteFileOperation();
            op.file = p_file;
            op.execute();
            
            if (Config.debug) {
                Posix.sleep(1);
            }
            
            m_file_count_processed++;
            
            if (!cancel_requested) {
                set_status(Status.SUCCESS);
            } else {
                set_status(Status.CANCEL);
            }
        } catch (Error e) {
            show_error(e.message + "\n" + p_file.get_path());
            set_status(Status.ERROR);
        }
    }
}

} // namespace
