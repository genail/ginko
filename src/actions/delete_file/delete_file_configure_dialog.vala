using Gtk;
using Ginko.Dialogs;

namespace Ginko.Actions {

class DeleteFileConfigureDialog : AbstractMessageDialog {
    public enum Response {
        YES = ResponseType.YES,
        NO = ResponseType.NO,
        CANCEL = ResponseType.CANCEL
    }
    
    
    public DeleteFileConfigureDialog(ActionContext p_context) {
        
        // title dependend of number of files
        var selected_files = p_context.source_selected_files;
        assert(selected_files.length >= 1);
        
        string label_text = "";
        if (selected_files.length == 1) {
            var file = selected_files[0];
            var file_basename = file.get_basename();
            label_text = "Do you really want to delete \"%s\"?".printf(file_basename);
        } else if (selected_files.length > 1) {
            var files_count = selected_files.length;
            label_text =
            "Do you really want to delete these %d files?".printf(files_count);
        } else {
            assert(false);
        }
        
        set_title("Delete files");
        
        set_stock_icon(Stock.DIALOG_QUESTION);
        set_secondary_label_text(label_text);
        
        add_button(Stock.YES, Response.YES).grab_focus();
        add_button(Stock.NO, Response.NO);
        add_button(Stock.CANCEL, Response.CANCEL);
    }
}
    
} // namespace
