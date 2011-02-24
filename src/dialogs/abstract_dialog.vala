using Gtk;

namespace Ginko {

public abstract class AbstractDialog : Dialog {
    
    public AbstractDialog() {
        set_resizable(false);
        set_skip_taskbar_hint(true);
        
        // sizes from GtkMessageDialog
        set_border_width(Sizes.BOX_BORDER_WIDTH_NORMAL);
        vbox.set_spacing(Sizes.BOX_SPACING_NORMAL);
        (get_action_area() as Container).set_border_width(Sizes.BOX_BORDER_WIDTH_NORMAL);
        (get_action_area() as Box).set_spacing(6);
    }
}
    
} // namespace
