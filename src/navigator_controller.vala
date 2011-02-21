using Gtk;
using Gdk;

namespace Ginko {

class NavigatorController {
    public NavigatorView m_view {get; private set;}
    
    private DirectoryController m_left_controller;
    private DirectoryController m_right_controller;
    
    public DirectoryController m_active_controller { get; private set; }
    public DirectoryController m_unactive_controller { get; private set; }

    public NavigatorController() {
        m_left_controller = new DirectoryController();
        m_right_controller = new DirectoryController();
        
        m_active_controller = m_left_controller;
        m_unactive_controller = m_right_controller;
        
        m_view = new NavigatorView(m_left_controller.view, m_right_controller.view);
        
        var widget = m_view.m_widget;
        widget.key_press_event.connect(on_key_press);
    }
    
    private bool on_key_press(EventKey p_event) {
        var keystr = Gdk.keyval_name(p_event.keyval);
//~         debug(keystr);
        switch (keystr) {
            case "Tab":
                on_key_press_tab();
                return true;
        }
    
        return false;
    }
    
    private void on_key_press_tab() {
        switch_active_pane();
    }
    
    private void switch_active_pane() {
        var tmp = m_active_controller;
        m_active_controller = m_unactive_controller;
        m_unactive_controller = tmp;

        m_unactive_controller.make_unactive();        
        m_active_controller.make_active();
    }
    
    public void accept_action_context(ActionContext p_context) {
        p_context.source_dir = m_active_controller.current_file;
        p_context.target_dir = m_unactive_controller.current_file;
        
        p_context.source_selected_files = m_active_controller.get_selected_files();
        p_context.target_selected_files = m_unactive_controller.get_selected_files();
    }
}

} // namespace
