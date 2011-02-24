using Gtk;

namespace Ginko.Actions {

class CopyFileConfigureDialog : AbstractDialog {
    private const ResponseType DEFAULT_RESPONSE = ResponseType.OK;
    
    private Entry destination_entry;
    private CheckButton preserve_attrs_check;
    private CheckButton follow_symlinks_check;
    
    public CopyFileConfigureDialog(ActionContext context) {
        build_ui(context);
    }
    
    public CopyFileConfig get_config() {
        var config = new CopyFileConfig();
        
        config.m_destination = destination_entry.get_text();
        config.m_preserve_attrs = preserve_attrs_check.get_active();
        config.m_follow_symlinks = follow_symlinks_check.get_active();
        
        return config;
    }
    
    private void build_ui(ActionContext context) {
        set_title("Copy files");
        set_size_request(Sizes.SUGGESTED_DIALOG_WIDTH, -1);
        
        add_buttons(Stock.OK, ResponseType.OK, Stock.CANCEL, ResponseType.CANCEL); // why this may be not null-terminated?
        set_default_response(DEFAULT_RESPONSE);
        
        var box = new VBox(false, Sizes.BOX_SPACING_SMALL);
        box.set_border_width(Sizes.BOX_BORDER_WIDTH_SMALL);
        (get_content_area() as Container).add(box);
        
        var copy_files_label = new Label("Copy x files to:");
        copy_files_label.set_alignment(0, 0);
        
        destination_entry = new Entry();
        prepare_entry(destination_entry);
        
        var target_path = context.m_destination_dir.get_path() + "/";
        destination_entry.set_text(target_path);
        
        
        preserve_attrs_check = new CheckButton.with_label("Preserve attributes");
        follow_symlinks_check = new CheckButton.with_label("Follow symlinks");
        
        box.pack_start(copy_files_label);
        box.pack_start(destination_entry);
        box.pack_start(preserve_attrs_check);
        box.pack_start(follow_symlinks_check);
        
        show_all();
    }
    
    private void prepare_entry(Entry entry) {
        entry.activate.connect(() => { response(DEFAULT_RESPONSE); });
    }
}

} // namespace
