int main(string[] args) {

    GnomeVFS.init();
    //GnomeVFS.mime_reload();
    Gtk.init (ref args);

    var window = new MainWindow();
    window.set_title("Ginko File Manager");
    window.destroy.connect (Gtk.main_quit);
    window.show_all();

    Gtk.main();
    return 0;
}