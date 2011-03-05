namespace Ginko.Actions {
    
class MoveFileDescriptor : ActionDescriptor {
    public MoveFileDescriptor() {
        base(
            "Move files",
            new string[] { "move", "rename", "file", "files" },
            new Accelerator("F6", null));
    }
    
    public override void execute(ActionContext p_context) {
        //var action = new MoveFileAction(this);
        //action.execute(p_context);
    }
}

} // namespace
