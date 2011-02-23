using Gtk;
using Gee;

namespace Ginko {

public class DirectoryModel  {
    public static const int STORE_ENTRY = 0;
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
    
    public ListStore m_store { get; private set; }
    
    private bool m_editing = false;
    
    public DirectoryModel() {
        m_store = new ListStore(7,
            typeof(Entry),
            typeof(Gdk.Pixbuf),
            typeof(string),
            typeof(string),
            typeof(string),
            typeof(string),
            typeof(string));
        
        // default sorting
        TreeSortable sortable = (TreeSortable) m_store;
        sortable.set_sort_func(1, file_name_compare);
    }
    
    // (start/stop)_editing makes sure that model is safe to edit
    // practically it stops sorting to make model editing more effective
    public void start_editing() {
        TreeSortable sortable = (TreeSortable) m_store;
        sortable.set_sort_column_id(UNSORTED_SORT_COLUMN_ID, SortType.ASCENDING);
        m_editing = true;
    }
    
    public void stop_editing() {
        TreeSortable sortable = (TreeSortable) m_store;
        sortable.set_sort_column_id(1, SortType.ASCENDING);
        m_editing = false;
    }
    
    public void add_entry(Entry p_entry) {
        assert(m_editing);
        //assert(entry.icon != null); // FIXME: replace null icon with default one
        assert(p_entry.name != null);
        assert(p_entry.file != null);
    
        TreeIter iter;
        m_store.append(out iter);
        m_store.set(iter,
            STORE_ENTRY, p_entry,
            STORE_ICON, p_entry.icon,
            STORE_NAME, p_entry.name,
            STORE_EXT, p_entry.extension,
            STORE_SIZE, p_entry.size,
            STORE_MOD_TIME, p_entry.mod_time,
            STORE_ATTR, p_entry.attr,
            -1);
    }
    
    public void clear() {
        assert(m_editing);
        m_store.clear();
    }
    
    public Entry path_to_entry(TreePath p_path) {
        var iter = path_to_iter(p_path);
        return iter_to_entry(iter);
    }
    
    private TreeIter path_to_iter(TreePath p_path) {
        TreeIter iter;
        m_store.get_iter(out iter, p_path);
        return iter;
    }
    
    private Entry iter_to_entry(TreeIter p_iter) {
        Value entry;
        m_store.get_value(p_iter, DirectoryModel.STORE_ENTRY, out entry);
        return (Entry) entry;
    }
    
    private int file_name_compare(TreeModel p_model, TreeIter p_a, TreeIter p_b) {
        var entry_a = iter_to_entry(p_a);
        var entry_b = iter_to_entry(p_b);
        
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
