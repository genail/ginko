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
            var infile = context.source_selected_files.data;
            
            var progress_dialog = new ActionProgressDialog();
            double progress_f = 0.0;
            
            progress_dialog.set_progress(progress_f, "Preparing...");
            
            // calculate used space first
            uint64 bytes_total = Files.calculate_space_recurse(infile, config.follow_symlinks);
            uint64 bytes_copied = 0;
            
            var scanner = new TreeScanner();
            scanner.m_follow_symlinks = config.follow_symlinks;
            
            if (Config.debug) {
                scanner.add_attribute(FILE_ATTRIBUTE_STANDARD_SIZE);
            }
            
            scanner.scan(infile, (file, fileinfo) => {
                    progress_dialog.set_progress(progress_f, "Copying...");
                    
                    var copy_file_op = new CopyFileOperation(config);
                    copy_file_op.source = file;
                    copy_file_op.destination = Files.rebase(
                        file, context.source_dir, context.target_dir);
                    
                    if (Config.debug) {
                        debug("dry copy: %s => %s",
                            copy_file_op.source.get_path(), copy_file_op.destination.get_path());
                        Posix.sleep(1);
                        bytes_copied += fileinfo.get_size();
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
                                    Messages.show_error(context,
                                        "Source not found!", "Source file doesn't exists!");
                                    return;
                                case CopyFileOperation.FAIL_REASON_OVERWRITE:
                                    //var dialog = new Ginko.Dialogs.OverwriteDialog(action_context);
                                    //dialog.run();
                                    break;
                            }
                            
                        }
                    }
                    
                    progress_f = bytes_copied / (double) bytes_total;
            });
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
