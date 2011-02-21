using Gtk;
using Gee;

namespace Ginko {

public class DirectoryModel  {
    public static const int STORE_FULLNAME = 0;
    public static const int STORE_ICON = 1;
    public static const int STORE_NAME = 2;
    public static const int STORE_EXT = 3;
    public static const int STORE_SIZE = 4;
    public static const int STORE_MOD_TIME = 5;
    public static const int STORE_ATTR = 6;
    
    private static const int UNSORTED_SORT_COLUMN_ID = -2;
    
    public class Entry : GLib.Object {
        public Gdk.Pixbuf icon;
        public File file;
        public string name;
        public string extension;
        public string size;
        public string mod_time;
        public string attr;
        
        public bool special; // special entry is visible always at top
    }
    
    public ListStore store { get; private set; }
    
    private bool editing = false;
    
    public DirectoryModel() {
        store = new ListStore(7,
            typeof(Entry),
            typeof(Gdk.Pixbuf),
            typeof(string),
            typeof(string),
            typeof(string),
            typeof(string),
            typeof(string));
        
        // default sorting
        TreeSortable sortable = (TreeSortable) store;
        sortable.set_sort_func(1, file_name_compare);
    }
    
    // (start/stop)_editing makes sure that model is safe to edit
    // practically it stops sorting to make model editing more effective
    public void start_editing() {
        TreeSortable sortable = (TreeSortable) store;
        sortable.set_sort_column_id(UNSORTED_SORT_COLUMN_ID, SortType.ASCENDING);
        editing = true;
    }
    
    public void stop_editing() {
        TreeSortable sortable = (TreeSortable) store;
        sortable.set_sort_column_id(1, SortType.ASCENDING);
        editing = false;
    }
    
    public void add_entry(Entry entry) {
        assert(editing);
        //assert(entry.icon != null); // FIXME: replace null icon with default one
        assert(entry.name != null);
        assert(entry.file != null);
    
        TreeIter iter;
        store.append(out iter);
        store.set(iter,
            STORE_FULLNAME, entry,
            STORE_ICON, entry.icon,
            STORE_NAME, entry.name,
            STORE_EXT, entry.extension,
            STORE_SIZE, entry.size,
            STORE_MOD_TIME, entry.mod_time,
            STORE_ATTR, entry.attr,
            -1);
    }
    
    public void clear() {
        assert(editing);
        store.clear();
    }
    
    public Entry path_to_entry(TreePath path) {
        var iter = path_to_iter(path);
        return iter_to_entry(iter);
    }
    
    private TreeIter path_to_iter(TreePath path) {
        TreeIter iter;
        store.get_iter(out iter, path);
        return iter;
    }
    
    private Entry iter_to_entry(TreeIter iter) {
        Value entry;
        store.get_value(iter, DirectoryModel.STORE_FULLNAME, out entry);
        return (Entry) entry;
    }
    
    private int file_name_compare(TreeModel model, TreeIter a, TreeIter b) {
        var entry_a = iter_to_entry(a);
        var entry_b = iter_to_entry(b);
        
        if (entry_a.special) {
            return -1;
        } else if (entry_b.special) {
            return 1;
        }
        
        var entry_name_a = entry_a.file.get_basename();
        var entry_name_b = entry_b.file.get_basename();
        
        return entry_name_a.ascii_casecmp(entry_name_b);
    }
}
    
} // namespace
