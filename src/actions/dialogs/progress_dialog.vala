using Gtk;

namespace Ginko.Dialogs {

public class ProgressDialog : Dialog {
    public static const int RESPONSE_PAUSE = 1;
    
    private static const int DIALOG_WIDTH = 300;
    private static const string MORE_LABEL = "More ↓";
    private static const string LESS_LABEL = "Less ↑";

    private Label status_label;
    
    private Adjustment progress_bar_adjustment;
    private ProgressBar progress_bar;
    
    private Button details_button;
    private Frame details_frame;
    
    private TreeView details_tree_view;
    private ListStore details_tree_view_store;
    
    private bool details_visible = true;
    
    public ProgressDialog() {
        build_ui();
    }

    public void log_details(string message) {
        TreeIter iter;
        details_tree_view_store.append(out iter);
        details_tree_view_store.set(iter, 0, message, -1);
    }
    
    public void set_progress(double val, string progress_text) {
        progress_bar_adjustment.set_value(val);
        progress_bar.set_text(progress_text);
    }
    
    public void set_status_text(string status_text) {
        status_label.set_text(status_text);
    }
    
    private void build_ui() {
        set_title("set me using set_title()");
        set_size_request(DIALOG_WIDTH, -1);

        build_ui_buttons();
        build_ui_statuses();
        build_ui_details();
        
        vbox.pack_start(status_label, false, false);
        vbox.pack_start(progress_bar, false, false);
        vbox.pack_start(details_frame, true, true);
        
        show_all();
        toggle_details();
    }
    
    private void build_ui_buttons() {
        var button_box = get_action_area() as HButtonBox;
        
        details_button = new Button.with_label(MORE_LABEL);
        details_button.clicked.connect(toggle_details);
        
        button_box.pack_start(details_button);
        add_buttons("Pause", RESPONSE_PAUSE, Stock.CANCEL, ResponseType.CANCEL, 0);
    }
    
    private void build_ui_statuses() {
        
        status_label = new Label("set me using set_status_text()");
        status_label.set_alignment(0, 0);
        
        progress_bar_adjustment = new Adjustment(0.0, 0.0, 1.0, 0.1, 1.0, 0.1);
        
        progress_bar = new ProgressBar();
        progress_bar.set_text("set me using set_progress_bar()");
        progress_bar.adjustment = progress_bar_adjustment;
    }
    
    private void build_ui_details() {
        details_frame = new Frame("Details");
        details_frame.set_size_request(-1, 150);
        
        var scrolls = new ScrolledWindow(null, null);
        details_frame.add(scrolls);
        
        
        details_tree_view = new TreeView();
        scrolls.add(details_tree_view);
        
        // model
        details_tree_view_store = new ListStore(1, typeof(string));
        details_tree_view.set_model(details_tree_view_store);
        
        details_tree_view.insert_column_with_attributes(
            -1, "List", new CellRendererText(), "text", 0, null);
    }
    
    private void toggle_details() {
        if (!details_visible) {
            details_frame.show();
            details_button.set_label(LESS_LABEL);
            details_visible = true;
        } else {
            details_frame.hide();
            details_button.set_label(MORE_LABEL);
            details_visible = false;
            resize(1, 1);
        }
    }
}

} // namespace
