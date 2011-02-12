namespace Ginko {

/**
 * Operation defines one single function that can be made on VFS.
 * Example of operation: move one file A to location B
 */
public interface Operation {
    /** @return true if operation may be possible or false if not. @see get_fail_reason() */
    public abstract bool check_if_possible();
    
    /** @return cost of current operation usually in transfered bytes. */
    public abstract long get_cost();
    
    /** @return fail reason of check_if_possible() or execute(). */
    public abstract int get_fail_reason();
    
    /** @return fail reason text when fail reason is unknown. */
    public abstract string get_fail_reason_text();
    
    /** Executes current operation
      * @return true if it was finished with no errors, false when opposite.
      * @see check_fail_reason() */
    public abstract bool execute();
}
    
} // namespace
