namespace Ginko {
    
public class Settings : AbstractSettings {
    public static const string ROOT = "/apps/ginko/preferences";
    
    private static Settings s_settings = new Settings();
    
    public static unowned Settings get() {
        typeof(Settings).class_ref(); // static fields fix
        return s_settings;
    }
    
    private Settings() {
        base(ROOT);
    }
    
    public PaneSettings get_pane(string p_name) {
        return new PaneSettings(p_name);
    }
    
    public bool is_show_hidden_files(bool p_default = false) {
        return get_boolean("show_hidden_files", p_default);
    }
    
    public void set_show_hidden_files(bool p_show_hidden_files) {
        set_boolean("show_hidden_files", p_show_hidden_files);
    }
    
    public void set_show_hidden_files_changed_callback(AbstractSettings.BooleanChanged p_callback) {
        add_boolean_notify("show_hidden_files", p_callback);
    }
    
    
    
}

} // namespace
