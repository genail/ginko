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
    
    public bool is_directory(bool p_follow_symlinks) {
        var type = m_file.query_file_type(
            p_follow_symlinks ? FileQueryInfoFlags.NONE : FileQueryInfoFlags.NOFOLLOW_SYMLINKS);
        return type == FileType.DIRECTORY;
    }
    
    public void make_parents_if_not_exists() throws IOError {
        if (m_file.has_parent(null)) {
            var parent = m_file.get_parent();
            if (!parent.query_exists()) {
                parent.make_directory_with_parents();
            }
        }
    }
}

} // namespace
