using Gtk;

namespace Ginko.Dialogs {

public abstract class AbstractDialog : Dialog {
    
    private Image image_widget;
    private Label primary_label;
    public VBox content {get; private set;}
    private HBox hbox;
    
    public AbstractDialog() {
        set_resizable(false);
        set_skip_taskbar_hint(true);
        
        image_widget = new Image.from_stock(Stock.DIALOG_QUESTION, IconSize.DIALOG);
        image_widget.set_alignment(0.5f, 0);
        
        primary_label = new Label("");
        primary_label.set_selectable(true);
        primary_label.set_alignment(0, 0);
        set_primary_label_text("set by set_primary_label_text()");
        
        hbox = new HBox(false, 12);
        this.vbox.pack_start(hbox);
        
        hbox.pack_start(image_widget);
        
        content = new VBox(false, 12);
        hbox.pack_end(content);
        
        content.pack_start(primary_label);
        
        
        // sizes from GtkMessageDialog
        set_border_width(5);
        hbox.set_border_width(5);
        this.vbox.set_spacing(14);
        (get_action_area() as Container).set_border_width(5);
        (get_action_area() as Box).set_spacing(6);
        
        show_all();
    }
    
    public void set_primary_label_text(string text) {
        primary_label.set_markup(@"<big>$text</big>");
    }
    
    public void set_stock_icon(string stock_icon) {
        hbox.remove(image_widget);
        image_widget = new Image.from_stock(stock_icon, IconSize.DIALOG);
        hbox.pack_start(image_widget);
    }
}

}
