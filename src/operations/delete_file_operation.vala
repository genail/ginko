using Ginko.IO;

namespace Ginko.Operations {

public class DeleteFileOperation : Operation {
    public File file {get; set;}
    
    private Cancellable m_cancellable = new Cancellable();
    
    public uint64 get_cost() {
        assert(file != null);
        return Files.query_size(file);
    }
    
    public void execute() throws Error {
        assert(file != null);
        file.delete(m_cancellable);
    }
    
    public bool cancel() {
        m_cancellable.cancel();
        return m_cancellable.is_cancelled();
    }
}
    
}
