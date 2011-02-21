namespace Ginko {

public class Application {
    private MainWindow main_window;
    private ApplicationContext context;
    
    public Application(string[] args) {
        if ("--debug" in args) {
            stdout.printf("!!! Running in debug mode !!!\n");
            Config.debug = true;
            
            /*try {
                Ginko.IO.Files.list_children_recurse(
                    File.new_for_path("/tmp"), false, (file) => {
                        stdout.printf("file: %s\n", file.get_path());
                    });
            } catch (Error e) {
                stdout.printf("error: %s\n", e.message);
            }
            
            var file = Ginko.IO.Files.rebase(File.new_for_path("/home/chudy/download"), File.new_for_path("/home"), File.new_for_path("/tmp"));
            stdout.printf("rebase: %s\n", file.get_path());*/
        }
        
        Gtk.init (ref args);
        
        main_window = new MainWindow();
        
        main_window.destroy.connect(Gtk.main_quit);
        main_window.action_invoked.connect(invoke_action);
        
        main_window.show_all();
    }
    
    private void invoke_action(ActionDescriptor action_descriptor) {
        var action_context = create_action_context(action_descriptor);
        action_descriptor.execute(action_context);
    }
    
    private ActionContext create_action_context(ActionDescriptor action_descriptor) {
        var context = new ActionContext(action_descriptor.name, main_window);
        
        main_window.navigator_controller.accept_action_context(context);
        
        return context;
    }
    
    public void run() {
        register_actions();
        Gtk.main();
    }
    
    private void register_actions() {
        ActionDescriptor[] action_descriptors = {};
        action_descriptors += new Actions.RefreshActionDescriptor();
        action_descriptors += new Actions.CopyFileDescriptor();
        
        main_window.register_action_accelerators(action_descriptors);
    }
    
    
}

} // namespace
