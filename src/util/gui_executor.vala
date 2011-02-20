namespace Ginko {
public class GuiExecutor {
    public delegate void Method();
    
    private static Mutex m_mutex = new Mutex();
    private static Cond m_finished = new Cond();
    
    public static void run(owned Method p_method) {
        Idle.add(() => {
                p_method();
                return false;
        });
    }
    
    public static void run_and_wait(owned Method p_method) {
        typeof(GuiExecutor).class_ref(); // static fields fix
        
        m_mutex.lock();
        run(() => {
                p_method();
                
                m_mutex.lock();
                m_finished.broadcast();
                m_mutex.unlock();
        });
        
        // wait for broadcast
        m_finished.wait(m_mutex);
        m_mutex.unlock();
    }
}
}
