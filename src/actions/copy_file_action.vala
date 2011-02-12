using Gtk;

namespace Ginko {

class CopyFileAction : Action {
    
    public class Config {
        public string destination;
        public bool preserve_attrs;
        public bool follow_symlinks;
    }
    
    public CopyFileAction() {
        base(
            "Copy files",
            new string[] { "copy", "file", "files" },
            new Accelerator("F5", null));
    }
    
    public override void execute(ActionContext context) {
        var config_dialog = new CopyFileActionConfigureDialog(context);
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
