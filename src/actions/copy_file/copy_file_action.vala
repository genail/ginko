using Gtk;
using Ginko.IO;
using Ginko.Util;
using Ginko.Dialogs;


namespace Ginko.Actions {

class CopyFileAction : GLib.Object {
    public void execute(ActionContext context) {
        if (!verify(context)) {
            return;
        }
        
        // ask for copy configuration
        var config_dialog = new CopyFileConfigureDialog(context);
        var return_code = config_dialog.run();
        config_dialog.close();
        
        
        if (return_code == ResponseType.OK) {
            var progress_dialog = new ProgressDialog();
            progress_dialog.set_title("Copy operation");
            progress_dialog.set_status_text_1("Preparing...");
            progress_dialog.show();
            
            // running copy operation as async task
            var async_task = new AsyncTask();
            
            async_task.push(context);
            async_task.push(config_dialog);
            async_task.push(progress_dialog);
            
            async_task.run(execute_in_new_thread, this);
        }
    }
    
    private void execute_in_new_thread(AsyncTask async_task) {
        var context = async_task.get() as ActionContext;
        var config_dialog = async_task.get() as CopyFileConfigureDialog;
        var progress_dialog = async_task.get() as ProgressDialog;
        
        var config = config_dialog.get_config();
        var infile = context.source_selected_files.data;
        
        
        double progress_f = 0.0;
        
        
        // calculate used space first
        uint64 bytes_total = Files.calculate_space_recurse(infile, config.follow_symlinks);
        uint64 bytes_copied = 0;
        
        var scanner = new TreeScanner();
        scanner.m_follow_symlinks = config.follow_symlinks;
        
        if (Config.debug) {
            scanner.add_attribute(FILE_ATTRIBUTE_STANDARD_SIZE);
        }
        
        scanner.scan(infile, (file, fileinfo) => {
                Idle.add(() => {
                    progress_dialog.set_status_text_1("Copying %s".printf(fileinfo.get_name()));
                    progress_dialog.set_progress(progress_f);
                    return false;
                });
                
                
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
                                var dialog = new Ginko.Dialogs.OverwriteDialog(context, copy_file_op.source, copy_file_op.destination);
                                dialog.run();
                                break;
                        }
                        
                    }
                }
                
                progress_f = bytes_copied / (double) bytes_total;
        });
        
        Idle.add(() => {
            progress_dialog.set_status_text_1("Operation finished!");
            progress_dialog.set_progress(progress_f);
            progress_dialog.set_done();
            return false;
        });
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
