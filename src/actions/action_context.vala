using Gtk;

namespace Ginko {

public class ActionContext : Context {
    public File m_source_dir;
    public File m_destination_dir;
    
    public List<File> m_source_selected_files = new List<File>();
    public List<File> m_destination_selected_files = new List<File>();
    
    public DirectoryController m_active_controller {get; set;}
    public DirectoryController m_unactive_controller {get; set;}
    
    public ActionContext(string p_name, Window p_main_window) {
        base(p_name, p_main_window);
    }
}

} // namespace
