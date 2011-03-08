using Gtk;
using Ginko.IO;
using Ginko.Util;
using Ginko.Dialogs;
using Ginko.Operations;


namespace Ginko.Actions {

class CopyFileAction : AbstractFileAction {
    
    private CopyFileConfig m_config;
    private File m_dest_file;
    
    private uint64 m_bytes_processed;
    private uint64 m_bytes_total;
    
    private CopyFileOperation m_copy_op;
    private uint64 m_bytes_processed_before;
    
    private bool m_overwrite_all;
    private bool m_skip_all;
    
    private Renamer m_renamer = new Renamer();
    private bool m_first_file = true;
    
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
        
        m_renamer.source_base_directory = p_context.source_dir;
        m_renamer.toplevel_source_file_count = p_context.source_selected_files.length;
        m_renamer.rename_string = m_config.destination;
        
        return return_code == CopyFileConfigureDialog.Response.OK;
    }
    
    private bool has_many_input_files(ActionContext p_context) {
        return p_context.source_selected_files.length > 1;
    }
    
    protected override bool prepare_t(ActionContext p_context) {
        foreach (var infile in p_context.source_selected_files) {
            m_bytes_total += Files.calculate_space_recurse(infile, m_config.follow_symlinks);
        }
        
        return true;
    }
    
    protected override bool on_file_found_t(ActionContext p_context,
        File p_file, FileInfo p_fileinfo,
        AbstractAction.ProgressCallback p_callback) {
        
        File dest = m_renamer.rename(p_file);
        
        if (m_first_file) {
            // if this is first file then the parent may not exists
            if (dest.has_parent(null)) {
                var parent = dest.get_parent();
                if (!parent.query_exists()) {
                    try {
                        parent.make_directory_with_parents();
                    } catch (IOError e) {
                        show_error(e.message);
                        set_status(Status.ERROR);
                        return false;
                    }
                }
            }
            
            m_first_file = false;
        }
        
        debug("dest: %s", dest.get_path());
        
        if (Files.with(p_file).is_ancestor_to(dest)) {
            show_error("Copying ancestor over child is disallowed.");
            set_status(Status.ERROR);
            return false;
        }
        
        
        create_copy_file_operation_t(p_file, dest, p_callback);
        
        p_callback(get_progress_percent(), "Copying %s".printf(p_file.get_path()));
        
        var file_type = p_fileinfo.get_file_type();
        
        do {
            if (file_type == FileType.DIRECTORY) {
                try {
                    dest.make_directory();
                    set_status(Status.SUCCESS);
                } catch (IOError e) {
                    show_error(e.message + "\n" + dest.get_path());
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
                            + " to " + dest.get_path());
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
        AbstractAction.ProgressCallback p_callback) {
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
