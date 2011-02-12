using Gtk;

namespace Ginko {

class NavigatorView {

    public Widget widget { get; private set;}
    
    private DirectoryController left_controller;
    private DirectoryController right_controller;
    
    public DirectoryController active_controller { get; private set; }
    public DirectoryController unactive_controller { get; private set; }
    
    public NavigatorView() {
        build_ui();
        
        active_controller = left_controller;
        unactive_controller = right_controller;
    }
    
    private void build_ui() {
        var panes = new HPaned();
        
        left_controller = new DirectoryController();
        right_controller = new DirectoryController();
        
        var left_view = left_controller.view;
        var right_view = right_controller.view;
        
        var left_scroll = new ScrolledWindow(null, null);
        var right_scroll = new ScrolledWindow(null, null);
        
        left_scroll.add(left_view);
        right_scroll.add(right_view);
        
        panes.pack1(left_scroll, false, false);
        panes.pack2(right_scroll, false, false);
        
        widget = panes;
    }
    
    public void switch_active_pane() {
        var tmp = active_controller;
        active_controller = unactive_controller;
        unactive_controller = tmp;

        unactive_controller.make_unactive();        
        active_controller.make_active();
    }
    

}

} // namespace
