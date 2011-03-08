using Gtk;

namespace Ginko.Actions {

class MoveFileConfigureDialog : AbstractDialog {
    public enum Response {
        OK = ResponseType.OK,
        CANCEL = ResponseType.CANCEL
    }
    
    private static const int DEFAULT_RESPONSE = Response.OK;
    
    private Entry m_destination_entry;
    
    public MoveFileConfigureDialog(ActionContext p_context) {
        build_ui(p_context);
    }
    
    public MoveFileConfig get_config() {
        var config = new MoveFileConfig();
        config.destination = m_destination_entry.get_text();
        return config;
    }
    
    private void build_ui(ActionContext p_context) {
        set_title("Move files");
        set_size_request(Sizes.SUGGESTED_DIALOG_WIDTH, -1);

        add_button(Stock.OK, Response.OK);
        add_button(Stock.CANCEL, Response.CANCEL);
        
        set_default_response(DEFAULT_RESPONSE);
        
        var box = new VBox(false, Sizes.BOX_SPACING_SMALL);
        box.set_border_width(Sizes.BOX_BORDER_WIDTH_SMALL);
        (get_content_area() as Container).add(box);
        
        // title dependend of number of files
        var selected_files = p_context.source_selected_files;
        assert(selected_files.length >= 1);
        
        string move_files_label_text = "";
        if (selected_files.length == 1) {
            var file = selected_files[0];
            var file_basename = file.get_basename();
            move_files_label_text = "Move \"%s\" to:".printf(file_basename);
        } else if (selected_files.length > 1) {
            var files_count = selected_files.length;
            move_files_label_text = "Move %d files to:".printf(files_count);
        } else {
            assert(false);
        }
        
        var move_files_label = new Label(move_files_label_text);
        move_files_label.set_alignment(0, 0);
        
        
        m_destination_entry = new Entry();
        prepare_entry(m_destination_entry);
        
        var target_path = p_context.destination_dir.get_path() + "/";
        m_destination_entry.set_text(target_path);
        
        
        box.pack_start(move_files_label);
        box.pack_start(m_destination_entry);
        
        show_all();
    }
    
    private void prepare_entry(Entry p_entry) {
        p_entry.activate.connect(() => { response(DEFAULT_RESPONSE); });
    }
}

} // namespace
