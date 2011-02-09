using Gtk;

class BreadCrumbs : Box {
    private Entry entry;
    
    public BreadCrumbs() {
        entry = new Entry();
        add(entry); 
    }
    
    public void set_path(string path) {
        entry.set_text(path);
    }
}
