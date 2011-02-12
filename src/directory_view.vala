using Gtk;
using Gdk;
using Gee;

namespace Ginko {

class DirectoryView : TreeView {

    public class Entry {
        public Gdk.Pixbuf icon;
        public string fullname;
        public string name;
        public string extension;
        public string size;
        public string mod_time;
        public string attr;
    }
    
    public signal void entry_activated(Entry entry);
    public signal void navigate_up_requested();
    
    private static const int UNSORTED_SORT_COLUMN_ID = -2;
    
    private static const int STORE_FULLNAME = 0;
    private static const int STORE_ICON = 1;
    private static const int STORE_NAME = 2;
    private static const int STORE_EXT = 3;
    private static const int STORE_SIZE = 4;
    private static const int STORE_MOD_TIME = 5;
    private static const int STORE_ATTR = 6;
    
    private ListStore store;
    // entry fullname => Entry
    private HashMap<string, Entry> name_entry_map = new HashMap<string, Entry>();
    private TreePath cursor_path_last;
    private bool cursor_hidden = false;
    
    private bool editing = false;
    
    
    
    
    public DirectoryView() {
        store = new ListStore(7,
            typeof(string), // entry fullname
            typeof(Gdk.Pixbuf),
            typeof(string),
            typeof(string),
            typeof(string),
            typeof(string),
            typeof(string));
        
        set_model(store);
        
        insert_column_with_attributes(-1, "", new CellRendererPixbuf(), "pixbuf", STORE_ICON, null);
        insert_column_with_attributes(-1, "Name", new CellRendererText(), "text", STORE_NAME, null);
        insert_column_with_attributes(-1, "Ext", new CellRendererText(), "text", STORE_EXT, null);
        
        var size_renderer = new CellRendererText();
        size_renderer.xalign = 1.0f;
        
        insert_column_with_attributes(-1, "Size", size_renderer, "text", STORE_SIZE, null);
        insert_column_with_attributes(-1, "Date", new CellRendererText(), "text", STORE_MOD_TIME, null);
        insert_column_with_attributes(-1, "Attr", new CellRendererText(), "text", STORE_ATTR, null);

        for (var i = 1; i <= 5; ++i) {
            unowned TreeViewColumn column = get_column(i);
            column.set_sizing(TreeViewColumnSizing.AUTOSIZE);
            column.set_resizable(true);
//~             column.set_min_width(50);
        }
        
        row_activated.connect(on_row_activated);
        key_press_event.connect(on_key_press);
        cursor_changed.connect(() => {
            get_cursor(out cursor_path_last, null);
        });
        
        // default sorting
        TreeSortable sortable = (TreeSortable) store;
        sortable.set_sort_func(1, file_name_compare);
        
    }
    
    private int file_name_compare(TreeModel model, TreeIter a, TreeIter b) {
        string entry_name_a = get_entry_fullname(a);
        string entry_name_b = get_entry_fullname(b);
        
        return entry_name_a.ascii_casecmp(entry_name_b);
    }
    
    private void on_row_activated(TreePath path, TreeViewColumn column) {
        var entry = path_to_entry(path);
        entry_activated(entry);
    }
    
    private bool on_key_press(EventKey e) {
        string key = Gdk.keyval_name(e.keyval);
//~         debug("%s\n", key);
    
        switch (key) {
            case "Return":
                on_return_pressed();
                return true;
            case "BackSpace":
                on_backspace_pressed();
                return true;
            default:
                return false;
        }
    }
    
    private void on_return_pressed() {
        var entry = get_current_entry();
        entry_activated(entry);
    }
    
    private void on_backspace_pressed() {
        navigate_up_requested();
    }
    
    private Entry get_current_entry() {
        TreeSelection selection = get_selection();
        
        var model = get_model();
        GLib.List<TreePath> selected_rows = selection.get_selected_rows(out model);
        TreePath path = selected_rows.nth_data(0);
        
        return path_to_entry(path);
    }
    
    private Entry path_to_entry(TreePath path) {
        var iter = path_to_iter(path);
        string entry_fullname = get_entry_fullname(iter);
        
        return name_entry_map[entry_fullname];
    }
    
    private TreeIter path_to_iter(TreePath path) {
        TreeIter iter;
        model.get_iter(out iter, path);
        return iter;
    }
    
    private string get_entry_fullname(TreeIter iter) {
        Value fullname;
        model.get_value(iter, STORE_FULLNAME, out fullname);
        return (string) fullname;
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
    
    public void clear() {
        assert(editing);
        store.clear();
        name_entry_map.clear();
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
    
    public void cursor_set_at_top() {
        var model = get_model();
        
        TreeIter first;
        model.get_iter_first(out first);
        
        var path = model.get_path(first);
        set_cursor(path, null, false);
    }
    
    public void cursor_show() {
        if (cursor_hidden) {
            set_cursor(cursor_path_last, null, false);
            cursor_hidden = false;
        } else if (cursor_path_last == null) {
            cursor_set_at_top();
        }
    }
    
    public void cursor_hide() {
        if (!cursor_hidden) {
        
            get_cursor(out cursor_path_last, null);
            
            var selection = get_selection();
            selection.unselect_all();
            
            cursor_hidden = true;
        }
    }
}

} // namespace
