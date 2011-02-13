using Gtk;

namespace Ginko {

class ActionContext : Context {
    public File source_dir;
    public List<File> source_selected_files;
    public File target_dir;
    public List<File> target_selected_files;
    
    public ActionContext(string name, Window main_window) {
        base(name, main_window);
    }
}

} // namespace
