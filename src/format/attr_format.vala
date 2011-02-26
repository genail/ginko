namespace Ginko.Format {

class AttrFormat {
    private static const uint32 MASK_DIR = 16384;
    private static const uint32 MASK_OWN_READ = 256;
    private static const uint32 MASK_OWN_WRITE = 128;
    private static const uint32 MASK_OWN_EXEC = 64;
    private static const uint32 MASK_GRP_READ = 32;
    private static const uint32 MASK_GRP_WRITE = 16;
    private static const uint32 MASK_GRP_EXEC = 8;
    private static const uint32 MASK_OTH_READ = 4;
    private static const uint32 MASK_OTH_WRITE = 2;
    private static const uint32 MASK_OTH_EXEC = 1;
    
    public string format(uint32 p_mode) {
        string result = "";
        
        result += get_if("d", (bool) (p_mode & MASK_DIR));
        result += get_if("r", (bool) (p_mode & MASK_OWN_READ));
        result += get_if("w", (bool) (p_mode & MASK_OWN_WRITE));
        result += get_if("x", (bool) (p_mode & MASK_OWN_EXEC));
        result += get_if("r", (bool) (p_mode & MASK_GRP_READ));
        result += get_if("w", (bool) (p_mode & MASK_GRP_WRITE));
        result += get_if("x", (bool) (p_mode & MASK_GRP_EXEC));
        result += get_if("r", (bool) (p_mode & MASK_OTH_READ));
        result += get_if("w", (bool) (p_mode & MASK_OTH_WRITE));
        result += get_if("x", (bool) (p_mode & MASK_OTH_EXEC));
        
        return result;
    }
    
    private string get_if(string p_str, bool condition) {
        if (condition) {
            return p_str;
        } else {
            return "-";
        }
    }
}
    
}
