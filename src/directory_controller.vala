using Gdk;
using Gtk;
using Gee;
using Ginko.Format;

namespace Ginko {

public class DirectoryController : GLib.Object {
    private const string DEFAULT_FILE_QUERY_ATTR =
                FILE_ATTRIBUTE_STANDARD_TYPE + "," +
                FILE_ATTRIBUTE_STANDARD_NAME + "," +
                FILE_ATTRIBUTE_STANDARD_SIZE + "," +
                FILE_ATTRIBUTE_STANDARD_ICON + "," +
                FILE_ATTRIBUTE_STANDARD_CONTENT_TYPE + "," +
                FILE_ATTRIBUTE_TIME_MODIFIED + "," +
                FILE_ATTRIBUTE_UNIX_MODE;

    public DirectoryView m_view { get; private set; }
    public DirectoryModel m_model { get; private set; }
    
    public File m_current_file { get; private set; }
    
    private IconTheme m_default_icon_theme = IconTheme.get_default();
    private HashMap<string, Pixbuf> m_icon_cache = new HashMap<string, Pixbuf>();
    
    // current entry name to file info
    private HashMap<string, FileInfo> m_fileinfos = new HashMap<string, FileInfo>();
        
    public DirectoryController() {
        m_model = new DirectoryModel();
        m_view = new DirectoryView(m_model);

        connect_signals();
        
        load_path(".");
    }
    
    public void make_active() {
        m_view.show_cursor();
        m_view.grab_focus();
    }
    
    public void make_unactive() {
        m_view.hide_cursor();
    }
    
    public GLib.List<File> get_selected_files() {
        var entry = m_view.get_selected_entry();
        
        var list = new GLib.List<File>();
        
        if (entry != null) {
            list.append(entry.file);
        }
        
        return list;
    }
    
    public void refresh() {
        load_path(m_current_file.get_path());
        m_view.show_cursor(); // because after path loading it's hidden
    }
    
    private void connect_signals() {
        
        m_view.key_pressed.connect(on_key_pressed);
        m_view.button_press_event.connect(on_button_press);
        
        m_view.entry_activation_request.connect(activate_entry);
        m_view.entry_highlight_toggle_request.connect(toggle_entry_highlight);
    }
    
    private bool on_key_pressed(string p_key) {
        switch (p_key) {
            case "Return":
                var entry = m_view.get_selected_entry();
                if (entry != null) {
                    activate_entry(entry);
                }
                return true;
            case "BackSpace":
                on_navigate_up_request();
                return true;
            default:
                return false;
        }
    }
    
    private bool on_button_press(EventButton p_event) {
        if (p_event.type == EventType.2BUTTON_PRESS) {
            return true;
        }
        
        return false;
    }
    
    private void toggle_entry_highlight(TreePath path) {
        var entry = m_model.path_to_entry(path);
        
        entry.highlighted = !entry.highlighted;
        m_model.set_entry_highlighted(path, entry.highlighted);
        
        if (!m_view.move_cursor_down()) {
            m_view.hide_cursor();
        }
    }
    
    private void activate_entry(DirectoryModel.Entry p_entry) {
        try {
            var child = p_entry.file;
            
            if (child.query_exists()) {
                var info = child.query_info(FILE_ATTRIBUTE_STANDARD_TYPE, 0);
                var type = info.get_file_type();
                
                if (type == FileType.DIRECTORY) {
                    load_path(child.get_path());
                    m_view.set_cursor_at_top();
                } else {
                    execute_app_on_file(child);
                }
            }
        } catch (Error e) {
            error(e.message);
        }
    }
    
    private void execute_app_on_file(File p_file) {
        try {
            AppInfo app_info = p_file.query_default_handler(null);
            var file_list = new GLib.List<File>();
            file_list.append(p_file);
            app_info.launch(file_list, null);
        } catch (Error e) {
            debug(e.message);
        }
    }
    
    private void on_navigate_up_request() {
        if (m_current_file.has_parent(null)) {
            var parent = m_current_file.get_parent();
            var parent_path = parent.get_path();
            load_path(parent_path);
            
            m_view.set_cursor_at_top();
        }
    }
    
