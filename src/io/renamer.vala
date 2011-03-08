namespace Ginko.IO {

/**
 * Helper class to help renaming files for copy and move operations.
 */
public class Renamer {
    public File source_base_directory {get; set;}
    public int toplevel_source_file_count {get; set;}
    public string rename_string {get; set;}
    
    private bool m_initialized;
    private File m_target_base_file;
    private bool m_rename_first;
    private File m_first_file;
    
    public Renamer() {
        // empty
    }
  
    /**
     * Renames File to new File (this is not I/O operation).
     * It's essential that files must be renamed in natural order. First goes parent directory,
     * then its children, then next parent etc.
     */
    public File rename(File p_source) {
        // stick to these rules:
        //
        // if source is only one file/directory:
        //   if destination exists copy source to destination/source
        //   if destination doesn't exists copy and rename source to .../destination
        // if source are many files/directories:
        //   always copy to destination/source even if it doesn't exists
        
        if (!m_initialized) {
            initialize();
        }
        
        if (m_rename_first) {
            if (m_first_file == null) {
                m_first_file = p_source;
                return m_target_base_file;
            } else {
                return Files.rebase(p_source, m_first_file, m_target_base_file);
            }
        } else {
            return Files.rebase(p_source, source_base_directory, m_target_base_file);
        }
    }
    
    private void initialize() {
        assert(source_base_directory != null);
        assert(toplevel_source_file_count > 0);
        assert(rename_string != null && rename_string != "");
        
        // rename string may be relative or absolute path
        if (Files.is_relative(rename_string)) {
            m_target_base_file = source_base_directory.resolve_relative_path(rename_string);
            debug("relative path '%s' resolved to '%s'",
                rename_string, m_target_base_file.get_path());
        } else {
            m_target_base_file = File.new_for_path(rename_string);
        }
        
        if (toplevel_source_file_count == 1 && !m_target_base_file.query_exists()) {
            // copy and rename to destination
            m_rename_first = true;
        }
        
        m_initialized = true;
    }
}

} // namespace
