using Gtk;

namespace Ginko {

class MainWindow : Window {
    
    public signal void action_invoked(Action action);
    
    public NavigatorController navigator_controller {get; private set;}
    private VBox main_vbox;

    public MainWindow() {
        title = "Ginko File Manager";
        set_default_size (800, 600);
        
        main_vbox = new VBox(false, 0);
        
        build_panels();
        build_function_buttons();
        
        add(main_vbox);
    }
    
    private void build_panels() {
        navigator_controller = new NavigatorController();
        var view = navigator_controller.view;
        var widget = view.widget;
        
        main_vbox.pack_start(widget);
    }
    
    private void build_function_buttons() {
        var hbox = new HBox(true, 0);
        
        Button[] buttons = {};
        
        var button_view = new Button.with_label("F3 View");
        buttons += button_view;
        
        var button_edit = new Button.with_label("F4 Edit");
        buttons += button_edit;
        
        var button_copy = new Button.with_label("F5 Copy");
        buttons += button_copy;
        
        var button_move = new Button.with_label("F6 Move");
        buttons += button_move;
        
        var button_new = new Button.with_label("F7 New Folder");
        buttons += button_new;
        
        var button_del = new Button.with_label("F8 Delete");
        buttons += button_del;
        
        var button_terminal = new Button.with_label("F9 Terminal");
        buttons += button_terminal;
        
        var button_exit = new Button.with_label("F10 Exit");
        buttons += button_exit;
        
        foreach (var button in buttons) {
            button.set_relief(ReliefStyle.NONE);
            hbox.pack_start(button);
        }
        
        main_vbox.pack_start(hbox, false);
    }
    
    public void register_action_accelerators(Action[] actions) {
        var accel_group = new AccelGroup();
        
        foreach (var action in actions) {
            var accel = action.accelerator;
            
            var action_clos = action; // FIXME: Vala bug, without this null pointer will occur
                                      //*wait for https://bugzilla.gnome.org/show_bug.cgi?id=599133
            accel_group.connect(accel.keyval, accel.modifier_type, 0, () =>
                {action_invoked(action_clos); return true;}
            );
        }
        
        add_accel_group(accel_group);
    }
}

} // namespace