    private void load_path(string p_path) {
        m_model.start_editing();
        m_model.clear();
        try {
            m_fileinfos.clear();
            FileInfo fileinfo;
        
            var directory = File.new_for_path(p_path);
            if (directory.has_parent(null)) {
                // put ".." entry at top
                var parent = directory.get_parent();
                
                fileinfo = File.new_for_path(parent.get_path()).query_info(
                    DEFAULT_FILE_QUERY_ATTR, 0);
                    
                fileinfo.set_name("..");
                load_file_info(directory, fileinfo, true);
            }
            
            var enumerator = directory.enumerate_children(DEFAULT_FILE_QUERY_ATTR, 0);
            while ((fileinfo = enumerator.next_file()) != null) {
                load_file_info(directory, fileinfo);
                m_fileinfos[fileinfo.get_name()] = fileinfo;
            }
            
            m_current_file = directory;
            //breadcrumbs.set_path(current_file.get_path());
        } catch (Error e) {
            debug(e.message);
        } finally {
            m_model.stop_editing();
        }
    }
    
    private void load_file_info(File p_parent, FileInfo p_fileinfo, bool p_special = false) {
        var entry = new DirectoryModel.Entry();
        
        entry.file = p_parent.get_child(p_fileinfo.get_name());
        entry.icon = load_file_icon(p_parent, p_fileinfo);
        entry.name = format_file_name(p_fileinfo);
        entry.extension = format_file_extension(p_fileinfo);
        entry.size = format_file_size(p_fileinfo);
        entry.mod_time = format_time(p_fileinfo);
        entry.special = p_special;
        
        m_model.add_entry(entry);
    }
    
    private Pixbuf load_file_icon(File p_parent, FileInfo p_fileinfo) {
        var content_type = p_fileinfo.get_content_type();
        assert(content_type != null);

        Pixbuf icon_pixbuf = null;

        if (m_icon_cache.has_key(content_type)) {
            icon_pixbuf = m_icon_cache[content_type];
        } else {
            try {
                var icon = (ThemedIcon) p_fileinfo.get_icon();
                var icon_names = icon.get_names();
                
                var icon_info = m_default_icon_theme.choose_icon(icon_names, 16, 0);
                if (icon_info != null) {
                    icon_pixbuf = icon_info.load_icon();
                }
            } catch (Error e) {
                error(e.message);
            }
        }
        
        return icon_pixbuf;
    }
    
    private string format_file_name(FileInfo p_fileinfo) {
        var filename = p_fileinfo.get_name();
        var parts = split_extension(filename);
        return parts[0];
    }
    
    private string format_file_extension(FileInfo p_fileinfo) {
        var filename = p_fileinfo.get_name();
        var parts = split_extension(filename);
        return parts[1];
    }
    
    private string[] split_extension(string p_filename) {
        var parts = p_filename.split(".");
        
        string shortname;
        string extension;
        
        if (has_extension(p_filename)) {
            var shortname_arr = parts[0:parts.length-1];
            shortname = string.joinv(".", shortname_arr);
            extension = parts[parts.length - 1];
        } else {
            shortname = p_filename;
            extension = "";
        }
        
        return new string[] {shortname, extension};
    }
    
    private bool has_extension(string p_filename) {
        var parts = p_filename.split(".");
        
        if (parts.length < 2) {
            return false;
        }
        
        if (parts.length == 2 && p_filename[0] == '.') { // hidden file
            return false;
        }
        
        if (parts.length >= 2 && p_filename[p_filename.length - 1] == '.') { // dot at the end? oh well...
            return false;
        }
        
        return true;
    }
    
    
    private string format_file_size(FileInfo p_fileinfo) {
        FileType file_type = p_fileinfo.get_file_type();
        if (file_type == FileType.DIRECTORY) {
            return "<DIR>";
        }
        
        int64 file_size = p_fileinfo.get_size();
        var size_formatter = new SizeFormat();
        return size_formatter.format(file_size);
    }
    
    private string format_time(FileInfo p_fileinfo) {
        TimeVal time;
        p_fileinfo.get_modification_time(out time);
        
        var formatter = new TimeFormat();
        return formatter.format(time);
    }
}

} // namespace
