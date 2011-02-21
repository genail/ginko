using Gtk;

namespace Ginko.Dialogs {
    
class RenameDialog {
    public const int RESPONSE_CANCEL = ResponseType.CANCEL;
    public const int RESPONSE_OK = ResponseType.OK;
    
    private MessageDialog m_dialog;
    private Entry m_entry;
    private Button m_ok_button;
    
    private string m_filename_orig;
    
    public RenameDialog(ActionContext p_context, string p_filename) {
        // workaround for https://bugzilla.gnome.org/show_bug.cgi?id=642899
        m_filename_orig = p_filename;
        
        
        m_dialog = new MessageDialog(
            null,
            0,
            MessageType.QUESTION,
            ButtonsType.OK_CANCEL,
            "Please enter new file name:");
        
        m_entry = new Entry();
        m_entry.set_text(p_filename);
        m_entry.select_region(-1, -1);
        
        m_dialog.vbox.add(m_entry);
        
        m_dialog.set_default_response(RESPONSE_OK);
        
        m_ok_button = (Button) m_dialog.get_widget_for_response(RESPONSE_OK);
        m_ok_button.set_sensitive(false);
        m_ok_button.grab_focus();
        
        //m_entry.changed.connect(on_entry_changed);
        m_entry.changed.connect(() => {
                var text = m_entry.get_text();
                m_ok_button.set_sensitive(text != m_filename_orig);
        });
        
        m_entry.activate.connect(() => {
                m_dialog.response(RESPONSE_OK);
        });
        
        m_entry.show();
    }
    
    public int run() {
        return m_dialog.run();
    }
    
    public unowned string get_filename() {
        return m_entry.get_text();
    }
    
    public void close() {
        m_dialog.close();
    }
    
    
}
    
} // namespace
