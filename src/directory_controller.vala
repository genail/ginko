using Gdk;
using Gtk;

class DirectoryController : Gtk.Widget {
    private DirectoryView view;
    private string current_path;

    public DirectoryController(DirectoryView view) {
        this.view = view;

        view.key_press_event.connect(on_key_press);
        
        load_path(".");
    }
    
    private bool on_key_press(EventKey e) {
    
        string key = Gdk.keyval_name(e.keyval);
        debug("%s\n", key);
    
        switch (key) {
            case "Return":
                handle_return();
                return true;
            default:
                return false;
        }
    }
    
    private void handle_return() {
        try{
            string entry_name = get_current_entry_name();
            var file = File.new_for_path(current_path + "/" + entry_name);
            
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
    
    private string get_current_entry_name() {
        TreeSelection selection = view.get_selection();
        
        var model = view.get_model();
        List<TreePath> selected_rows = selection.get_selected_rows(out model);
        TreePath rowPath = selected_rows.nth_data(0);
        
        TreeIter iter;
        model.get_iter(out iter, rowPath);
        
        Value value;
        model.get_value(iter, 1, out value);
        
        string entry_name = (string) value;
        return entry_name;
    }
    
    private void load_path(string path) {
        view.clear();
        
        try {
            var directory = File.new_for_path(path);
            var fullpath = directory.get_path();
            
            var enumerator = directory.enumerate_children(
                FILE_ATTRIBUTE_STANDARD_TYPE + "," +
                FILE_ATTRIBUTE_STANDARD_NAME + "," +
                FILE_ATTRIBUTE_STANDARD_SIZE + "," +
                FILE_ATTRIBUTE_TIME_MODIFIED + "," +
                FILE_ATTRIBUTE_UNIX_MODE,
                0);
            
            FileInfo file_info;
            file_info = File.new_for_path("..").query_info(
                FILE_ATTRIBUTE_STANDARD_TYPE + "," +
                FILE_ATTRIBUTE_STANDARD_NAME + "," +
                FILE_ATTRIBUTE_STANDARD_SIZE + "," +
                FILE_ATTRIBUTE_TIME_MODIFIED + "," +
                FILE_ATTRIBUTE_UNIX_MODE,
                0);
                
            file_info.set_name("..");
            load_file_info(directory, file_info);
            
            while ((file_info = enumerator.next_file()) != null) {
                load_file_info(directory, file_info);
            }
            
            current_path = fullpath;
            stdout.printf("%s\n", current_path);
        } catch (Error e) {
            error(e.message);
        }
    }
    
    private void load_file_info(File parent, FileInfo file_info) {
        var entry = DirectoryView.Entry();
        
        
        entry.icon = load_file_icon(parent, file_info);
        entry.name = format_file_name(file_info);
        entry.extension = format_file_extension(file_info);
        entry.size = format_file_size(file_info);
        entry.mod_time = format_time(file_info);
        
        view.add_entry(entry);
    }
    
    private Pixbuf load_file_icon(File parent, FileInfo file_info) {
        string uri = parent.get_path() + "/" + file_info.get_name();
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
    
    private string format_file_name(FileInfo file_info) {
        var filename = file_info.get_name();
        var parts = split_extension(filename);
        return parts[0];
    }
    
    private string format_file_extension(FileInfo file_info) {
        var filename = file_info.get_name();
        var parts = split_extension(filename);
        return parts[1];
    }
    
    private string[] split_extension(string filename) {
        var parts = filename.split(".");
        
        string shortname;
        string extension;
        
        if (parts.length >= 2 && parts[parts.length-1].length > 0) {
            var shortname_arr = parts[0:parts.length-1];
            shortname = string.joinv(".", shortname_arr);
            extension = parts[parts.length - 1];
        } else {
            shortname = filename;
            extension = "";
        }
        
        return new string[] {shortname, extension};
    }
    
    private string format_file_size(FileInfo file_info) {
        int64 file_size = file_info.get_size();
        
        FileType file_type = file_info.get_file_type();
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
    
    private string format_time(FileInfo file_info) {
        TimeVal time;
        file_info.get_modification_time(out time);
        return time.tv_sec.to_string();
    }
}
