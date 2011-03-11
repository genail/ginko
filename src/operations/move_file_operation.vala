using Ginko.IO;

namespace Ginko.Operations {

public errordomain MoveFileError {
    IO_ERROR
}
    
public class MoveFileOperation : Operation {
    
    public enum Status {
        OK,
        SKIP,
        CANCEL
    }
    
    private Context m_context;
    
    public File source {get; set;}
    public File destination {get; set;}
    
    private Status m_return_status;
    private FileProgressCallback m_progress_callback;
    private Cancellable m_cancellable = new Cancellable();
    private CopyFileOperation m_copy;
    
    private bool m_cancel_requested;
    
    
    public MoveFileOperation(Context p_context) {
        m_context = p_context;
    }
    
    // workaround for ownage bug?
    public void set_progress_callback(owned FileProgressCallback p_callback) {
        m_progress_callback = (owned) p_callback;
    }
    
    public uint64 get_cost() {
        return 1; // TODO: check if it's on the same file system
    }
    
    public bool cancel() {
        m_cancellable.cancel();
        if (m_copy != null) {
            m_copy.cancel();
        }
        
        m_cancel_requested = true;
        
        return true; // there's no easy way to tell if cancelling failed 
    }
    
    public Status execute() throws MoveFileError {
        assert(source != null);
        assert(destination != null);
        
        try {
            if (Config.debug) {
                Posix.sleep(1);
            }
            
            source.move(destination, FileCopyFlags.NOFOLLOW_SYMLINKS,
                m_cancellable, m_progress_callback);
            m_return_status = Status.OK;
        } catch (IOError e) {
            if (e is IOError.WOULD_RECURSE) {
                try {
                    debug("Cannot move - using copy fallback");
                    execute_copy_fallback();
                } catch (CopyFileError e) {
                    throw new MoveFileError.IO_ERROR(e.message);
                }
            } else {
                throw new MoveFileError.IO_ERROR(e.message);
            }
        }
        
        return m_return_status;
    }
    
    private void execute_copy_fallback() throws CopyFileError {
        // we need tree scanning
        var scanner = new TreeScanner();
        
        var renamer = new Renamer();
        
        assert(source.has_parent(null));
        renamer.source_base_directory = source.get_parent();
        renamer.toplevel_source_file_count = 1;
        renamer.rename_string = destination.get_path();
        
        scanner.scan(source, (file, file_info) => {
                m_copy = new CopyFileOperation(m_context, m_copy);
                m_copy.source = file;
                m_copy.destination = renamer.rename(file);
                
                try {
                    return m_copy.execute() != CopyFileOperation.Status.CANCEL;
                } catch (CopyFileError e) {
                    throw e;
                }
        });
    }
}

} // namespace
