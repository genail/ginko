using Gtk;

namespace Ginko.Dialogs {

public class ProgressDialog : Dialog {
    public static const int RESPONSE_PAUSE = 1;
    
    private static const int DIALOG_WIDTH = 300;

    private Label m_status_label_1;
    private Label m_status_label_2;
    
    private Adjustment m_progress_bar_adjustment;
    private ProgressBar m_progress_bar;
    
    private Button m_cancel_button;
    private Expander m_more_expander;
    
    private TreeView m_details_tree_view;
    private ListStore m_details_tree_view_store;
    
    private bool m_details_visible = true;
    
    public ProgressDialog() {
        build_ui();
        set_position(WindowPosition.NONE);
        
        // sizes from GtkMessageDialog
        set_border_width(5);
        vbox.set_spacing(5);
        (get_action_area() as Container).set_border_width(5);
        (get_action_area() as Box).set_spacing(6);
    }
    
    private void build_ui() {
        set_title("set me using set_title()");
        set_size_request(DIALOG_WIDTH, -1);

        build_ui_buttons();
        build_ui_statuses();
        build_ui_details();
        
        vbox.pack_start(m_status_label_1, false, false);
        vbox.pack_start(m_progress_bar, false, false);
        vbox.pack_start(m_status_label_2, false, false);
        vbox.pack_start(m_more_expander, true, true);
    }
    
    private void build_ui_buttons() {
        var button_box = get_action_area() as HButtonBox;
        
        //details_button = new Button.with_label(MORE_LABEL);
        //details_button.clicked.connect(toggle_details);
        
        //button_box.pack_start(details_button);
        add_buttons("Pause", RESPONSE_PAUSE, Stock.CANCEL, ResponseType.CANCEL, 0);
        
        m_cancel_button = get_widget_for_response(ResponseType.CANCEL) as Button;
    }
    
    private void build_ui_statuses() {
        
        m_status_label_1 = new Label("use set_status_text_1()");
        m_status_label_1.set_alignment(0, 0);
        
        m_progress_bar_adjustment = new Adjustment(0.0, 0.0, 1.0, 0.1, 1.0, 0.1);
        
        m_progress_bar = new ProgressBar();
        m_progress_bar.adjustment = m_progress_bar_adjustment;
        
        m_status_label_2 = new Label("");
        m_status_label_2.set_alignment(1, 0);
    }
    
    private void build_ui_details() {
        m_more_expander = new Expander.with_mnemonic("M_ore");
        
        var details_frame = new Frame("Details");
        details_frame.set_size_request(-1, 150);
        
        var scrolls = new ScrolledWindow(null, null);
        
        m_details_tree_view = new TreeView();
        
        scrolls.add(m_details_tree_view);
        details_frame.add(scrolls);
        m_more_expander.add(details_frame);
        
        // model
        m_details_tree_view_store = new ListStore(1, typeof(string));
        m_details_tree_view.set_model(m_details_tree_view_store);
        
        m_details_tree_view.insert_column_with_attributes(
            -1, "List", new CellRendererText(), "text", 0, null);
    }

    public void log_details(string p_message) {
        TreeIter iter;
        m_details_tree_view_store.append(out iter);
        m_details_tree_view_store.set(iter, 0, p_message, -1);
    }
    
    public void set_progress(double p_val) {
        m_progress_bar_adjustment.set_value(p_val);
    }
    
    public void set_status_text_1(string p_status_text) {
        m_status_label_1.set_text(p_status_text);
    }
    
    public void set_status_text_2(string p_status_text) {
        m_status_label_2.set_text(p_status_text);
    }
    
    public void set_done() {
        m_cancel_button.set_label("Close");
    }
}

} // namespace
