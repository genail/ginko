using Gtk;

namespace Ginko {

class NavigatorView {

    public Widget m_widget { get; private set;}
    
    DirectoryView m_left_view;
    DirectoryView m_right_view;
    
    public NavigatorView(DirectoryView p_left_view, DirectoryView p_right_view) {
        m_left_view = p_left_view;
        m_right_view = p_right_view;
        
        build_ui();
    }
    
    private void build_ui() {
        var panes = new HPaned();
        
        var left_scroll = new ScrolledWindow(null, null);
        var right_scroll = new ScrolledWindow(null, null);
        
        left_scroll.add(m_left_view);
        right_scroll.add(m_right_view);
        
        panes.pack1(left_scroll, false, false);
        panes.pack2(right_scroll, false, false);
        
        m_widget = panes;
    }
}

} // namespace
