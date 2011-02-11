using Gtk;

class ActionProgressDialog : Dialog {
    private Label status_label;
    
    private Adjustment progress_bar_adjustment;
    private ProgressBar progress_bar;
    
    public ActionProgressDialog() {
        var box = new VBox(false, 0);
        (get_content_area() as Container).add(box);
        
        status_label = new Label("set me using set_status_text()");
        
        progress_bar_adjustment = new Adjustment(0.0, 0.0, 1.0, 0.1, 1.0, 0.1);
        
        progress_bar = new ProgressBar();
        progress_bar.set_text("set me using set_progress_bar()");
        progress_bar.adjustment = progress_bar_adjustment;
        
        vbox.pack_start(status_label);
        vbox.pack_start(progress_bar);
        
        show_all();
    }

    public void log_details(string message) {
    
    }
    
    public void set_progress(double val, string progress_text) {
        progress_bar_adjustment.set_value(val);
        progress_bar.set_text(progress_text);
    }
    
    public void set_status_text(string status_text) {
        
    }
}
