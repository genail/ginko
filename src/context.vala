using Gtk;

namespace Ginko {

public abstract class Context : GLib.Object {
    public string m_name {get; private set;}
    public Window m_main_window {get; private set;}
    
    public Context(string p_name, Window p_main_window) {
        m_name = p_name;
        m_main_window = p_main_window;
    }
}

} // namespace
