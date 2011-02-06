using Gtk;

class MainWindow : Window {
    private DirectoryController directory_controller_1;
    private DirectoryController directory_controller_2;

    public MainWindow() {
        title = "Ginko File Manager";
        set_default_size (800, 600);
        
        var hpaned = new HPaned();
        
        var dir_view1 = new DirectoryView();
        var breadcrumbs1 = new BreadCrumbs();
        directory_controller_1 = new DirectoryController(dir_view1, breadcrumbs1);
        
        var scroll1 = new ScrolledWindow(null, null);
        scroll1.add(dir_view1);
        
        var dir_view2 = new DirectoryView();
        var breadcrumbs2 = new BreadCrumbs();
        directory_controller_2 = new DirectoryController(dir_view2, breadcrumbs2);
        
        var scroll2 = new ScrolledWindow(null, null);
        scroll2.add(dir_view2);
        
        var vbox1 = new VBox(false, 10);
        vbox1.pack_start(breadcrumbs1, false);
        vbox1.pack_start(scroll1);
        
        hpaned.pack1(vbox1, true, true);
        
        var vbox2 = new VBox(false, 10);
        vbox2.pack_start(breadcrumbs2, false);
        vbox2.pack_start(scroll2);
        
        hpaned.pack2(vbox2, true, true);
        
        add(hpaned);
    }
}
