using Gtk;

namespace Ginko {

public abstract class Context : GLib.Object {
    public string name {get; private set;}
    public Window main_window {get; private set;}
    
    public Context(string name, Window main_window) {
        this.name = name;
        this.main_window = main_window;
    }
}

} // namespace
