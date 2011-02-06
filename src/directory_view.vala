using Gtk;

class DirectoryView : TreeView {

    public struct Entry {
        public Gdk.Pixbuf icon;
        public string name;
        public string extension;
        public string size;
        public string mod_time;
        public string attr;
    }
    
    private ListStore store;
    
    public DirectoryView() {
        store = new ListStore(6, typeof(Gdk.Pixbuf), typeof(string), typeof(string), typeof(string), typeof(string), typeof(string));
        
        set_model(store);
        
        insert_column_with_attributes(-1, "Icon", new CellRendererPixbuf(), "pixbuf", 0, null);
        insert_column_with_attributes(-1, "Name", new CellRendererText(), "text", 1, null);
        insert_column_with_attributes(-1, "Ext", new CellRendererText(), "text", 2, null);
        insert_column_with_attributes(-1, "Size", new CellRendererText(), "text", 3, null);
        insert_column_with_attributes(-1, "Date", new CellRendererText(), "text", 4, null);
        insert_column_with_attributes(-1, "Attr", new CellRendererText(), "text", 5, null);
    }
    
    public void clear() {
        store.clear();
    }
    
    public void add_entry(Entry entry) {
        TreeIter iter;
        store.append(out iter);
        store.set(iter, 0, entry.icon, -1);
        store.set(iter, 1, entry.name, -1);
        store.set(iter, 2, entry.extension, -1);
        store.set(iter, 3, entry.size, -1);
        store.set(iter, 4, entry.mod_time, -1);
        store.set(iter, 5, entry.attr, -1);

        expand_all();
    }
    
//~     /* Mouse button got pressed over widget */
//~     public override bool button_press_event (Gdk.EventButton event) {
//~         stdout.printf("a\n");
//~         // ...
//~         return false;
//~     }
}
