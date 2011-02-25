namespace Ginko {

public class Application {
    private MainWindow m_main_window;
    private ApplicationContext m_context;
    
    public Application(string[] p_args) {
        if ("--debug" in p_args) {
            stdout.printf("!!! Running in debug mode !!!\n");
            Config.debug = true;
        }
        
        Gtk.init (ref p_args);
        
        m_main_window = new MainWindow();
        
        m_main_window.destroy.connect(Gtk.main_quit);
        m_main_window.action_invoked.connect(invoke_action);
        
        m_main_window.show_all();
    }
    
    private void invoke_action(ActionDescriptor p_action_descriptor) {
        var p_action_context = create_action_context(p_action_descriptor);
        p_action_descriptor.execute(p_action_context);
    }
    
    private ActionContext create_action_context(ActionDescriptor p_action_descriptor) {
        var context = new ActionContext(p_action_descriptor.m_name, m_main_window);
        
        m_main_window.m_navigator_controller.accept_action_context(context);
        
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
        action_descriptors += new Actions.OpenTerminalActionDescriptor();
        
        m_main_window.register_action_accelerators(action_descriptors);
    }
    
    
}

} // namespace
