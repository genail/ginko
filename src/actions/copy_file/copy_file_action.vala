using Gtk;
using Ginko.IO;
using Ginko.Util;
using Ginko.Dialogs;
using Ginko.Operations;


namespace Ginko.Actions {

class CopyFileAction : AbstractFileAction {
    
    private CopyFileConfig m_config;
    
    private uint64 m_bytes_processed;
    private uint64 m_bytes_total;
    
    private CopyFileOperation m_copy_op;
    private uint64 m_bytes_processed_before;
    
    private bool m_overwrite_all;
    private bool m_skip_all;
    
    protected CopyFileAction(ActionDescriptor p_action_descriptor) {
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
        var config_dialog = new CopyFileConfigureDialog(p_context);
        
        int return_code = config_dialog.run();
        m_config = config_dialog.get_config();
        set_follow_symlinks(m_config.follow_symlinks);
        
        config_dialog.close();
        
        return return_code == CopyFileConfigureDialog.Response.OK;
    }
    
    protected override bool prepare_t(ActionContext p_context) {
        foreach (var infile in p_context.source_selected_files) {
            m_bytes_total += Files.calculate_space_recurse(infile, m_config.follow_symlinks);
        }
        
        return true;
    }
    
    protected override bool on_file_found_t(ActionContext p_context,
        File p_file, FileInfo p_fileinfo,
        AbstractFileAction.ProgressCallback p_callback) {
    
        
        File dest_dir;
        if (!Files.is_relative(m_config.destination)) {
            dest_dir = File.new_for_path(m_config.destination);
        } else {
            dest_dir = p_context.source_dir.resolve_relative_path(m_config.destination);
        }
        
        if (!dest_dir.query_exists()) {
            try {
                dest_dir.make_directory_with_parents();
            } catch (Error e) {
                show_error(e.message + "\n" + dest_dir.get_path());
                set_status(Status.ERROR);
                return false;
            }
        }
    
        var dst_file = Files.rebase(p_file,
            p_context.source_dir, dest_dir);
        
        create_copy_file_operation_t(p_file, dst_file, p_callback);
        
        p_callback(get_progress_percent(), "Copying %s".printf(p_file.get_path()));
        
        var file_type = p_fileinfo.get_file_type();
        
        do {
            if (file_type == FileType.DIRECTORY) {
                try {
                    dst_file.make_directory();
                    set_status(Status.SUCCESS);
                } catch (IOError e) {
                    show_error(e.message + "\n" + dst_file.get_path());
                    set_status(Status.ERROR);
                }
            } else {
                try {
                    m_copy_op.execute();
                    set_status(Status.SUCCESS);
                } catch (IOError e) {
                    if (e is IOError.CANCELLED) {
                        set_status(Status.CANCEL);
                    } else if (e is IOError.NOT_FOUND) {
                        show_error(e.message + "\n" + p_file.get_path());
                        set_status(Status.ERROR);
                    } else if (e is IOError.EXISTS) {
                        if (m_skip_all) {
                            set_status(Status.SKIP);
                        } else if (m_overwrite_all) {
                            m_copy_op.m_overwrite = true;
                            set_status(Status.TRY_AGAIN);
                        } else {
                            prompt_overwrite_t(p_context);
                        }
                    } else {
                        show_error(e.message + "\n" + p_file.get_path()
                            + " to " + dst_file.get_path());
                        set_status(Status.ERROR);
                    }
                }
            }
            
            if (Config.debug) {
                Posix.sleep(1);
            }
            
        } while (get_status() == Status.TRY_AGAIN); // retry until action is done
        
        return true;
    }
    
    private void create_copy_file_operation_t(File p_source, File p_dest,
        AbstractFileAction.ProgressCallback p_callback) {
        m_copy_op = new CopyFileOperation();
        m_copy_op.m_source = p_source;
        m_copy_op.m_destination = p_dest;
        m_bytes_processed_before = m_bytes_processed;
        
        m_copy_op.set_progress_callback((current, total) => {
                p_callback(get_progress_percent());
        });
    }
    
    private float get_progress_percent() {
        return (float) (m_bytes_processed / (double) m_bytes_total);
    }
    
    private void prompt_overwrite_t(ActionContext p_context) {
        GuiExecutor.run_and_wait(() => {
                var dialog = new OverwriteDialog(p_context,
                    m_copy_op.m_source, m_copy_op.m_destination);
                var response = dialog.run();
                dialog.close();
                
                switch (response) {
                    case OverwriteDialog.RESPONSE_CANCEL:
                        set_status(Status.CANCEL);
                        break;
                    case OverwriteDialog.RESPONSE_RENAME:
                        if (prompt_rename(p_context)) {
                            set_status(Status.TRY_AGAIN);
                        } else {
                            set_status(Status.CANCEL);
                        }
                        break;
                    case OverwriteDialog.RESPONSE_OVERWRITE:
                        m_copy_op.m_overwrite = true;
                        m_overwrite_all = dialog.is_apply_to_all();
                        set_status(Status.TRY_AGAIN);
                        break;
                    case OverwriteDialog.RESPONSE_SKIP:
                        set_status(Status.SKIP);
                        m_skip_all = dialog.is_apply_to_all();
                        break;
                    case ResponseType.DELETE_EVENT:
                        set_status(Status.CANCEL);
                        break;
                    default:
                        error("unknown response: %d", response);
                }
                
        });
    }
    
    private bool prompt_rename(ActionContext p_context) {
        var basename = m_copy_op.m_destination.get_basename();
        var rename_dialog = new RenameDialog(p_context, basename);
        var response = rename_dialog.run();
        
        try {
            if (response == RenameDialog.RESPONSE_OK) {
                var new_filename = rename_dialog.get_filename();
                
                var parent = m_copy_op.m_destination.get_parent();
                m_copy_op.m_destination = parent.get_child(new_filename);
                
                return true;
            }
            
            return false;
        } finally {
            rename_dialog.close();
        }
    }
}

} // namespace
