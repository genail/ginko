namespace Ginko.Actions {
    
class DeleteFileDescriptor : ActionDescriptor {
    public DeleteFileDescriptor() {
        base(
            "Delete files",
            new string[] { "delete", "remove", "erease", "file", "files" },
            new Accelerator("F8", null));
    }
    
    public override void execute(ActionContext p_context) {
        var action = new DeleteFileAction(this);
        action.execute(p_context);
    }
}

} // namespace
