using Gtk;

namespace Ginko {

class Messages {
    public static void show_error(Context p_context, string p_title, string p_description) {
        var dialog = new MessageDialog(
            p_context.m_main_window,
            0,
            MessageType.ERROR,
            ButtonsType.OK,
            p_description,
            null);
        
        dialog.set_title(p_context.m_name + ": " + p_title);
        dialog.run();
        dialog.close();
    }
    
    public static void show_error_t(Context p_context, string p_title, string p_description) {
        Idle.add(() => {
                show_error(p_context, p_title, p_description); return false;
        });
    }
    
    public static void show_info(Context p_context, string p_title, string p_description) {
        var dialog = new MessageDialog(
            p_context.m_main_window,
            0,
            MessageType.INFO,
            ButtonsType.OK,
            p_description,
            null);
        
        dialog.set_title(p_context.m_name + ": " + p_title);
        dialog.run();
        dialog.close();
    }
    
    public static void show_info_t(Context p_context, string p_title, string p_description) {
        Idle.add(() => {
                show_info(p_context, p_title, p_description); return false;
        });
    }
    
    public static bool ask_yes_no(Context p_context, string p_title, string p_description) {
        var dialog = new MessageDialog(
            p_context.m_main_window,
            0,
            MessageType.QUESTION,
            ButtonsType.YES_NO,
            p_description,
            null);
        
        dialog.set_title(p_context.m_name + ": " + p_title);
        var response = dialog.run();
        dialog.close();
        
        return response == ResponseType.YES;
    }
    
    public static bool ask_yes_no_t(Context p_context, string p_title, string p_description) {
        bool[] answer = {};
        
        GuiExecutor.run_and_wait(() => {
                answer += ask_yes_no(p_context, p_title, p_description);
        });
        
        return answer[0];
    }
}

} // namespace
