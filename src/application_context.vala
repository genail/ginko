using Gtk;

namespace Ginko {

class ApplicationContext : Context {
    public List<Action> actions = new List<Action>();
    
    public ApplicationContext(string name, Window main_window) {
        base(name, main_window);
    }
}

} // namespace
