using Gdk;
using Gtk;

class DirectoryController : Gtk.Widget {
    private const string DEFAULT_FILE_QUERY_ATTR =
                FILE_ATTRIBUTE_STANDARD_TYPE + "," +
                FILE_ATTRIBUTE_STANDARD_NAME + "," +
                FILE_ATTRIBUTE_STANDARD_SIZE + "," +
                FILE_ATTRIBUTE_TIME_MODIFIED + "," +
                FILE_ATTRIBUTE_UNIX_MODE;

    private DirectoryView view;
    private string current_path;

    public DirectoryController(DirectoryView view) {
        this.view = view;

        view.button_press_event.connect(on_button_press);
        
        view.entry_activated.connect(on_entry_activated);
        
        load_path(".");
    }
    
    private bool on_button_press(EventButton e) {
        if (e.type == EventType.2BUTTON_PRESS) {
            return true;
        }
        
        return false;
    }
    
    private void on_entry_activated(DirectoryView.Entry entry) {
        try{
            var file = File.new_for_path(current_path + "/" + entry.name);
            
            if (file.query_exists()) {
                var info = file.query_info(FILE_ATTRIBUTE_STANDARD_TYPE, 0);
                var type = info.get_file_type();
                
                if (type == FileType.DIRECTORY) {
                    load_path(file.get_path());
                }
            }
        } catch (Error e) {
            error(e.message);
        }
    }
    
    private void load_path(string path) {
        view.clear();
        
        try {
            FileInfo fileinfo;
        
            var directory = File.new_for_path(path);
            if (directory.has_parent(null)) {
                // put ".." entry at top
                var parent = directory.get_parent();
                
                fileinfo = File.new_for_path(parent.get_path()).query_info(
                    DEFAULT_FILE_QUERY_ATTR, 0);
                    
                fileinfo.set_name("..");
                load_file_info(directory, fileinfo);
            }
            
            var fullpath = directory.get_path();
            
            var enumerator = directory.enumerate_children(DEFAULT_FILE_QUERY_ATTR, 0);
            while ((fileinfo = enumerator.next_file()) != null) {
                load_file_info(directory, fileinfo);
            }
            
            current_path = fullpath;
            stdout.printf("%s\n", current_path);
        } catch (Error e) {
            error(e.message);
        }
    }
    
    private void load_file_info(File parent, FileInfo fileinfo) {
        var entry = new DirectoryView.Entry();
        
        
        entry.icon = load_file_icon(parent, fileinfo);
        entry.name = format_file_name(fileinfo);
        entry.extension = format_file_extension(fileinfo);
        entry.size = format_file_size(fileinfo);
        entry.mod_time = format_time(fileinfo);
        
        view.add_entry(entry);
    }
    
    private Pixbuf load_file_icon(File parent, FileInfo fileinfo) {
        string uri = parent.get_path() + "/" + fileinfo.get_name();
        unowned string mime_type = GnomeVFS.get_mime_type(uri);
        
        var icon_theme = IconTheme.get_default();
        GnomeVFS.FileInfo gvfs_file_info = new GnomeVFS.FileInfo();
        GnomeVFS.get_file_info(uri, gvfs_file_info, 0);
        var thumbnail_factory = new Gnome.ThumbnailFactory(Gnome.ThumbnailSize.NORMAL);
        unowned string icon_name = Gnome.icon_lookup(
        icon_theme, thumbnail_factory, uri, "", gvfs_file_info, mime_type, 0, 0);
        
        try {
            bool has_icon = icon_theme.has_icon(icon_name);
            if (has_icon) {
                var icon_pixbuf = icon_theme.load_icon(icon_name, 16, 0);
                return icon_pixbuf;
            }
        } catch (Error e) {
            error(e.message);
        }
        
        return (Gdk.Pixbuf) null;
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
            debug(filename[filename.length - 1].to_string());
            return false;
        }
        
        return true;
    }
    
    
    private string format_file_size(FileInfo fileinfo) {
        int64 file_size = fileinfo.get_size();
        
        FileType file_type = fileinfo.get_file_type();
        if (file_type == FileType.DIRECTORY) {
            return "<DIR>";
        }

        if (file_size == 0) {
            return "0";
        }

        string result = "";
        
        while (file_size > 0) {
            int64 rest = file_size % 1000;
            
            if (result.length != 0) {
                result = " " + result;
            }
            
            result = rest.to_string() + result;
            file_size /= 1000;
        }
        
        return result;
    }
    
    private string format_time(FileInfo fileinfo) {
        TimeVal time;
        fileinfo.get_modification_time(out time);
        return time.tv_sec.to_string();
    }
}
