using Gtk;
using Gdk;
using Gee;

namespace Ginko {

public class DirectoryView : TreeView {
    
    private static const int COL_ICON = 0;
    private static const int COL_NAME = 1;
    private static const int COL_EXT = 2;
    private static const int COL_SIZE = 3;
    private static const int COL_TIME = 4;
    private static const int COL_ATTR = 5;
    
    private static const int DEFAULT_ICON_COL_SIZE = (int) (MainWindow.DEFAULT_WIDTH / 2 * 0.025f);
    private static const int DEFAULT_NAME_COL_SIZE = (int) (MainWindow.DEFAULT_WIDTH / 2 * 0.375f);
    private static const int DEFAULT_EXT_COL_SIZE = (int) (MainWindow.DEFAULT_WIDTH / 2 * 0.1f);
    private static const int DEFAULT_SIZE_COL_SIZE = (int) (MainWindow.DEFAULT_WIDTH / 2 * 0.12f);
    private static const int DEFAULT_TIME_COL_SIZE = (int) (MainWindow.DEFAULT_WIDTH / 2 * 0.18f);
    private static const int DEFAULT_ATTR_COL_SIZE = (int) (MainWindow.DEFAULT_WIDTH / 2 * 0.2f);
    
    public signal bool key_pressed(string p_name);
    
    public signal void entry_activation_request(DirectoryModel.Entry entry);
    public signal void entry_highlight_toggle_request(TreePath path);
    
    private DirectoryModel m_model;
    private TreePath m_cursor_path_last;
    
    
    public DirectoryView(DirectoryModel p_model, PaneSettings p_settings) {
        m_model = p_model;
        set_model(m_model.m_store);
        
        var size_renderer = new CellRendererText();
        size_renderer.xalign = 1.0f;
        
        insert_column_with_attributes(-1, "", new CellRendererPixbuf(),
            "pixbuf", DirectoryModel.STORE_ICON, null);
        insert_column_with_attributes(-1, "Name", new CellRendererText(),
            "text", DirectoryModel.STORE_NAME,
            "foreground-set", DirectoryModel.STORE_HIGHLIGHTED,
            "foreground", DirectoryModel.STORE_HIGHLIGHT_COLOR,
            null);
        insert_column_with_attributes(-1, "Ext", new CellRendererText(),
            "text", DirectoryModel.STORE_EXT,
            "foreground-set", DirectoryModel.STORE_HIGHLIGHTED,
            "foreground", DirectoryModel.STORE_HIGHLIGHT_COLOR,
            null);
        
        insert_column_with_attributes(-1, "Size", size_renderer,
            "text", DirectoryModel.STORE_SIZE,
            "foreground-set", DirectoryModel.STORE_HIGHLIGHTED,
            "foreground", DirectoryModel.STORE_HIGHLIGHT_COLOR,
            null);
        insert_column_with_attributes(-1, "Date", new CellRendererText(), "text",
            DirectoryModel.STORE_MOD_TIME,
            "foreground-set", DirectoryModel.STORE_HIGHLIGHTED,
            "foreground", DirectoryModel.STORE_HIGHLIGHT_COLOR,
            null);
        insert_column_with_attributes(-1, "Attr", new CellRendererText(), "text",
            DirectoryModel.STORE_ATTR,
            "foreground-set", DirectoryModel.STORE_HIGHLIGHTED,
            "foreground", DirectoryModel.STORE_HIGHLIGHT_COLOR,
            null);

        for (var i = 1; i <= 5; ++i) {
            unowned TreeViewColumn column = get_column(i);
            column.set_sizing(TreeViewColumnSizing.FIXED);
            column.set_resizable(true);
        }
        
        // set column sizes
        configure_column_sizes(COL_ICON, DEFAULT_ICON_COL_SIZE,
            p_settings.get_icon_column_size, p_settings.set_icon_column_size);
        configure_column_sizes(COL_NAME, DEFAULT_NAME_COL_SIZE,
            p_settings.get_name_column_size, p_settings.set_name_column_size);
        configure_column_sizes(COL_EXT, DEFAULT_EXT_COL_SIZE,
            p_settings.get_ext_column_size, p_settings.set_ext_column_size);
        configure_column_sizes(COL_SIZE, DEFAULT_SIZE_COL_SIZE,
            p_settings.get_size_column_size, p_settings.set_size_column_size);
        configure_column_sizes(COL_TIME, DEFAULT_TIME_COL_SIZE,
            p_settings.get_time_column_size, p_settings.set_time_column_size);
        configure_column_sizes(COL_ATTR, DEFAULT_ATTR_COL_SIZE,
            p_settings.get_attr_column_size, p_settings.set_attr_column_size);
        
        
        set_search_column(DirectoryModel.STORE_NAME);
        
        row_activated.connect(on_row_activated);
        key_press_event.connect(on_key_press);
        cursor_changed.connect(() => {
            get_cursor(out m_cursor_path_last, null);
        });
    }
    
    private delegate int GetSizeFunc(int p_default);
    private delegate void SetSizeFunc(int p_size);
    
    private void configure_column_sizes(int p_column_id, int p_default_size,
        GetSizeFunc p_get_func, SetSizeFunc p_set_func) {
        
        var column = get_column(p_column_id);
        var width = p_get_func(p_default_size);
        column.set_fixed_width(width);
        column.notify["width"].connect(() => {
                var nwidth = column.get_width();
                p_set_func(nwidth);
        });
    }
    
    private void on_row_activated(TreePath p_path, TreeViewColumn p_column) {
        var entry = m_model.path_to_entry(p_path);
        entry_activation_request(entry);
    }
    
    private bool on_key_press(EventKey p_event) {
        string key = Gdk.keyval_name(p_event.keyval);
        
        switch (key) {
            case "Return":
                on_return_pressed();
                return true;
            case "Insert":
                var path = get_selected_tree_path();
                if (path != null) {
                    entry_highlight_toggle_request(path);
                }
                return true;
            default:
                return key_pressed(key);
        }
    }
    
    private void on_return_pressed() {
        var entry = get_selected_entry();
        entry_activation_request(entry);
    }
    
    /** @return Highlighted Entry or null if nothing is highlighted here. */
    public DirectoryModel.Entry get_selected_entry() {
        var path = get_selected_tree_path();
        
        if (path == null) {
            return null;
        }
        
        return m_model.path_to_entry(path);
    }
    
    private TreePath get_selected_tree_path() {
        TreeSelection selection = get_selection();
        
        var store = get_model();
        GLib.List<TreePath> selected_rows = selection.get_selected_rows(out store);
        return selected_rows.nth_data(0);
    }
    
    public void set_cursor_at_top() {
        var model = get_model();
        
        TreeIter first;
        model.get_iter_first(out first);
        
        var path = model.get_path(first);
        set_cursor(path, null, false);
    }
    
    public bool move_cursor_down() {
        var path = get_selected_tree_path();
        TreeIter iter;
        model.get_iter(out iter, path);
        
        if (model.iter_next(ref iter)) {
            var npath = model.get_path(iter);
            set_cursor(npath, null, false);
            return true;
        } else {
            hide_cursor();
            return false;
        }
    }
    
    public void show_cursor() {
        if (m_cursor_path_last != null) {
            set_cursor(m_cursor_path_last, null, false);
        } else {
            set_cursor_at_top();
        }
    }
    
    public void hide_cursor() {
        get_cursor(out m_cursor_path_last, null);
        
        var selection = get_selection();
        selection.unselect_all();
    }
    
}

} // namespace
