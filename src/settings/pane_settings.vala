namespace Ginko {

public class PaneSettings : AbstractSettings {
    private static const string ROOT = Settings.ROOT + "/panes";
    
    private string m_name;
    
    public PaneSettings(string p_name) {
        base(ROOT + "/" + p_name);
    }
    
    public string get_path(string p_default = "") {
        return get_string("path", p_default);
    }
    
    public void set_path(string p_path) {
        set_string("path", p_path);
    }
}
    
} // namespace
