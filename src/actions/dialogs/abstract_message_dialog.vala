using Gtk;

namespace Ginko.Dialogs {

public abstract class AbstractMessageDialog : Dialog {
    
    private Image m_image_widget;
    private Label m_primary_label;
    public VBox m_content {get; private set;}
    private HBox m_hbox;
    
    public AbstractMessageDialog() {
        set_resizable(false);
        set_skip_taskbar_hint(true);
        
        m_image_widget = new Image.from_stock(Stock.DIALOG_QUESTION, IconSize.DIALOG);
        m_image_widget.set_alignment(0.5f, 0);
        
        m_primary_label = new Label("");
        m_primary_label.set_selectable(true);
        m_primary_label.set_alignment(0, 0);
        set_primary_label_text("set by set_primary_label_text()");
        
        m_hbox = new HBox(false, 12);
        vbox.pack_start(m_hbox);
        
        m_hbox.pack_start(m_image_widget);
        
        m_content = new VBox(false, 12);
        m_hbox.pack_end(m_content);
        
        m_content.pack_start(m_primary_label);
        
        
        // sizes from GtkMessageDialog
        set_border_width(5);
        m_hbox.set_border_width(5);
        vbox.set_spacing(14);
        (get_action_area() as Container).set_border_width(5);
        (get_action_area() as Box).set_spacing(6);
    }
    
    public void set_primary_label_text(string p_text) {
        m_primary_label.set_markup(@"<big>$p_text</big>");
    }
    
    public void set_stock_icon(string p_stock_icon) {
        m_hbox.remove(m_image_widget);
        m_image_widget = new Image.from_stock(p_stock_icon, IconSize.DIALOG);
        m_hbox.pack_start(m_image_widget);
    }
}

}
