using Gtk;

namespace Ginko.Actions {

class CopyFile : Action {
    
    public CopyFile() {
        base(
            "Copy files",
            new string[] { "copy", "file", "files" },
            new Accelerator("F5", null));
    }
    
    public override void execute(ActionContext context) {
        if (!verify(context)) {
            return;
        }
        
        var config_dialog = new CopyFileConfigureDialog(context);
        var return_code = config_dialog.run();
        config_dialog.close();
        
        if (return_code == ResponseType.OK) {
            var config = config_dialog.get_config();
            
            var copy_file_opr = new CopyFileOperation(config);
            
            var source_file = context.source_selected_files.data;
            copy_file_opr.source = source_file;
            copy_file_opr.destination = context.target_dir.get_child(source_file.get_basename());
            
            debug("checking copy operation from %s to %s", copy_file_opr.source.get_path(), copy_file_opr.destination.get_path());
            
            if (copy_file_opr.check_if_possible()) {
                debug("copy possible");
            } else {
                debug("copy impossible of reason: %d", copy_file_opr.get_fail_reason());
                
                var fail_reason = copy_file_opr.get_fail_reason();
                switch (fail_reason) {
                    case CopyFileOperation.FAIL_REASON_NOT_EXISTS:
                        // TODO: source is gone?!
                        break;
                    case CopyFileOperation.FAIL_REASON_OVERWRITE:
                        break; // TODO
                }
                
            }
            
            /*var progress_dialog = new ActionProgressDialog();
            progress_dialog.set_progress(0.5, "Test");
            progress_dialog.log_details("first detail");
            progress_dialog.log_details("second detail");
            progress_dialog.run();*/
        }
    }
    
    private bool verify(ActionContext context) {
        if (context.source_selected_files.length() == 0) {
            Messages.show_error(context, "Nothing to copy", "You must select at least one file.");
            return false;
        }
        
        return true;
    }
}

} // namespace
