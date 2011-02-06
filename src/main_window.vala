using Gtk;

class MainWindow : Window {
    private DirectoryController directory_controller_1;

    public MainWindow() {
        title = "File Manager";
        set_default_size (400, 300);
        
        var dir_view1 = new DirectoryView();
        directory_controller_1 = new DirectoryController(dir_view1);
        
        var scroll1 = new ScrolledWindow(null, null);
        scroll1.add(dir_view1);
        
        var hpaned = new HPaned();
        
        hpaned.add(scroll1);
        
        var dir_view2 = new DirectoryView();
        hpaned.add(dir_view2);
        
        add(hpaned);
    }
}
