namespace Ginko {
    
public class Settings {
    private static Settings s_settings = new Settings();
    
    public static unowned Settings get() {
        typeof(Settings).class_ref(); // static fields fix
        return s_settings;
    }
    
    private GLib.Settings m_gsettings;
    
    private Settings() {
        m_gsettings = new GLib.Settings("ginko");
    }
    
    public string get_left_pane_path() {
        return m_gsettings.get_string("left-pane-path");
    }
    
    public void set_left_pane_path(string p_path) {
        m_gsettings.set_string("left-pane-path", p_path);
    }
    
    public string get_right_pane_path() {
        return m_gsettings.get_string("right-pane-path");
    }
    
    public void set_right_pane_path(string p_path) {
        m_gsettings.set_string("right-pane-path", p_path);
    }
    
}

} // namespace
