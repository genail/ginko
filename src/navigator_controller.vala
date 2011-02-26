using Gtk;
using Gdk;

namespace Ginko {

class NavigatorController {
    public NavigatorView m_view {get; private set;}
    
    private enum ActivePane {
        LEFT,
        RIGHT
    }
    
    private DirectoryController m_left_controller;
    private DirectoryController m_right_controller;
    
    private ActivePane m_active_pane;
    
    //public DirectoryController m_active_controller { get; private set; }
    //public DirectoryController m_unactive_controller { get; private set; }

    public NavigatorController() {
        m_left_controller = new DirectoryController();
        m_right_controller = new DirectoryController();
      
        m_active_pane = ActivePane.LEFT;
        
        m_view = new NavigatorView(m_left_controller.m_view, m_right_controller.m_view);
        
        var widget = m_view.m_widget;
        widget.key_press_event.connect(on_key_press);
        
        // connect path settings
        m_left_controller.load_path(Settings.get().get_left_pane_path());
        m_left_controller.dir_changed.connect((p_dir) =>
            Settings.get().set_left_pane_path(p_dir.get_path()));
        
        m_right_controller.load_path(Settings.get().get_right_pane_path());
        m_right_controller.dir_changed.connect((p_dir) =>
            Settings.get().set_right_pane_path(p_dir.get_path()));
        
        // connect focus grab
        m_left_controller.user_focused.connect(() => {
                if (m_active_pane == ActivePane.RIGHT) {
                    switch_active_pane();
                }
        });
        
        m_right_controller.user_focused.connect(() => {
                if (m_active_pane == ActivePane.LEFT) {
                    switch_active_pane();
                }
        });
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
        if (m_active_pane == ActivePane.LEFT) {
            m_active_pane = ActivePane.RIGHT;
            m_left_controller.make_unactive();
            m_right_controller.make_active();
        } else if (m_active_pane == ActivePane.RIGHT) {
            m_active_pane = ActivePane.LEFT;
            m_left_controller.make_active();
            m_right_controller.make_unactive();
        }
    }
    
    public void accept_action_context(ActionContext p_context) {
        var active_controller = get_active_controller();
        var unactive_controller = get_unactive_controller();
        
        p_context.source_dir = active_controller.m_current_file;
        p_context.destination_dir = unactive_controller.m_current_file;
        
        p_context.source_selected_files = active_controller.get_selected_files();
        p_context.destination_selected_files = unactive_controller.get_selected_files();
        
        p_context.active_controller = active_controller;
        p_context.unactive_controller = unactive_controller;
    }
    
    private unowned DirectoryController get_active_controller() {
        if (m_active_pane == ActivePane.LEFT) {
            return m_left_controller;
        } else if (m_active_pane == ActivePane.RIGHT) {
            return m_right_controller;
        } else {
            return null;
        }
    }
    
    private unowned DirectoryController get_unactive_controller() {
        if (m_active_pane == ActivePane.LEFT) {
            return m_right_controller;
        } else if (m_active_pane == ActivePane.RIGHT) {
            return m_left_controller;
        } else {
            return null;
        }
    }
}

} // namespace
