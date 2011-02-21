namespace Ginko.Actions {

// set of very basic and quick actions (few lines of code)
class RefreshActionDescriptor : ActionDescriptor {
    public RefreshActionDescriptor() {
        base(
            "Refresh directory view",
            new string[] { "refresh", "reload", "show" },
            new Accelerator("R", new string[] { "CTRL" }));
    }
    
    public override void execute(ActionContext context) {
        var action = new CopyFileAction();
        action.execute(context);
    }
}

} // namespace
