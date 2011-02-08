using Gtk;
using Gdk;
using Gee;

class DirectoryView : TreeView {

    public class Entry {
        public Gdk.Pixbuf icon;
        public string name;
        public string extension;
        public string size;
        public string mod_time;
        public string attr;
    }
    
    public signal void entry_activated(Entry entry);
    public signal void navigate_up_requested();
    
    private ListStore store;
    private HashMap<string, Entry> name_entry_map = new HashMap<string, Entry>();
    
    public DirectoryView() {
        store = new ListStore(6,
            typeof(Gdk.Pixbuf),
            typeof(string),
            typeof(string),
            typeof(string),
            typeof(string),
            typeof(string));
        
        set_model(store);
        
        insert_column_with_attributes(-1, "", new CellRendererPixbuf(), "pixbuf", 0, null);
        insert_column_with_attributes(-1, "Name", new CellRendererText(), "text", 1, null);
        insert_column_with_attributes(-1, "Ext", new CellRendererText(), "text", 2, null);
        
        var size_renderer = new CellRendererText();
        size_renderer.xalign = 1.0f;
        
        insert_column_with_attributes(-1, "Size", size_renderer, "text", 3, null);
        insert_column_with_attributes(-1, "Date", new CellRendererText(), "text", 4, null);
        insert_column_with_attributes(-1, "Attr", new CellRendererText(), "text", 5, null);

        for (var i = 1; i <= 5; ++i) {
            unowned TreeViewColumn column = get_column(i);
            column.set_sizing(TreeViewColumnSizing.AUTOSIZE);
            column.set_resizable(true);
//~             column.set_min_width(50);
        }
        
        row_activated.connect(on_row_activated);
        key_press_event.connect(on_key_press);
        
        // FIXME: disable sorting when changing the model - it causes many unwantend sort executions
        TreeSortable sortable = (TreeSortable) store;
        sortable.set_sort_func(1, file_name_compare);
        sortable.set_sort_column_id(1, SortType.ASCENDING);
    }
    
    private int file_name_compare(TreeModel model, TreeIter a, TreeIter b) {
        string entry_name_a = get_entry_name(a);
        string entry_name_b = get_entry_name(b);
        
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
        string entry_name = get_entry_name(iter);
        
        return name_entry_map[entry_name];
    }
    
    private TreeIter path_to_iter(TreePath path) {
        TreeIter iter;
        model.get_iter(out iter, path);
        return iter;
    }
    
    private string get_entry_name(TreeIter iter) {
        Value value;
        model.get_value(iter, 1, out value);
        return (string) value;
    }
    
    public void clear() {
        store.clear();
        name_entry_map.clear();
    }
    
    public void add_entry(Entry entry) {
        assert(entry.icon != null);
        assert(entry.name != null);
        
        name_entry_map[entry.name] = entry;
    
        TreeIter iter;
        store.append(out iter);
        store.set(iter,
            0, entry.icon,
            1, entry.name,
            2, entry.extension,
            3, entry.size,
            4, entry.mod_time,
            5, entry.attr,
            -1);
    }
    
    public void select_first_row() {
        var model = get_model();
        
        TreeIter first;
        model.get_iter_first(out first);
        
        var path = model.get_path(first);
        set_cursor(path, null, false);
    }
}
