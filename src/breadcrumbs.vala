using Gtk;

namespace Ginko {

class BreadCrumbs : Box {
    private Entry m_entry;
    
    public BreadCrumbs() {
        m_entry = new Entry();
        add(m_entry); 
    }
    
    public void set_path(string p_path) {
        m_entry.set_text(p_path);
    }
}

} // namespace
