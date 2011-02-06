using Gtk;

class MainWindow : Window {
    private DirectoryController directory_controller_1;
    private DirectoryController directory_controller_2;

    public MainWindow() {
        title = "Ginko File Manager";
        set_default_size (800, 600);
        
        var hpaned = new HPaned();
        
        var dir_view1 = new DirectoryView();
        directory_controller_1 = new DirectoryController(dir_view1);
        
        var scroll1 = new ScrolledWindow(null, null);
        scroll1.add(dir_view1);
        
        var dir_view2 = new DirectoryView();
        directory_controller_2 = new DirectoryController(dir_view2);
        
        var scroll2 = new ScrolledWindow(null, null);
        scroll2.add(dir_view2);
        
        hpaned.pack1(scroll1, true, true);
        hpaned.pack2(scroll2, true, true);
        
        add(hpaned);
    }
}
