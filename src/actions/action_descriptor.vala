namespace Ginko {

public abstract class ActionDescriptor : Object {
    public string name { get; private set; }
    public string[] keywords { get; private set; }
    public Accelerator accelerator { get; private set; }
    
    public ActionDescriptor(string name, string[] keywords, Accelerator accelerator) {
        this.name = name;
        this.keywords = keywords;
        this.accelerator = accelerator;
    }
    
    public abstract void execute(ActionContext context);
}

} // namespace
