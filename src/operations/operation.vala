namespace Ginko.Operations {

/**
 * Operation defines one single function that can be made on VFS.
 * Example of operation: move one file A to location B
 */
public interface Operation {
    
    /** @return cost of current operation usually in transfered bytes. */
    public abstract uint64 get_cost();
    
    /** Cancels current operation.
     * @return true if cancelled.
     */
    public abstract bool cancel();
}
    
} // namespace
