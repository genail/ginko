namespace Ginko {
    
class Main {
    static int main(string[] p_args) {
        /*GLib.Intl.bindtextdomain(Config.GETTEXT_PACKAGE, Config.LOCALEDIR);
        GLib.Intl.bind_textdomain_codeset(Config.GETTEXT_PACKAGE, "UTF-8");
        GLib.Intl.textdomain(Config.GETTEXT_PACKAGE);
        GLib.Intl.setlocale(LocaleCategory.ALL, "");*/
        
        var application = new Application(p_args);
        application.run();
        
        return 0;
    }
}

} // namespace
