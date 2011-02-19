namespace Ginko.Actions {
    
public class CopyFileDescriptor : ActionDescriptor {
    public CopyFileDescriptor() {
        base(
            "Copy files",
            new string[] { "copy", "file", "files" },
            new Accelerator("F5", null));
    }
    
    public override void execute(ActionContext context) {
        var action = new CopyFileAction();
        action.execute(context);
    }
}

} // namespace
