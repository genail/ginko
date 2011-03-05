namespace Ginko.Util {
    
class AsyncTask {
    public delegate void Runnable(AsyncTask async_task);
    
    /** To keep reference to owner object of runnable method. Destruction might cause SIGSEGV */
    private Object m_runnable_owner;
    private Runnable m_runnable;
    
    private Queue<Object> m_storage = new Queue<Object>();
    
    private Mutex m_free_mutex = new Mutex();
    private Cond m_free_cond = new Cond();
    
    private bool m_parent_freed = false;
    
    public void push(Object p_variant) {
        m_storage.push_tail(p_variant);
    }
    
    public Object get() {
        return m_storage.pop_head();
    }
    
    private void free_parent() {
        m_free_mutex.lock();
        m_free_cond.broadcast();
        m_free_mutex.unlock();
    }
    
    public unowned Thread run(Runnable p_runnable, Object p_owner) {
        if (!Thread.supported()) {
            error("Threading not supported!");
        }
        
        m_runnable_owner = p_owner;
        m_runnable = p_runnable;
        
        unowned Thread thread = Thread.create<void*>(this.thread_func, false);
        
        m_free_mutex.lock();
        m_free_cond.wait(m_free_mutex); // wait to free_parent to be called
        m_parent_freed = true;
        m_free_mutex.unlock();
        
        return thread;
    }
    
    private void* thread_func() {
        var async_task = this;
        free_parent();
        
        m_runnable(async_task);
        
        if (!m_parent_freed) {
            warning("Parent not freed until yet. Did you forget to call free_parent()?");
        }
        
        return null;
    }
}

} // namespace
