import gtk.ListBox;
import gtk.ListBoxRow;
import gtk.Box;
import gtk.Label;
import gtk.Button;
import gtk.Image;
import gtk.CheckButton;

import gtkutils;
import event;
import eventdatabase;

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
				.Hexpand = true
				.Halign = Align.START
				.Xalign = 0
			}
			Button {
				Image {
					.FromIconName = "open-menu-symbolic", IconSize.BUTTON
				}
			}
		}
	}
};

class EventRow : ListBoxRow {
public:
	this(Event event, EventDatabase db) {
		mixin(uiInit(ui));
		this.event = event;

		updateStyleClasses();

		nameLabel.setLabel(event.getName());
		doneButton.setActive(event.todayChecked());
		doneButton.addOnToggled((cb) {
			event.check();
			db.save();
			updateStyleClasses();
		});
	}

	public void updateStyleClasses() {
		float p = event.getPercentage();
		string[] classes = ["over-90", "over-75", "over-50", "over-25", "over-00"];
		foreach(c; classes)
			getStyleContext().removeClass(c);

		if (p > 0.9) {
			getStyleContext().addClass("over-90");
		} else if (p > 0.75) {
			getStyleContext().addClass("over-75");
		} else if (p > 0.50) {
			getStyleContext().addClass("over-50");
		} else if (p > 0.25) {
			getStyleContext().addClass("over-25");
		} else {
			getStyleContext().addClass("over-00");
		}
	}
private:
	mixin(uiMembers(ui));
	Event event;
}
