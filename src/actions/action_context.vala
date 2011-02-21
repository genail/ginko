using Gtk;

namespace Ginko {

public class ActionContext : Context {
    public File source_dir;
    public List<File> source_selected_files = new List<File>();
    public File target_dir;
    public List<File> target_selected_files = new List<File>();
    
    public DirectoryController m_active_controller {get; set;}
    public DirectoryController m_unactive_controller {get; set;}
    
    public ActionContext(string name, Window main_window) {
        base(name, main_window);
    }
}

} // namespace
