using Gtk;

namespace Ginko.Actions {

class CopyFileConfigureDialog : AbstractDialog {
    private const ResponseType DEFAULT_RESPONSE = ResponseType.OK;
    
    private Entry m_destination_entry;
    private CheckButton m_preserve_attrs_check;
    private CheckButton m_follow_symlinks_check;
    
    public CopyFileConfigureDialog(ActionContext p_context) {
        build_ui(p_context);
    }
    
    public CopyFileConfig get_config() {
        var config = new CopyFileConfig();
        
        config.destination = m_destination_entry.get_text();
        config.preserve_attrs = m_preserve_attrs_check.get_active();
        config.follow_symlinks = m_follow_symlinks_check.get_active();
        
        return config;
    }
    
    private void build_ui(ActionContext p_context) {
        set_title("Copy files");
        set_size_request(Sizes.SUGGESTED_DIALOG_WIDTH, -1);
        
        add_buttons(Stock.OK, ResponseType.OK, Stock.CANCEL, ResponseType.CANCEL); // why this may be not null-terminated?
        set_default_response(DEFAULT_RESPONSE);
        
        var box = new VBox(false, Sizes.BOX_SPACING_SMALL);
        box.set_border_width(Sizes.BOX_BORDER_WIDTH_SMALL);
        (get_content_area() as Container).add(box);
        
        // title dependend of number of files
        var selected_files = p_context.source_selected_files;
        assert(selected_files.length >= 1);
        
        string copy_files_label_text = "";
        if (selected_files.length == 1) {
            var file = selected_files[0];
            var file_basename = file.get_basename();
            copy_files_label_text = "Copy \"%s\" to:".printf(file_basename);
        } else if (selected_files.length > 1) {
            var files_count = selected_files.length;
            copy_files_label_text = "Copy %d files to:".printf(files_count);
        } else {
            assert(false);
        }
        
        var copy_files_label = new Label(copy_files_label_text);
        copy_files_label.set_alignment(0, 0);
        
        
        m_destination_entry = new Entry();
        prepare_entry(m_destination_entry);
        
        var target_path = p_context.destination_dir.get_path() + "/";
        m_destination_entry.set_text(target_path);
        
        
        m_preserve_attrs_check = new CheckButton.with_label("Preserve attributes");
        m_follow_symlinks_check = new CheckButton.with_label("Follow symlinks");
        
        box.pack_start(copy_files_label);
        box.pack_start(m_destination_entry);
        box.pack_start(m_preserve_attrs_check);
        box.pack_start(m_follow_symlinks_check);
        
        show_all();
    }
    
    private void prepare_entry(Entry p_entry) {
        p_entry.activate.connect(() => { response(DEFAULT_RESPONSE); });
    }
}

} // namespace
