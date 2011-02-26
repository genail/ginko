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
        p_context.active_controller.refresh();
    }
}

class ToggleHiddenFilesActionDescriptor : ActionDescriptor {
    public ToggleHiddenFilesActionDescriptor() {
        base(
            "Show / hide hidden files",
            new string[] { "show", "hide", "hidden" },
            new Accelerator("H", new string[] { "ctrl" }));
    }
    
    public override void execute(ActionContext p_context) {
        var settings = Settings.get();
        var show_hidden_files = settings.is_show_hidden_files();
        settings.set_show_hidden_files(!show_hidden_files);
    }
}

class OpenTerminalActionDescriptor : ActionDescriptor {
    public OpenTerminalActionDescriptor() {
        base(
            "Open terminal in current directory",
            new string[]{"terminal"},
            new Accelerator("F9", null));
    }
    
    public override void execute(ActionContext p_context) {
        Process.spawn_command_line_async("gnome-terminal" + " --working-directory=" + 
            p_context.source_dir.get_path());
    }
}

} // namespace
