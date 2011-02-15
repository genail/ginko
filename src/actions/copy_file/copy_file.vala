using Gtk;
using Ginko.IO;

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
        
        // ask for copy configuration
        var config_dialog = new CopyFileConfigureDialog(context);
        var return_code = config_dialog.run();
        config_dialog.close();
        
        if (return_code == ResponseType.OK) {
            var config = config_dialog.get_config();
            
            Files.list_recurse(
                context.source_selected_files.data, config.follow_symlinks, (file) => {
                    var copy_file_op = new CopyFileOperation(config);
                    copy_file_op.source = file;
                    copy_file_op.destination = Files.rebase(
                        file, context.source_dir, context.target_dir);
                    
                    if (Config.debug) {
                        debug("dry copy: %s => %s",
                            copy_file_op.source.get_path(), copy_file_op.destination.get_path());
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
                                    //Messages.show_error(context, "Source file \"");
                                    break;
                                case CopyFileOperation.FAIL_REASON_OVERWRITE:
                                    break; // TODO
                            }
                            
                        }
                    }
                });
            
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
