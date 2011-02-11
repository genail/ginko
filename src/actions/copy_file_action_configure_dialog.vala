using Gtk;

class CopyFileActionConfigureDialog : Dialog {
    public const int RESPONSE_OK = 1;
    public const int RESPONSE_CANCEL = 2;
    
    private Entry destination_entry;
    private CheckButton preserve_attrs_check;
    private CheckButton follow_symlinks_check;
    
    public CopyFileActionConfigureDialog(ActionContext context) {
        set_size_request(Stock.SUGGESTED_DIALOG_WIDTH, -1);
        
        add_buttons(Gtk.Stock.OK, RESPONSE_OK, Gtk.Stock.CANCEL, RESPONSE_CANCEL, 0);
        
        var box = new VBox(false, 0);
        (get_content_area() as Container).add(box);
        
        var copy_files_label = new Label("Copy x files to:");
        copy_files_label.set_alignment(0, 0);
        
        destination_entry = new Entry();
        
        var target_path = context.target_dir.get_path() + "/";
        destination_entry.set_text(target_path);
        
        
        preserve_attrs_check = new CheckButton.with_label("Preserve attributes");
        follow_symlinks_check = new CheckButton.with_label("Follow symlinks");
        
        box.pack_start(copy_files_label);
        box.pack_start(destination_entry);
        box.pack_start(preserve_attrs_check);
        box.pack_start(follow_symlinks_check);
        
        show_all();
    }
}
