namespace Ginko.Operations {

class CopyFileOperation : Operation {
    public static const int FAIL_REASON_NONE = 0;
    public static const int FAIL_REASON_NOT_EXISTS = 1;
    public static const int FAIL_REASON_OVERWRITE = 2;
    public static const int FAIL_REASON_PERMISSIONS = 3;
    public static const int FAIL_REASON_MISSING = 4;
    public static const int FAIL_REASON_UNKNOWN = 5;
    
    public File source;
    public File destination;
    public bool overwrite;
    
    private int fail_reason;
    private string fail_reason_text;
    
    public bool check_if_possible() {
        try {
            if (!source.query_exists()) {
                fail_reason = FAIL_REASON_NOT_EXISTS;
                return false;
            }
            
            if (destination.query_exists()) {
                if (!overwrite) {
                    fail_reason = FAIL_REASON_OVERWRITE;
                    return false;
                }
                
                if (!can_read(source) || !can_write(destination)) {
                    fail_reason = FAIL_REASON_PERMISSIONS;
                    return false;
                }
            } else {
                if (!destination.has_parent(null)) {
                    fail_reason = FAIL_REASON_MISSING;
                    return false;
                }
                
                var destination_parent = destination.get_parent();
                if (!can_write(destination_parent)) {
                    fail_reason = FAIL_REASON_PERMISSIONS;
                    return false;
                }
            }
            
            return true;
        } catch (Error e) {
            fail_reason = FAIL_REASON_UNKNOWN;
            fail_reason_text = e.message;
            return false;
        }
    }
    
    public long get_cost() {
        return 0;
    }
    
    public int get_fail_reason() {
        return fail_reason;
    }
    
    public string get_fail_reason_text() {
        return fail_reason_text;
    }
    
    public bool execute() {
        if (Config.debug) {
            // on dry run only run possibilities check
            return check_if_possible();
        }
        
        return false;
    }
    
    private bool can_read(File file) throws Error {
        var info = file.query_info(FILE_ATTRIBUTE_ACCESS_CAN_READ, 0, null);
        return info.get_attribute_boolean(FILE_ATTRIBUTE_ACCESS_CAN_READ);
    }
    
    private bool can_write(File file) throws Error {
        var info = file.query_info(FILE_ATTRIBUTE_ACCESS_CAN_WRITE, 0, null);
        return info.get_attribute_boolean(FILE_ATTRIBUTE_ACCESS_CAN_WRITE);
    }
    
    private uint64 get_size(File file) throws Error {
        var info = file.query_info(FILE_ATTRIBUTE_STANDARD_SIZE, 0, null);
        return info.get_attribute_uint64(FILE_ATTRIBUTE_STANDARD_SIZE);
    }
}

} // namespace
