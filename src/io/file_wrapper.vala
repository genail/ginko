namespace Ginko.IO {

public class FileWrapper {
    
    private File m_file;
    
    public FileWrapper(File p_file) {
        m_file = p_file;
    }
    
    public bool is_ancestor_to(File p_file) {
        File tmpfile = p_file;
        
        while (tmpfile.has_parent(null)) {
            tmpfile = tmpfile.get_parent();
            if (tmpfile.equal(m_file)) {
                return true;
            }
        }
        
        return false;
    }
}

} // namespace
