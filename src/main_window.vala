using Gtk;
using Gee;

namespace Ginko {

class MainWindow : Window {
    
    public signal void action_invoked(ActionDescriptor action_descriptor);
    
    public NavigatorController m_navigator_controller {get; private set;}
    private VBox m_main_vbox;
    private HBox m_button_box;
    
    private HashMap<Accelerator, Button> m_accel_buttons = new HashMap<Accelerator, Button>(
        (a) => Accelerator.hash(a as Accelerator),
        (a, b) => Accelerator.equal(a as Accelerator, b as Accelerator));

    public MainWindow() {
        title = "Ginko File Manager";
        if (Config.debug) {
            title += " (DEBUG MODE)";
        }
        
        set_default_size(800, 600);
        
        m_main_vbox = new VBox(false, 0);
        
        build_panels();
        build_function_buttons();
        
        add(m_main_vbox);
    }
    
    private void build_panels() {
        m_navigator_controller = new NavigatorController();
        var view = m_navigator_controller.m_view;
        var widget = view.m_widget;
        
        m_main_vbox.pack_start(widget);
    }
    
    private void build_function_buttons() {
        m_button_box = new HBox(true, 0);
        
        add_button("View", "F3");
        add_button("Edit", "F4");
        add_button("Copy", "F5");
        add_button("Move", "F6");
        add_button("New Folder", "F7");
        add_button("Delete", "F8");
        add_button("Terminal", "F9");
        add_button("Exit", "F10");
        
        m_main_vbox.pack_start(m_button_box, false);
    }
    
    private void add_button(string p_name, string p_accel_str) {
        var button = new Button.with_label(p_accel_str + " " + p_name);
        button.set_relief(ReliefStyle.NONE);
        
        m_button_box.pack_start(button);
        
        var accel = new Accelerator(p_accel_str);
        m_accel_buttons[accel] = button;
    }
    
    public void register_action_accelerators(ActionDescriptor[] p_actions) {
        var accel_group = new AccelGroup();
        
        foreach (var action in p_actions) {
            var accel = action.m_accelerator;
            
            var action_clos = action; // FIXME: Vala bug, without this null pointer will occur
                                      //*wait for https://bugzilla.gnome.org/show_bug.cgi?id=599133
            accel_group.connect(accel.m_keyval, accel.m_modifier_type, 0, () => {
                action_invoked(action_clos);
                return true;
            });
            
            // connect to function button if exists
            if (m_accel_buttons.has_key(accel)) {
                var function_button = m_accel_buttons[accel];
                function_button.clicked.connect(() => action_invoked(action_clos));
                
                m_accel_buttons.unset(accel);
            }
        }
        
        add_accel_group(accel_group);
        
        // check and warning about missing connections
        foreach (var button in m_accel_buttons.values) {
            warning("missing connection for function button: '%s'", button.get_label());
        }
    }
}

} // namespace
