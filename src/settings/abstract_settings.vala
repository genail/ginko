namespace Ginko {

public abstract class AbstractSettings {
    
    public delegate void BooleanChanged(bool p_new_value);
    
    private string m_root;
    protected GConf.Client m_gconf;
    
    protected AbstractSettings(string p_root) {
        m_root = p_root;
        m_gconf = GConf.Client.get_default();
        m_gconf.add_dir(m_root, GConf.ClientPreloadType.RECURSIVE);
    }
    
    protected bool is_set(string p_rel_key) throws Error {
        var value = m_gconf.get_without_default(to_abs(p_rel_key));
        return value != null;
    }
    
    protected string get_string(string p_rel_key, string p_default) {
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
    
    protected void set_string(string p_rel_key, string p_value) {
        try {
            m_gconf.set_string(to_abs(p_rel_key), p_value);
        } catch (Error e) {
            warning("cannot set gconf key '%s': %s", to_abs(p_rel_key), e.message);
        }
    }
    
    protected bool get_boolean(string p_rel_key, bool p_default) {
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
    
    protected void add_boolean_notify(string p_rel_key, BooleanChanged p_callback) {
        try {
            m_gconf.notify_add(to_abs(p_rel_key), () => {
                    var value = get_boolean(p_rel_key, false);
                    p_callback(value);
            });
        } catch (Error e) {
            warning("cannot add notify for reason: %s", e.message);
        }
    }
    
    protected void set_boolean(string p_rel_key, bool p_value) {
        try {
            m_gconf.set_bool(to_abs(p_rel_key), p_value);
        } catch (Error e) {
            warning("cannot set gconf key '%s': %s", to_abs(p_rel_key), e.message);
        }
    }
    
    protected string to_abs(string p_rel_key) {
        return m_root + "/" + p_rel_key;
    }
}
    
} // namespace
