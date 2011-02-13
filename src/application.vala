namespace Ginko {

public class Application {
    private MainWindow main_window;
    private ApplicationContext context;
    
    public Application(string[] args) {
        Gtk.init (ref args);
        
        main_window = new MainWindow();
        
        main_window.destroy.connect(Gtk.main_quit);
        main_window.action_invoked.connect(invoke_action);
        
        main_window.show_all();
    }
    
    private void invoke_action(Action action) {
        var action_context = create_action_context(action);
        action.execute(action_context);
        
        // DEBUG
        var dialog = new Ginko.Dialogs.OverwriteDialog(action_context);
        dialog.run();
    }
    
    private ActionContext create_action_context(Action action) {
        var context = new ActionContext(action.name, main_window);
        
        main_window.navigator_controller.accept_action_context(context);
        
        return context;
    }
    
    public void run() {
        register_actions();
        Gtk.main();
    }
    
    private void register_actions() {
        Action[] actions = {};
        actions += new Actions.CopyFile();
        
        main_window.register_action_accelerators(actions);
    }
    
    
}

} // namespace
