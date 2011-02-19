using Gtk;

namespace Ginko {

class ApplicationContext : Context {
    public List<ActionDescriptor> action_descriptors = new List<ActionDescriptor>();
    
    public ApplicationContext(string name, Window main_window) {
        base(name, main_window);
    }
}

} // namespace
