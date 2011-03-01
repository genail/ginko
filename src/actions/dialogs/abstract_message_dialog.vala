using Gtk;

namespace Ginko.Dialogs {

/**
 * Usage:
 * - set icon using set_stock_icon
 * - set label using set_primary_label
 * - add additional content using m_content property
 */
public abstract class AbstractMessageDialog : AbstractDialog {
    
    private Image m_image_widget;
    private Label m_primary_label;
    private Label m_secondary_label; // invisible until text set
    public VBox m_content {get; private set;}
    private HBox m_hbox;
    
    public AbstractMessageDialog() {
        m_image_widget = new Image.from_stock(Stock.DIALOG_QUESTION, IconSize.DIALOG);
        m_image_widget.set_alignment(0.5f, 0);
        m_image_widget.show();
        
        m_primary_label = new Label("");
        m_primary_label.set_selectable(true);
        m_primary_label.set_alignment(0, 0);
        
        m_secondary_label = new Label("");
        m_secondary_label.set_selectable(true);
        m_secondary_label.set_alignment(0, 0);
        
        m_hbox = new HBox(false, Sizes.BOX_SPACING_NORMAL);
        m_hbox.show();
        
        vbox.pack_start(m_hbox);
        m_hbox.pack_start(m_image_widget);
        
        m_content = new VBox(false, Sizes.BOX_SPACING_NORMAL);
        m_content.show();
        
        m_hbox.pack_end(m_content);
        m_content.pack_start(m_primary_label);
        m_content.pack_start(m_secondary_label);
        
        m_hbox.set_border_width(Sizes.BOX_BORDER_WIDTH_NORMAL);
    }
    
    public void set_primary_label_text(string p_text) {
        m_primary_label.set_markup(@"<big>$p_text</big>");
        m_primary_label.show();
    }
    
    public void set_secondary_label_text(string p_text) {
        m_secondary_label.set_text(p_text);
        m_secondary_label.show();
    }
    
    public void set_stock_icon(string p_stock_icon) {
        m_hbox.remove(m_image_widget);
        m_image_widget = new Image.from_stock(p_stock_icon, IconSize.DIALOG);
        m_image_widget.show();
        m_hbox.pack_start(m_image_widget);
    }
}

}
