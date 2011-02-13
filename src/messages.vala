using Gtk;

namespace Ginko {

class Messages {
    public static void show_error(Context context, string title, string description) {
        var dialog = new MessageDialog(
            context.main_window, 0, MessageType.ERROR, ButtonsType.OK, description);
        dialog.set_title(context.name + ": " + title);
        dialog.run();
    }
}

} // namespace
