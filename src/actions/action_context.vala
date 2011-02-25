using Gtk;

namespace Ginko {

public class ActionContext : Context {
    public File source_dir;
    public File destination_dir;
    
    private File[] m_source_selected_files = {};
    public File[] source_selected_files {
        get {
            return m_source_selected_files;
        }
        
        set {
            m_source_selected_files = {};
            foreach (var file in value) {
                m_source_selected_files += file;
            }
        }
    }
    
    private File[] m_destination_selected_files = {};
    public File[] destination_selected_files {
        get {
            return m_destination_selected_files;
        }
        
        set {
            m_destination_selected_files = {};
            foreach (var file in value) {
                m_destination_selected_files += file;
            }
        }
    }
    
    public DirectoryController active_controller {get; set;}
    public DirectoryController unactive_controller {get; set;}
    
    public ActionContext(string p_name, Window p_main_window) {
        base(p_name, p_main_window);
    }
}

} // namespace
