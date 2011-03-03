namespace Ginko {

public abstract class ActionDescriptor : Object {
    public string name { get; private set; }
    public string[] keywords { get; private set; }
    public Accelerator accelerator { get; private set; }
    
    public ActionDescriptor(string p_name, string[] p_keywords, Accelerator p_accelerator) {
        name = p_name;
        keywords = p_keywords;
        accelerator = p_accelerator;
    }
    
    public abstract void execute(ActionContext p_context);
}

} // namespace
