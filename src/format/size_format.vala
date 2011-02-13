namespace Ginko.Format {

public class SizeFormat {
    
    private static const string POSTFIX_BYTE = "B";
    private static const string POSTFIX_KILOBYTE = "K";
    private static const string POSTFIX_MEGABYTE = "M";
    private static const string POSTFIX_GIGABYTE = "G";
    private static const string POSTFIX_TERABYTE = "T";
    private static const string POSTFIX_PETABYTE = "P";
    private static const string POSTFIX_EXABYTE = "E"; // that's as far as we can go using 64 bits
    
    private static const uint64 SIZE_KILOBYTE = 1024;
    private static const uint64 SIZE_MEGABYTE = SIZE_KILOBYTE * 1024;
    private static const uint64 SIZE_GIGABYTE = SIZE_MEGABYTE * 1024;
    private static const uint64 SIZE_TERABYTE = SIZE_GIGABYTE * 1024;
    private static const uint64 SIZE_PETABYTE = SIZE_TERABYTE * 1024;
    private static const uint64 SIZE_EXABYTE = SIZE_PETABYTE * 1024;
    
    private static const string[] POSTFIXES = {
        POSTFIX_BYTE,
        POSTFIX_KILOBYTE,
        POSTFIX_MEGABYTE,
        POSTFIX_GIGABYTE,
        POSTFIX_TERABYTE,
        POSTFIX_PETABYTE,
        POSTFIX_EXABYTE
    };
    
    private static const uint64[] SIZES = {
        0,
        SIZE_KILOBYTE,
        SIZE_MEGABYTE,
        SIZE_GIGABYTE,
        SIZE_TERABYTE,
        SIZE_PETABYTE,
        SIZE_EXABYTE
    };
    
    public enum Method {
        SEPERATED_BYTES, // e.g. 123 345 789
        HUMAN_READABLE   // e.g. 1,1 M
    }
    
    public Type method { get; set; default = Method.SEPERATED_BYTES; }
    
    public string format(uint64 size) {
        switch (method) {
            case Method.SEPERATED_BYTES:
                return format_seperated_bytes(size);
            case Method.HUMAN_READABLE:
                return format_human_readable(size);
            default:
                error("unknown type");
        }
    }
    
    private string format_seperated_bytes(uint64 file_size) {
        if (file_size == 0) {
            return "0";
        }

        string result = "";
        
        while (file_size > 0) {
            uint64 rest = file_size % 1000;
            
            if (result.length != 0) {
                result = " " + result;
            }
            
            result = rest.to_string() + result;
            file_size /= 1000;
        }
        
        return result;
    }
    
    private string format_human_readable(uint64 file_size) {
        if (file_size == 0) {
            return "0 " + POSTFIX_BYTE;
        }
        
        for (int i = SIZES.length - 1; i >= 0; --i) {
            var checked_size = SIZES[i];
            
            if (file_size > checked_size) {
                var postfix = POSTFIXES[i];
                return to_human_readable(file_size, checked_size, postfix);
            }
        }
        
        assert(false); // should not be reached
        return "";
    }
    
    private string to_human_readable(uint64 file_size, uint64 base_size, string postfix) {
        if (base_size == 0) {
            return @"$file_size $postfix";
        }
        
        double h_size = file_size / (double) base_size;
        var builder = new StringBuilder();
        builder.printf("%.1f %s", h_size, postfix);
        
        return builder.str;
    }
}
    
}
