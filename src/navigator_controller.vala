using Gtk;
using Gdk;

namespace Ginko {

class NavigatorController {

    public NavigatorView view { get; private set; default = new NavigatorView(); }

    public NavigatorController() {
        var widget = view.widget;
        widget.key_press_event.connect(on_key_press);
    }
    
    private bool on_key_press(EventKey e) {
        string keystr = Gdk.keyval_name(e.keyval);
//~         debug(keystr);
        switch (keystr) {
            case "Tab":
                on_key_press_tab();
                return true;
        }
    
        return false;
    }
    
    private void on_key_press_tab() {
        view.switch_active_pane();
    }
    
    public ActionContext create_action_context() {
        var c = new ActionContext();
        var active_controller = view.active_controller;
        var unactive_controller = view.unactive_controller;
        
        c.source_dir = active_controller.current_file;
        c.target_dir = unactive_controller.current_file;
        
        c.source_selected_files = active_controller.get_selected_files();
        c.target_selected_files = unactive_controller.get_selected_files();
        
        return c;
    }
}

} // namespace
