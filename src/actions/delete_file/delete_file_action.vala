using Ginko.Dialogs;
using Ginko.Util;
using Ginko.IO;

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
    
    protected override bool on_file_found_t(File p_file, FileInfo p_fileinfo,
        AbstractFileAction.ProgressCallback p_callback) {
    
        var file_type = p_fileinfo.get_file_type();
        if (file_type != FileType.DIRECTORY) {
            debug("about to delete %s", p_file.get_path());
            delete_file_t(p_file, p_callback);
        } else {
            set_status(Status.SKIP);
        }
        
        return true;
    }
    
    protected override void on_directory_leaved_t(File p_dir,
        AbstractFileAction.ProgressCallback p_callback) {
        debug("about to delete empty dir %s", p_dir.get_path());
        delete_file_t(p_dir, p_callback);
    }
    
    private void delete_file_t(File p_file, AbstractFileAction.ProgressCallback p_callback) {
        float percent = m_file_count_processed / (float)m_file_count_total;
        p_callback(percent, "Deleting %s".printf(p_file.get_path()));
        
        //p_file.delete(null);
        m_file_count_processed++;
        set_status(Status.SUCCEED);
    }
}

} // namespace
