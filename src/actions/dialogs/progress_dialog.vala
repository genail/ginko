using Gtk;

namespace Ginko.Dialogs {

public class ProgressDialog : Dialog {
    private static const int DIALOG_WIDTH = 300;
    
    
    public enum Response {
        PAUSE = 1,
        CANCEL = ResponseType.CANCEL,
        CLOSE = ResponseType.CLOSE
    }
    
    public signal void cancel_button_pressed();

    
    private Context m_context;
    
    private Label m_status_label_1;
    private Label m_status_label_2;
    
    private Adjustment m_progress_bar_adjustment;
    private ProgressBar m_progress_bar;
    
    private Button m_pause_button;
    private Button m_cancel_button;
    private Button m_close_button;
    
    private Expander m_more_expander;
    
    private TreeView m_details_tree_view;
    private ListStore m_details_tree_view_store;
    
    private bool m_details_visible = true;
    
    
    public ProgressDialog(Context p_context) {
        m_context = p_context;
        
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
        add_button("Pause", Response.PAUSE);
        add_button(Stock.CANCEL, Response.CANCEL);
        add_button(Stock.CLOSE, Response.CLOSE);
        
        m_pause_button = (Button) get_widget_for_response(Response.PAUSE);
        
        m_cancel_button = (Button) get_widget_for_response(Response.CANCEL);
        m_cancel_button.clicked.connect(() => {
                bool cancelled = Messages.ask_yes_no(m_context, "Really cancel?",
                    "Do you really want to cancel current operation?");
                
                if (cancelled) {
                    cancel_button_pressed();
                    m_cancel_button.set_label("Cancelling...");
                    
                    m_cancel_button.set_sensitive(false);
                    m_pause_button.set_sensitive(false);
                    m_progress_bar.set_sensitive(false);
                }
        });
        
        m_close_button = (Button) get_widget_for_response(Response.CLOSE);
        m_close_button.pressed.connect(() => destroy());
        m_close_button.hide();
    }
    
    private void build_ui_statuses() {
        
        m_status_label_1 = new Label("use set_status_text_1()");
        m_status_label_1.set_alignment(0, 0);
        m_status_label_1.show();
        
        m_progress_bar_adjustment = new Adjustment(0.0, 0.0, 1.0, 0.1, 1.0, 0.1);
        
        m_progress_bar = new ProgressBar();
        m_progress_bar.adjustment = m_progress_bar_adjustment;
        m_progress_bar.show();
        
        m_status_label_2 = new Label("");
        m_status_label_2.set_alignment(1, 0);
        m_status_label_2.show();
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
        
        //m_more_expander.show();
        //scrolls.show();
        //details_frame.show();
        //m_details_tree_view.show();
        
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
        m_cancel_button.hide();
        m_close_button.show();
    }
}

} // namespace
