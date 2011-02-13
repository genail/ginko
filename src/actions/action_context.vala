using Gtk;

namespace Ginko {

public class ActionContext : Context {
    public File source_dir;
    public List<File> source_selected_files = new List<File>();
    public File target_dir;
    public List<File> target_selected_files = new List<File>();
    
    public ActionContext(string name, Window main_window) {
        base(name, main_window);
    }
}

} // namespace
