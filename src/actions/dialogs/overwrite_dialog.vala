using Gtk;
using Ginko.IO;
using Ginko.Format;

namespace Ginko.Dialogs {

public class OverwriteDialog : AbstractDialog {
    
    private class FileButton : Button {
        public FileButton(File file) {
            set_relief(ReliefStyle.NONE);
            
            var hbox = new HBox(false, 2);
            add(hbox);
            
            var default_icon_theme = IconTheme.get_default();
            var icon = Files.find_icon_for_file(file, default_icon_theme, 48);
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
            var size_formatter = new SizeFormat();
            size_formatter.method = SizeFormat.Method.HUMAN_READABLE;
            var formatted_size = size_formatter.format(size);
            var size_label = new Label(@"size: $formatted_size"); // FIXME: format size
            size_label.set_alignment(0, 0);
            vbox.pack_start(size_label);
            
            // TODO: modification date
            var modtime = Files.query_modification_time(file);
            var time_formatter = new TimeFormat();
            var formated_time = time_formatter.format(modtime);
            var moddate_label = new Label("modified: " + formated_time);
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
        
        set_primary_label_text("Overwrite file \"<b>filename.ext</b>\"?");
        
        var file_button_source = new FileButton(File.new_for_path("/var"));
        var arrow = new Arrow(ArrowType.RIGHT, ShadowType.NONE);
        var file_button_dest = new FileButton(File.new_for_path("/etc"));
        
        var check_button_box = new HButtonBox();
        check_button_box.set_layout(ButtonBoxStyle.START);
        
        var apply_to_all_check = new CheckButton.with_mnemonic("Apply to _all");
        check_button_box.add(apply_to_all_check);
        
        var hbox = new HBox(false, 12);
        content.pack_start(hbox);
        
        hbox.pack_start(file_button_source);
        hbox.pack_start(arrow);
        hbox.pack_start(file_button_dest);
        
        content.pack_start(check_button_box);
        
        // why this may be not null-terminated? and crash when it is?
        add_buttons(Stock.CANCEL, ResponseType.CANCEL, "Rename", 2, "Overwrite", 3); 
        
        show_all();
    }
}
    
}
