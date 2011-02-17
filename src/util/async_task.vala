namespace Ginko.Util {
    
class AsyncTask {
    public delegate void Runnable(AsyncTask async_task);
    
    private Runnable m_runnable;
    private Queue<Object> m_storage = new Queue<Object>();
    
    private Mutex m_free_mutex = new Mutex();
    private Cond m_free_cond = new Cond();
    
    private bool m_parent_freed = false;
    
    public void push(Object variant) {
        m_storage.push_tail(variant);
    }
    
    public Object get() {
        return m_storage.pop_head();
    }
    
    public void free_parent() {
        m_free_mutex.lock();
        m_free_cond.broadcast();
        m_free_mutex.unlock();
    }
    
    public void run(Runnable p_runnable) {
        if (!Thread.supported()) {
            error("Threading not supported!");
        }
        
        m_runnable = p_runnable;
        
        Thread.create<void*> (this.thread_func, false);
        
        m_free_mutex.lock();
        m_free_cond.wait(m_free_mutex); // wait to free_parent to be called
        m_parent_freed = true;
        m_free_mutex.unlock();
    }
    
    private void* thread_func() {
        stdout.printf("async task\n");
        
        m_runnable(this);
        if (!m_parent_freed) {
            warning("Parent not freed until yet. Did you forget to call free_parent()?");
        }
        
        return null;
    }
}

} // namespace
