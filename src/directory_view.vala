using Gtk;
using Gdk;
using Gee;

namespace Ginko {

public class DirectoryView : TreeView {
    
    public signal void entry_activated(DirectoryModel.Entry entry);
    public signal void navigate_up_requested();
    
    private DirectoryModel m_model;
    private TreePath m_cursor_path_last;
    
    
    public DirectoryView(DirectoryModel p_model) {
        m_model = p_model;
        set_model(m_model.m_store);
        
        var size_renderer = new CellRendererText();
        size_renderer.xalign = 1.0f;
        
        insert_column_with_attributes(-1, "", new CellRendererPixbuf(),
            "pixbuf", DirectoryModel.STORE_ICON, null);
        insert_column_with_attributes(-1, "Name", new CellRendererText(),
            "text", DirectoryModel.STORE_NAME, null);
        insert_column_with_attributes(-1, "Ext", new CellRendererText(),
            "text", DirectoryModel.STORE_EXT, null);
        
        insert_column_with_attributes(-1, "Size", size_renderer,
            "text", DirectoryModel.STORE_SIZE, null);
        insert_column_with_attributes(-1, "Date", new CellRendererText(), "text",
            DirectoryModel.STORE_MOD_TIME, null);
        insert_column_with_attributes(-1, "Attr", new CellRendererText(), "text",
            DirectoryModel.STORE_ATTR, null);

        for (var i = 1; i <= 5; ++i) {
            unowned TreeViewColumn column = get_column(i);
            column.set_sizing(TreeViewColumnSizing.AUTOSIZE);
            column.set_resizable(true);
//~             column.set_min_width(50);
        }
        
        row_activated.connect(on_row_activated);
        key_press_event.connect(on_key_press);
        cursor_changed.connect(() => {
            get_cursor(out m_cursor_path_last, null);
        });
        
    }
    
    private void on_row_activated(TreePath p_path, TreeViewColumn p_column) {
        var entry = m_model.path_to_entry(p_path);
        entry_activated(entry);
    }
    
    private bool on_key_press(EventKey p_event) {
        string key = Gdk.keyval_name(p_event.keyval);
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
        var entry = get_highlighted_entry();
        entry_activated(entry);
    }
    
    private void on_backspace_pressed() {
        navigate_up_requested();
    }
    
    /** @return Highlighted Entry or null if nothing is highlighted here. */
    public DirectoryModel.Entry get_highlighted_entry() {
        TreeSelection selection = get_selection();
        
        var store = get_model();
        GLib.List<TreePath> selected_rows = selection.get_selected_rows(out store);
        TreePath path = selected_rows.nth_data(0);
        
        if (path == null) {
            return null;
        }
        
        return m_model.path_to_entry(path);
    }
    
    public void cursor_set_at_top() {
        var model = get_model();
        
        TreeIter first;
        model.get_iter_first(out first);
        
        var path = model.get_path(first);
        set_cursor(path, null, false);
    }
    
    public void show_cursor() {
        if (m_cursor_path_last != null) {
            set_cursor(m_cursor_path_last, null, false);
        } else {
            cursor_set_at_top();
        }
    }
    
    public void hide_cursor() {
        get_cursor(out m_cursor_path_last, null);
        
        var selection = get_selection();
        selection.unselect_all();
    }
    
}

} // namespace
