namespace Ginko.IO {

public class TreeScanner {
    
    /** @return false if scanning should be stopped */
    public delegate bool FileFoundCallback(File p_file, FileInfo p_file_info);
    
    private string[] m_attributes;
    public bool m_follow_symlinks {get; set; default = true;}
    
    private string m_attr_list;
    
    public void add_attribute(string p_attr) {
        m_attributes += p_attr;
    }
    
    public void clear_attributes() {
        m_attributes = {};
    }
    
    public void scan(File p_file, FileFoundCallback p_file_found_callback) {
        compile_attribute_list();
        
        if (p_file.query_exists()) {
            if (!p_file_found_callback(p_file, info(p_file))) {
                return;
            }
        }
        
        var type = p_file.query_file_type(
            m_follow_symlinks ? FileQueryInfoFlags.NONE : FileQueryInfoFlags.NOFOLLOW_SYMLINKS);
        if (type == FileType.DIRECTORY) {
            list_children_recurse(p_file, p_file_found_callback);
        }
    }
    
    /** @return false if stop scanning */
    public bool list_children_recurse(File p_dir, FileFoundCallback p_file_found_callback)
    throws Error {
        var enumerator = p_dir.enumerate_children(
            m_attr_list,
            m_follow_symlinks ? FileQueryInfoFlags.NONE : FileQueryInfoFlags.NOFOLLOW_SYMLINKS,
            null);
        
        FileInfo fileinfo;
        while ((fileinfo = enumerator.next_file()) != null) {
            var file_name = fileinfo.get_name();
            var child_file = p_dir.get_child(file_name);
            if (!p_file_found_callback(child_file, fileinfo)) {
                return false;
            }
            
            var file_type = fileinfo.get_file_type();
            if (file_type == FileType.DIRECTORY) {
                if (!list_children_recurse(child_file, p_file_found_callback)) {
                    return false;
                }
            }
        }
        
        return true;
    }
    
    private void compile_attribute_list() {
        m_attr_list = FILE_ATTRIBUTE_STANDARD_NAME + "," + FILE_ATTRIBUTE_STANDARD_TYPE;
        foreach (var attr in m_attributes) {
            m_attr_list += "," + attr;
        }
    }
    
    private FileInfo info(File p_file) {
        return p_file.query_info(m_attr_list,
            m_follow_symlinks ? FileQueryInfoFlags.NONE : FileQueryInfoFlags.NOFOLLOW_SYMLINKS,
            null);
    }
    
    
}
    
} // namespace
