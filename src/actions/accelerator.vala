using Gtk;
using Gdk;

namespace Ginko {

public class Accelerator {
    // FIXME: bind from GDK_VoidSymbol
    private const int VoidSymbol = 0xffffff;
    
    public static bool equal(Accelerator p_a, Accelerator p_b) {
        if (p_a.keyval != p_b.keyval) {
            return false;
        }
        
        if (p_a.modifier_type != p_b.modifier_type) {
            return false;
        }
        
        return true;
    }
    
    public static uint hash(Accelerator p_obj) {
        uint h = 1;
        h = h * 31 + p_obj.keyval;
        h = h * 31 + p_obj.modifier_type;
        return h;
    }
    
    public uint keyval;
    public ModifierType modifier_type;
    
    public Accelerator(string keystr, string[]? mods = null) {
        keyval = Gdk.keyval_from_name(keystr);
        if (keyval == VoidSymbol) {
            error("unknown key symbol: %s", keystr);
        }
        
        ModifierType modifier = 0;
        if (mods != null) {
            foreach (var mod in mods) {
                modifier |= modifier_from_string(mod);
            }
        }
        
        modifier_type = modifier;
        
    }
    
    private ModifierType modifier_from_string(string modstr) {
        switch (modstr) {
            case "ctrl":
                return ModifierType.CONTROL_MASK;
            case "shift":
                return ModifierType.SHIFT_MASK;
            case "alt":
                return ModifierType.MODIFIER_MASK;
            case "super":
                return ModifierType.SUPER_MASK;
            default:
                error("unknown modifier: %s", modstr);
        }
    }
}

} // namespace
