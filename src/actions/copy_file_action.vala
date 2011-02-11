class CopyFileAction : Action {
    public CopyFileAction() {
        base(
            "Copy files",
            new string[] { "copy", "file", "files" },
            new Accelerator("F5", null));
    }
    
    public override void execute(ActionContext context) {
        debug("copy files executed");
        
        var confdialog = new CopyFileActionConfigureDialog(context);
        confdialog.run();
    }
}
