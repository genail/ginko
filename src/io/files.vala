using Gtk;
using Gdk;

namespace Ginko.IO {
    
public class Files {
    public static Pixbuf find_icon_for_file(File file, IconTheme theme, int size=64) throws Error {
        var info = file.query_info(FILE_ATTRIBUTE_STANDARD_ICON, 0, null);
        
        var icon = (ThemedIcon) info.get_icon();
        var icon_names = icon.get_names();
        
        var icon_info = theme.choose_icon(icon_names, size, 0);
        if (icon_info != null) {
            return icon_info.load_icon();
        }
        
        return null;
    }
    
    public static string query_content_type(File file) {
        var info = file.query_info(FILE_ATTRIBUTE_STANDARD_CONTENT_TYPE, 0, null);
        return info.get_content_type();
    }
    
    public static uint64 query_size(File file) {
        var info = file.query_info(FILE_ATTRIBUTE_STANDARD_SIZE, 0, null);
        return info.get_size();
    }
    
    public static TimeVal query_modification_time(File file) {
        TimeVal time;
        
        var info = file.query_info(FILE_ATTRIBUTE_TIME_MODIFIED, 0, null);
        info.get_modification_time(out time);
        
        return time;
    }
}

} // namespace
