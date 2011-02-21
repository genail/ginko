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

    public DirectoryView view { get; private set; }
    public DirectoryModel model { get; private set; }
    
    private BreadCrumbs breadcrumbs;
    
    public File current_file { get; private set; }
    
    private IconTheme default_icon_theme = IconTheme.get_default();
    private HashMap<string, Pixbuf> icon_cache = new HashMap<string, Pixbuf>();
    
    // current entry name to file info
    private HashMap<string, FileInfo> fileinfos = new HashMap<string, FileInfo>();
        
    public DirectoryController() {
        this.model = new DirectoryModel();
        this.view = new DirectoryView(model);
        this.breadcrumbs = new BreadCrumbs();

        view.button_press_event.connect(on_button_press);
        view.entry_activated.connect(on_entry_activated);
        view.navigate_up_requested.connect(on_navigate_up_request);
        
        load_path(".");
    }
    
    public void make_active() {
        view.show_cursor();
        view.grab_focus();
    }
    
    public void make_unactive() {
        view.hide_cursor();
    }
    
    public GLib.List<File> get_selected_files() {
        var entry = view.get_highlighted_entry();
        
        var list = new GLib.List<File>();
        
        if (entry != null) {
            list.append(entry.file);
        }
        
        return list;
    }
    
    public void refresh() {
        load_path(current_file.get_path());
        view.show_cursor(); // because after path loading it's hidden
    }
    
    private bool on_button_press(EventButton e) {
        if (e.type == EventType.2BUTTON_PRESS) {
            return true;
        }
        
        return false;
    }
    
    private void on_entry_activated(DirectoryModel.Entry entry) {
        try {
            var child = entry.file;
            
            if (child.query_exists()) {
                var info = child.query_info(FILE_ATTRIBUTE_STANDARD_TYPE, 0);
                var type = info.get_file_type();
                
                if (type == FileType.DIRECTORY) {
                    load_path(child.get_path());
                    view.cursor_set_at_top();
                } else {
                    execute_app_on_file(child);
                }
            }
        } catch (Error e) {
            error(e.message);
        }
    }
    
    private void execute_app_on_file(File file) {
        try {
            AppInfo app_info = file.query_default_handler(null);
            var file_list = new GLib.List<File>();
            file_list.append(file);
            app_info.launch(file_list, null);
        } catch (Error e) {
            debug(e.message);
        }
    }
    
    private void on_navigate_up_request() {
        if (current_file.has_parent(null)) {
            var parent = current_file.get_parent();
            var parent_path = parent.get_path();
            load_path(parent_path);
            
            view.cursor_set_at_top();
        }
    }
    
    private void load_path(string path) {
        model.start_editing();
        model.clear();
        try {
            fileinfos.clear();
            FileInfo fileinfo;
        
            var directory = File.new_for_path(path);
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
                fileinfos[fileinfo.get_name()] = fileinfo;
            }
            
            current_file = directory;
            breadcrumbs.set_path(current_file.get_path());
        } catch (Error e) {
            debug(e.message);
        } finally {
            model.stop_editing();
        }
    }
    
    private void load_file_info(File parent, FileInfo fileinfo, bool special=false) {
        var entry = new DirectoryModel.Entry();
        
        entry.file = parent.get_child(fileinfo.get_name());
        entry.icon = load_file_icon(parent, fileinfo);
        entry.name = format_file_name(fileinfo);
        entry.extension = format_file_extension(fileinfo);
        entry.size = format_file_size(fileinfo);
        entry.mod_time = format_time(fileinfo);
        entry.special = special;
        
        model.add_entry(entry);
    }
    
    private Pixbuf load_file_icon(File parent, FileInfo fileinfo) {
        var content_type = fileinfo.get_content_type();
        assert(content_type != null);

        Pixbuf icon_pixbuf = null;

        if (icon_cache.has_key(content_type)) {
            icon_pixbuf = icon_cache[content_type];
        } else {
            try {
                var icon = (ThemedIcon) fileinfo.get_icon();
                var icon_names = icon.get_names();
                
                var icon_info = default_icon_theme.choose_icon(icon_names, 16, 0);
                if (icon_info != null) {
                    icon_pixbuf = icon_info.load_icon();
                }
            } catch (Error e) {
                error(e.message);
            }
        }
        
        return icon_pixbuf;
    }
    
    private string format_file_name(FileInfo fileinfo) {
        var filename = fileinfo.get_name();
        var parts = split_extension(filename);
        return parts[0];
    }
    
    private string format_file_extension(FileInfo fileinfo) {
        var filename = fileinfo.get_name();
        var parts = split_extension(filename);
        return parts[1];
    }
    
    private string[] split_extension(string filename) {
        var parts = filename.split(".");
        
        string shortname;
        string extension;
        
        if (has_extension(filename)) {
            var shortname_arr = parts[0:parts.length-1];
            shortname = string.joinv(".", shortname_arr);
            extension = parts[parts.length - 1];
        } else {
            shortname = filename;
            extension = "";
        }
        
        return new string[] {shortname, extension};
    }
    
    private bool has_extension(string filename) {
        var parts = filename.split(".");
        
        if (parts.length < 2) {
            return false;
        }
        
        if (parts.length == 2 && filename[0] == '.') { // hidden file
            return false;
        }
        
        if (parts.length >= 2 && filename[filename.length - 1] == '.') { // dot at the end? oh well...
            return false;
        }
        
        return true;
    }
    
    
    private string format_file_size(FileInfo fileinfo) {
        FileType file_type = fileinfo.get_file_type();
        if (file_type == FileType.DIRECTORY) {
            return "<DIR>";
        }
        
        int64 file_size = fileinfo.get_size();
        var size_formatter = new SizeFormat();
        return size_formatter.format(file_size);
    }
    
    private string format_time(FileInfo fileinfo) {
        TimeVal time;
        fileinfo.get_modification_time(out time);
        
        var formatter = new TimeFormat();
        return formatter.format(time);
    }
}

} // namespace
