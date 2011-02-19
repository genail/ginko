using Gtk;
using Ginko.IO;
using Ginko.Util;
using Ginko.Dialogs;
using Ginko.Operations;


namespace Ginko.Actions {

class CopyFileAction : GLib.Object {
    
    private ActionContext m_context;
    private CopyFileConfig m_config;
    private int m_config_return_code;
    private ProgressDialog m_progress_dialog;
    
    
    public void execute(ActionContext p_context) {
        if (!verify(p_context)) {
            return;
        }
        
        m_context = p_context;
        
        m_progress_dialog = new ProgressDialog();
        m_progress_dialog.set_title("Copy operation");
        
        prompt_configuration();
        if (configuration_done()) {
            execute_async();
        }
    }
    
    private bool verify(ActionContext context) {
        if (context.source_selected_files.length() == 0) {
            Messages.show_error(context, "Nothing to copy", "You must select at least one file.");
            return false;
        }
        
        return true;
    }
    
    private void prompt_configuration() {
        var config_dialog = new CopyFileConfigureDialog(m_context);
        m_config_return_code = config_dialog.run();
        config_dialog.close();
        
        m_config = config_dialog.get_config();
    }
    
    private bool configuration_done() {
        return m_config_return_code == ResponseType.OK;
    }
    
    private void execute_async() {
        var async_task = new AsyncTask();
        async_task.run(execute_async_t, this);
    }
    
    // executed in new thread
    private void execute_async_t(AsyncTask p_async_task) {
        show_progress_preparing_t();
        
        var infile = m_context.source_selected_files.data;
        double progress_f = 0.0;
        
        // calculate used space first
        uint64 bytes_total = Files.calculate_space_recurse(infile, m_config.follow_symlinks);
        uint64 bytes_copied = 0;
        
        var scanner = new TreeScanner();
        scanner.m_follow_symlinks = m_config.follow_symlinks;
        
        if (Config.debug) {
            scanner.add_attribute(FILE_ATTRIBUTE_STANDARD_SIZE);
        }
        
        scanner.scan(infile, (src_file, src_fileinfo) => {
                var src_filename = src_fileinfo.get_name();
                show_progress_copying_t(src_filename, progress_f);
                
                // build copy file configuration
                var op = new CopyFileOperation();
                op.m_source = src_file;
                var dst_file = Files.rebase(
                    src_file, m_context.source_dir, m_context.target_dir);
                op.m_destination = dst_file;
                
                progress_log_details_t(
                        "%s => %s".printf(
                            op.m_source.get_path(),
                            op.m_destination.get_path()
                        ));
                
                if (Config.debug) {
                    Posix.sleep(1);
                    bytes_copied += src_fileinfo.get_size();
                } else {
                    
                    bool skip_file = false;
                    bool succeed = false;
                    bool cancel = false;
                    
                    do {
                        var src_filetype = src_file.query_file_type(
                            m_config.follow_symlinks ?
                                FileQueryInfoFlags.NONE : FileQueryInfoFlags.NOFOLLOW_SYMLINKS);
                        
                        if (src_filetype == FileType.DIRECTORY) {
                            try {
                                dst_file.make_directory();
                                succeed = true;
                            } catch (IOError e) {
                                Messages.show_error_t(m_context, "Error", e.message);
                                cancel = true;
                            }
                        } else {
                            try {
                                op.execute();
                                succeed = true;
                            } catch (IOError e) {
                                if (e is IOError.CANCELLED) {
                                    Messages.show_info_t(m_context,
                                        "Aborted",
                                        "Operation aborted by user."
                                        );
                                    cancel = true;
                                } else if (e is IOError.NOT_FOUND) {
                                    debug("file not found");
                                    Messages.show_error_t(m_context,
                                        "Source not found!",
                                        "Lost track of source file '%s'. I saw it! I swear!".printf(
                                            src_filename));
                                    skip_file = true;
                                } else if (e is IOError.EXISTS) {
                                    var dialog = new OverwriteDialog(m_context,
                                        op.m_source, op.m_destination);
                                    var response = dialog.run();
                                    
                                    switch (response) {
                                        case OverwriteDialog.RESPONSE_CANCEL:
                                            cancel = true;
                                            break;
                                        case OverwriteDialog.RESPONSE_RENAME:
                                            // TODO: rename dialog
                                            break;
                                        case OverwriteDialog.RESPONSE_OVERWRITE:
                                            op.m_overwrite = true;
                                            break;
                                        default:
                                            error("unknown response: %d", response);
                                    }
                                    
                                } else if (e is IOError.IS_DIRECTORY) {
                                    // TODO: tried to overwrite a file over directory
                                    Messages.show_error_t(m_context, "Error", e.message);
                                    cancel = true;
                                } else if (e is IOError.WOULD_MERGE) {
                                    // TODO: tried to overwrite a directory with a directory
                                    Messages.show_error_t(m_context, "Error", e.message);
                                    cancel = true;
                                } else if (e is IOError.WOULD_RECURSE) {
                                    // TODO: source is directory and target doesn't exists
                                    // or m_overwrite = true and target is a file
                                    Messages.show_error_t(m_context, "Error", e.message);
                                    cancel = true;
                                } else {
                                    Messages.show_error_t(m_context, "Error", e.message);
                                    cancel = true;
                                }
                            }
                        }
                        
                        if (cancel) {
                            debug("cancelling");
                            return false;
                        }
                        
                    } while (!succeed && !skip_file);
                }
                
                progress_f = bytes_copied / (double) bytes_total;
                return true;
        });
        
        show_progress_finished_t();
    }
    
    private void show_progress_preparing_t() {
        Idle.add(() => {
                m_progress_dialog.set_status_text_1("Preparing...");
                m_progress_dialog.show_all();
                return false;
        });
    }
    
    private void show_progress_copying_t(string p_filename, double p_value) {
        Idle.add(() => {
                m_progress_dialog.set_status_text_1("Copying %s".printf(p_filename));
                m_progress_dialog.set_progress(p_value);
                return false;
        });
    }
    
    private void show_progress_finished_t() {
        Idle.add(() => {
                m_progress_dialog.set_status_text_1("Operation finished!");
                m_progress_dialog.set_progress(1);
                m_progress_dialog.set_done();
                return false;
        });
    }
    
    private void progress_log_details_t(string p_text) {
        Idle.add(() => {
                m_progress_dialog.log_details(p_text);
                return false;
        });
    }
}

} // namespace
