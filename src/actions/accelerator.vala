using Gtk;
using Gdk;

class Accelerator {
    // FIXME: bind from GDK_VoidSymbol
    private const int VoidSymbol = 0xffffff;
    
    public uint keyval;
    public ModifierType modifier_type;
    
    public Accelerator(string keystr, string[]? mods) {
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
