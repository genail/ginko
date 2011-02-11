int main(string[] args) {

    Gtk.init (ref args);
    
    var context = new ApplicationContext();
    
    var copy_action = new CopyFileAction();
    context.actions.append(copy_action);
    
    var accel = copy_action.accelerator;

    var window = new MainWindow(context);
    window.register_action_accelerators();
    
    window.destroy.connect (Gtk.main_quit);
    window.show_all();

    Gtk.main();
    return 0;
}
