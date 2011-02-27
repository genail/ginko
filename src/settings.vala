namespace Ginko {
    
public class Settings {
    private static const string PREFERENCES_ROOT = "/apps/ginko/preferences";
    
    private static Settings s_settings = new Settings();
    
    public delegate void BooleanChanged(bool p_new_value);
    
    public static unowned Settings get() {
        typeof(Settings).class_ref(); // static fields fix
        return s_settings;
    }
    
    private GConf.Client m_gconf;
    
    private Settings() {
        m_gconf = GConf.Client.get_default();
        m_gconf.add_dir(PREFERENCES_ROOT, GConf.ClientPreloadType.RECURSIVE);
    }
    
    public string get_left_pane_path(string p_default = "") {
        return get_string("left_pane_path", p_default);
    }
    
    public void set_left_pane_path(string p_path) {
        set_string("left_pane_path", p_path);
    }
    
    public string get_right_pane_path(string p_default = "") {
        return get_string("right_pane_path", p_default);
    }
    
    public void set_right_pane_path(string p_path) {
        set_string("right_pane_path", p_path);
    }
    
    public bool is_show_hidden_files(bool p_default = false) {
        return get_boolean("show_hidden_files", p_default);
    }
    
    public void set_show_hidden_files(bool p_show_hidden_files) {
        set_boolean("show_hidden_files", p_show_hidden_files);
    }
    
    public void set_show_hidden_files_changed_callback(BooleanChanged p_callback) {
        try {
            m_gconf.notify_add(to_abs("show_hidden_files"), () => {
                    var value = is_show_hidden_files();
                    p_callback(value);
            });
        } catch (Error e) {
            warning("cannot add notify for reason: %s", e.message);
        }
    }
    
    private bool is_set(string p_rel_key) throws Error {
        var value = m_gconf.get_without_default(to_abs(p_rel_key));
        return value != null;
    }
    
    private string get_string(string p_rel_key, string p_default) {
        try {
            if (is_set(p_rel_key)) {
                return m_gconf.get_string(to_abs(p_rel_key));
            } else {
                return p_default;
            }
        } catch (Error e) {
            warning("cannot get gconf key '%s': %s", to_abs(p_rel_key), e.message);
            return p_default;
        }
    }
    
    private void set_string(string p_rel_key, string p_value) {
        try {
            m_gconf.set_string(to_abs(p_rel_key), p_value);
        } catch (Error e) {
            warning("cannot set gconf key '%s': %s", to_abs(p_rel_key), e.message);
        }
    }
    
    private bool get_boolean(string p_rel_key, bool p_default) {
        try {
            if (is_set(p_rel_key)) {
                return m_gconf.get_bool(to_abs(p_rel_key));
            } else {
                return p_default;
            }
        } catch (Error e) {
            warning("cannot get gconf key '%s': %s", to_abs(p_rel_key), e.message);
            return p_default;
        }
    }
    
    private void set_boolean(string p_rel_key, bool p_value) {
        try {
            m_gconf.set_bool(to_abs(p_rel_key), p_value);
        } catch (Error e) {
            warning("cannot set gconf key '%s': %s", to_abs(p_rel_key), e.message);
        }
    }
    
    private string to_abs(string p_rel_key) {
        return PREFERENCES_ROOT + "/" + p_rel_key;
    }
    
}

} // namespace
