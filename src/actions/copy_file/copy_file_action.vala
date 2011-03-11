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
            try {
                Files.with(dest).make_parents_if_not_exists();
            } catch (IOError e) {
                show_error(e.message);
                set_status(Status.ERROR);
                return false;
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
                    CopyFileOperation.Status copy_op_status = m_copy_op.execute();
                    
                    if (copy_op_status != CopyFileOperation.Status.CANCEL) {
                        set_status(Status.SUCCESS);
                    } else {
                        set_status(Status.CANCEL);
                    }
                } catch (IOError e) {
                    show_error(e.message + "\n" + p_file.get_path()
                        + " to " + dest.get_path());
                    set_status(Status.ERROR);
                }
            }
            
            if (cancel_requested) {
                set_status(Status.CANCEL);
            }
            
            
        } while (get_status() == Status.TRY_AGAIN); // retry until action is done
        
        return true;
    }
    
    private void create_copy_file_operation_t(File p_source, File p_dest,
        AbstractAction.ProgressCallback p_callback) {
        m_copy_op = new CopyFileOperation(context, m_copy_op);
        m_copy_op.source = p_source;
        m_copy_op.destination = p_dest;
        m_bytes_processed_before = m_bytes_processed;
     
        // workaround for https://bugzilla.gnome.org/show_bug.cgi?id=642899
        m_copy_op.set_progress_callback((current, total) => {
                m_bytes_processed = m_bytes_processed_before + current;
                p_callback(get_progress_percent());
        });
    }
    
    private float get_progress_percent() {
        return (float) (m_bytes_processed / (double) m_bytes_total);
    }
    
    protected override void on_cancel_request() {
        m_copy_op.cancel();
    }
    
}

} // namespace
