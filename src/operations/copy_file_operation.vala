using Gtk;
using Ginko.IO;
using Ginko.Dialogs;

namespace Ginko.Operations {

class CopyFileOperation : Operation {
    
    public enum Status {
        OK,
        SKIP,
        CANCEL
    }
    
    private Context m_context;
    private bool m_try_again;
    private Status m_return_status;
    
    public File source {get; set;}
    public File destination {get; set;}
    
    public bool overwrite {get; set;}
    public bool overwrite_all {get; set;} // set to true if user checked 'overwrite all' option
    
    public bool skip_on_overwrite_all {get; set;} // set to true if user checked 'skip all' option
    
    public bool follow_symlinks {get; set;}
    
    private FileProgressCallback m_progress_callback;
    
    private Cancellable m_cancellable = new Cancellable();
    
    
    /**
     * Constructs new CopyFileOperation based on user choices given on previous operation.
     * This means that if user made a choice that should affect all following operations
     * (overwrite all etc.) then this choice is preserved.
     */
    public CopyFileOperation(Context p_context, CopyFileOperation? p_previous_operation = null) {
        m_context = p_context;
        
        if (p_previous_operation != null) {
            if (p_previous_operation.overwrite_all) {
                overwrite = true;
                overwrite_all = true;
            }
            
            skip_on_overwrite_all = p_previous_operation.skip_on_overwrite_all;
        }
    }
    
    public uint64 get_cost() {
        return Files.query_size(source);
    }
    
    public Status execute() throws IOError {
        do {
            m_try_again = false;
            
            try {
                if (Config.debug) {
                    Posix.sleep(1);
                }
                
                source.copy(
                    destination,
                    gen_copy_flags(),
                    m_cancellable,
                    m_progress_callback
                    );
            } catch (IOError e) {
                if (e is IOError.CANCELLED) {
                    m_return_status = Status.CANCEL;
                } else if (e is IOError.EXISTS) {
                    if (skip_on_overwrite_all) {
                        m_return_status = Status.SKIP;
                    } else {
                        prompt_overwrite();
                    }
                } else {
                    throw e;
                }
            }
        } while (m_try_again);
        
        return m_return_status;
    }
    
    public bool cancel() {
        m_cancellable.cancel();
        return m_cancellable.is_cancelled();
    }
    
    private FileCopyFlags gen_copy_flags() {
        FileCopyFlags flags = FileCopyFlags.NONE;
        if (overwrite) {
            flags |= FileCopyFlags.OVERWRITE;
        }
        
        if (!follow_symlinks) {
            flags |= FileCopyFlags.NOFOLLOW_SYMLINKS;
        }
        
        return flags;
    }
    
    public void set_progress_callback(owned FileProgressCallback p_callback) {
        m_progress_callback = (owned) p_callback;
    }
    
    private void prompt_overwrite() {
        GuiExecutor.run_and_wait(() => {
                var dialog = new OverwriteDialog(m_context, source, destination);
                var response = dialog.run();
                dialog.close();
                
                switch (response) {
                    case OverwriteDialog.RESPONSE_CANCEL:
                        m_return_status = Status.CANCEL;
                        break;
                    case OverwriteDialog.RESPONSE_RENAME:
                        if (prompt_rename()) {
                            m_try_again = true;
                        } else {
                            m_return_status = Status.CANCEL;
                        }
                        break;
                    case OverwriteDialog.RESPONSE_OVERWRITE:
                        overwrite = true;
                        overwrite_all = dialog.is_apply_to_all();
                        m_try_again = true;
                        break;
                    case OverwriteDialog.RESPONSE_SKIP:
                        m_return_status = Status.SKIP;
                        skip_on_overwrite_all = dialog.is_apply_to_all();
                        break;
                    case ResponseType.DELETE_EVENT:
                        m_return_status = Status.CANCEL;
                        break;
                    default:
                        error("unknown response: %d", response);
                }
                
        });
    }
    
    private bool prompt_rename() {
        var basename = destination.get_basename();
        var rename_dialog = new RenameDialog(m_context, basename);
        var response = rename_dialog.run();
        
        try {
            if (response == RenameDialog.RESPONSE_OK) {
                var new_filename = rename_dialog.get_filename();
                
                var parent = destination.get_parent();
                destination = parent.get_child(new_filename);
                
                return true;
            }
            
            return false;
        } finally {
            rename_dialog.close();
        }
    }
}

} // namespace
