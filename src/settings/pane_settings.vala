namespace Ginko {

public class PaneSettings : AbstractSettings {
    private static const string ROOT = Settings.ROOT + "/panes";
    
    private static const string KEY_ICON_COLUMN_SIZE = "icon_column_size";
    private static const string KEY_NAME_COLUMN_SIZE = "name_column_size";
    private static const string KEY_EXT_COLUMN_SIZE = "ext_column_size";
    private static const string KEY_SIZE_COLUMN_SIZE = "size_column_size";
    private static const string KEY_TIME_COLUMN_SIZE = "time_column_size";
    private static const string KEY_ATTR_COLUMN_SIZE = "attr_column_size";
    
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
    
    //
    // column sizes
    //
    
    public int get_icon_column_size(int p_default) {
        return get_integer(KEY_ICON_COLUMN_SIZE, p_default);
    }
    
    public void set_icon_column_size(int p_size) {
        set_integer(KEY_ICON_COLUMN_SIZE, p_size);
    }
    
    public int get_name_column_size(int p_default) {
        return get_integer(KEY_NAME_COLUMN_SIZE, p_default);
    }
    
    public void set_name_column_size(int p_size) {
        set_integer(KEY_NAME_COLUMN_SIZE, p_size);
    }
    
    public int get_ext_column_size(int p_default) {
        return get_integer(KEY_EXT_COLUMN_SIZE, p_default);
    }
    
    public void set_ext_column_size(int p_size) {
        set_integer(KEY_EXT_COLUMN_SIZE, p_size);
    }
    
    public int get_size_column_size(int p_default) {
        return get_integer(KEY_SIZE_COLUMN_SIZE, p_default);
    }
    
    public void set_size_column_size(int p_size) {
        set_integer(KEY_SIZE_COLUMN_SIZE, p_size);
    }
    
    public int get_time_column_size(int p_default) {
        return get_integer(KEY_TIME_COLUMN_SIZE, p_default);
    }
    
    public void set_time_column_size(int p_size) {
        set_integer(KEY_TIME_COLUMN_SIZE, p_size);
    }
    
    public int get_attr_column_size(int p_default) {
        return get_integer(KEY_ATTR_COLUMN_SIZE, p_default);
    }
    
    public void set_attr_column_size(int p_size) {
        set_integer(KEY_ATTR_COLUMN_SIZE, p_size);
    }
}
    
} // namespace
