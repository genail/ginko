class CopyFileAction : Action {
    public CopyFileAction() {
        base(
            "Copy files",
            new string[] { "copy", "file", "files" },
            new Accelerator("F5", null));
    }
}
