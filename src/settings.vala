namespace Ginko {
    
public class Settings {
    private static Settings s_settings = new Settings();
    
    public delegate void BooleanChanged(bool p_new_value);
    
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
    
    public bool is_show_hidden_files() {
        return m_gsettings.get_boolean("show-hidden-files");
    }
    
    public void set_show_hidden_files(bool p_show_hidden_files) {
        m_gsettings.set_boolean("show-hidden-files", p_show_hidden_files);
    }
    
    public void set_show_hidden_files_changed_callback(BooleanChanged p_callback) {
        m_gsettings.changed["show-hidden-files"].connect((p_key_name) => {
                var value = is_show_hidden_files();
                p_callback(value);
        });
    }
    
}

} // namespace
