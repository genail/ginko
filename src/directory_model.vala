using Gtk;
using Gee;

namespace Ginko {

class DirectoryModel  {
    public static const int STORE_FULLNAME = 0;
    public static const int STORE_ICON = 1;
    public static const int STORE_NAME = 2;
    public static const int STORE_EXT = 3;
    public static const int STORE_SIZE = 4;
    public static const int STORE_MOD_TIME = 5;
    public static const int STORE_ATTR = 6;
    
    private static const int UNSORTED_SORT_COLUMN_ID = -2;
    
    public class Entry {
        public Gdk.Pixbuf icon;
        public string fullname;
        public string name;
        public string extension;
        public string size;
        public string mod_time;
        public string attr;
    }
    
    public ListStore store { get; private set; }
    
    // entry fullname => Entry
    private HashMap<string, Entry> name_entry_map = new HashMap<string, Entry>();
    private bool editing = false;
    
    public DirectoryModel() {
        store = new ListStore(7,
            typeof(string), // entry fullname
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
        assert(entry.fullname != null);
        assert(entry.name != null);
        
        name_entry_map[entry.fullname] = entry;
    
        TreeIter iter;
        store.append(out iter);
        store.set(iter,
            STORE_FULLNAME, entry.fullname,
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
        name_entry_map.clear();
    }
    
    public Entry path_to_entry(TreePath path) {
        var iter = path_to_iter(path);
        string entry_fullname = get_entry_fullname(iter);
        
        return name_entry_map[entry_fullname];
    }
    
    private string get_entry_fullname(TreeIter iter) {
        Value fullname;
        store.get_value(iter, DirectoryModel.STORE_FULLNAME, out fullname);
        return (string) fullname;
    }
    
    private TreeIter path_to_iter(TreePath path) {
        TreeIter iter;
        store.get_iter(out iter, path);
        return iter;
    }
    
    private int file_name_compare(TreeModel model, TreeIter a, TreeIter b) {
        string entry_name_a = get_entry_fullname(a);
        string entry_name_b = get_entry_fullname(b);
        
        return entry_name_a.ascii_casecmp(entry_name_b);
    }
}
    
} // namespace
