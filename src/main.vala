namespace Ginko {

int main(string[] args) {
    /*GLib.Intl.bindtextdomain(Config.GETTEXT_PACKAGE, Config.LOCALEDIR);
    GLib.Intl.bind_textdomain_codeset(Config.GETTEXT_PACKAGE, "UTF-8");
    GLib.Intl.textdomain(Config.GETTEXT_PACKAGE);
    GLib.Intl.setlocale(LocaleCategory.ALL, "");*/
    
    Gtk.init (ref args);
    
    var context = new ApplicationContext();
    
    var copy_action = new Actions.CopyFile();
    context.actions.append(copy_action);
    
    var accel = copy_action.accelerator;

    var window = new MainWindow(context);
    window.register_action_accelerators();
    
    window.destroy.connect (Gtk.main_quit);
    window.show_all();

    Gtk.main();
    return 0;
}

} // namespace
