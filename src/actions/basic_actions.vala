namespace Ginko.Actions {

// set of very basic and quick actions (few lines of code)
class RefreshActionDescriptor : ActionDescriptor {
    public RefreshActionDescriptor() {
        base(
            "Refresh directory view",
            new string[] { "refresh", "reload", "show" },
            new Accelerator("R", new string[] { "ctrl" }));
    }
    
    public override void execute(ActionContext p_context) {
        p_context.m_active_controller.refresh();
    }
}

} // namespace
