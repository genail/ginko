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
            var icon = Files.find_icon_for_file(file, default_icon_theme, 64);
            var image_widget = new Image.from_pixbuf(icon);
            hbox.pack_start(image_widget);
            
            var vbox = new VBox(false, 0);
            hbox.pack_start(vbox);
            
            var file_path = file.get_path();
            
            var size = Files.query_size(file);
            var size_formatter = new SizeFormat();
            size_formatter.method = SizeFormat.Method.HUMAN_READABLE;
            var formatted_size = size_formatter.format(size);
            
            var modtime = Files.query_modification_time(file);
            var time_formatter = new TimeFormat();
            var formatted_time = time_formatter.format(modtime);
            
            var label = new Label("");
            label.set_markup(@"<b>$file_path</b>\n<i>size:</i> $formatted_size\n"
                + @"<i>modified:</i> $formatted_time");
            label.set_alignment(0, 0);
            vbox.pack_start(label);
            
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
        add_button(Stock.CANCEL, ResponseType.CANCEL);
        add_button("Rename", 2);
        add_button("Overwrite", 3).grab_focus();
        
        show_all();
    }
}
    
} // namespace
