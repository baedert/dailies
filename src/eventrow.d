import gtk.ListBox;
import gtk.ListBoxRow;
import gtk.Box;
import gtk.Label;
import gtk.CheckButton;

import gtkutils;
import event;

enum ui = q{
	ListBoxRow this {
		.Activatable = false
		#style = event-row
		Box {
			|orientation = Orientation.HORIZONTAL
			|spacing = 24
			CheckButton doneButton {

			}
			Label nameLabel {
				|label = ""

			}
		}
	}
};

class EventRow : ListBoxRow {
public:
	this(Event event) {
		mixin(uiInit(ui));

		nameLabel.setLabel(event.getName());
	}
private:
	mixin(uiMembers(ui));
}
