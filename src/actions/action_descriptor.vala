namespace Ginko {

public abstract class ActionDescriptor : Object {
    public string m_name { get; private set; }
    public string[] m_keywords { get; private set; }
    public Accelerator m_accelerator { get; private set; }
    
    public ActionDescriptor(string p_name, string[] p_keywords, Accelerator p_accelerator) {
        m_name = p_name;
        m_keywords = p_keywords;
        m_accelerator = p_accelerator;
    }
    
    public abstract void execute(ActionContext p_context);
}

} // namespace
