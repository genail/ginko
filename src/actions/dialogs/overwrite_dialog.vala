using Gtk;
using Ginko.IO;

namespace Ginko.Dialogs {

public class OverwriteDialog : Dialog {
    
    private class FileButton : Button {
        public FileButton(File file) {
            var hbox = new HBox(false, 0);
            add(hbox);
            
            var default_icon_theme = IconTheme.get_default();
            var icon = Files.find_icon_for_file(file, default_icon_theme);
            var image_widget = new Image.from_pixbuf(icon);
            hbox.pack_start(image_widget);
            
            var vbox = new VBox(false, 0);
            hbox.pack_start(vbox);
            
            var file_path = file.get_path();
            var name_label = new Label(file.get_path()); // FIXME: simplifier relative name
            name_label.set_markup(@"<b>$file_path</b>");
            name_label.set_alignment(0, 0);
            vbox.pack_start(name_label);
            
            var size = Files.query_size(file);
            var size_label = new Label(@"size: $size"); // FIXME: format size
            size_label.set_alignment(0, 0);
            vbox.pack_start(size_label);
            
            // TODO: modification date
            var moddate_label = new Label("modified: 13.02.2011 16:39");
            moddate_label.set_alignment(0, 0);
            vbox.pack_start(moddate_label);
            
            show_all();
        }
    }
    
    public OverwriteDialog(ActionContext context) {
        set_title(context.name + ": Overwrite file?");
        
        build_ui();
    }
    
    private void build_ui() {
        var vbox = new VBox(false, 0);
        (get_content_area() as Container).add(vbox);
        
        var desc_label = new Label("");
        desc_label.set_markup(
            "<span font_desc=\"14\">Overwrite file \"<b>filename.ext</b>\"?</span>");
        desc_label.set_alignment(0, 0);
        vbox.add(desc_label);
        
        var hbox = new HBox(false, 12);
        vbox.pack_start(hbox);
        
        var file_button_source = new FileButton(File.new_for_path("/var"));
        hbox.pack_start(file_button_source);
        
        var arrow = new Arrow(ArrowType.RIGHT, ShadowType.NONE);
        hbox.pack_start(arrow);
        
        var file_button_dest = new FileButton(File.new_for_path("/etc"));
        hbox.pack_start(file_button_dest);
        
        //var hseparator = new HSeparator();
        //vbox.pack_start(hseparator);
        
        var check_button_box = new HButtonBox();
        check_button_box.set_layout(ButtonBoxStyle.END);
        vbox.pack_start(check_button_box);
        
        var apply_to_all_check = new CheckButton.with_mnemonic("Apply to _all");
        check_button_box.add(apply_to_all_check);
        
        
        add_buttons(Stock.CANCEL, ResponseType.CANCEL, "Rename", 2, "Overwrite", 3);  // why this may be not null-terminated? and crash when it is?
        
        show_all();
    }
}
    
}
