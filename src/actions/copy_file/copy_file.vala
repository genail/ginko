using Gtk;

namespace Ginko.Actions {

class CopyFile : Action {
    
    public CopyFile() {
        base(
            "Copy files",
            new string[] { "copy", "file", "files" },
            new Accelerator("F5", null));
    }
    
    public override void execute(ActionContext context) {
        var config_dialog = new CopyFileConfigureDialog(context);
        var return_code = config_dialog.run();
        config_dialog.close();
        
        if (return_code == ResponseType.OK) {
            var config = config_dialog.get_config();
            
            var progress_dialog = new ActionProgressDialog();
            progress_dialog.set_progress(0.5, "Test");
            progress_dialog.log_details("first detail");
            progress_dialog.log_details("second detail");
            progress_dialog.run();
        }
    }
}

} // namespace
