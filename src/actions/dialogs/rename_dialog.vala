using Gtk;

namespace Ginko.Dialogs {
    
class RenameDialog {
    private MessageDialog m_dialog;
    
    public RenameDialog(ActionContext p_context, string p_filename) {
        m_dialog = new MessageDialog(
            p_context.main_window,
            0,
            MessageType.QUESTION,
            ButtonsType.OK_CANCEL,
            "Please enter new file name:");
        
        var entry = new Entry();
        entry.set_text(p_filename);
        entry.select_region(-1, -1);
        
        m_dialog.vbox.add(entry);
        
        entry.show();
    }
    
    public int run() {
        return m_dialog.run();
    }
}
    
} // namespace
