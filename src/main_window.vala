using Gtk;

class MainWindow : Window {
    private DirectoryController directory_controller_1;
    private DirectoryController directory_controller_2;
    
    private VBox main_vbox;

    public MainWindow() {
        title = "Ginko File Manager";
        set_default_size (800, 600);
        
        main_vbox = new VBox(false, 0);
        
        build_panels();
        build_function_buttons();
        
        add(main_vbox);
    }
    
    private void build_panels() {
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
        main_vbox.pack_start(hpaned);
    }
    
    private void build_function_buttons() {
        var hbox = new HBox(true, 0);
        
        var button_view = new Button.with_label("F3 View");
        hbox.pack_start(button_view);
        
        var button_edit = new Button.with_label("F4 Edit");
        hbox.pack_start(button_edit);
        
        var button_copy = new Button.with_label("F5 Copy");
        hbox.pack_start(button_copy);
        
        var button_move = new Button.with_label("F6 Move");
        hbox.pack_start(button_move);
        
        var button_new = new Button.with_label("F7 New Folder");
        hbox.pack_start(button_new);
        
        var button_del = new Button.with_label("F8 Delete");
        hbox.pack_start(button_del);
        
        var button_terminal = new Button.with_label("F9 Terminal");
        hbox.pack_start(button_terminal);
        
        var button_exit = new Button.with_label("F10 Exit");
        hbox.pack_start(button_exit);
        
        main_vbox.pack_start(hbox, false);
    }
}
