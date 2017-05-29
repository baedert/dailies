import gtk.ListBox;
import gtk.ListBoxRow;
import gtk.Box;
import gtk.Label;
import gtk.Button;
import gtk.Image;
import gtk.Stack;
import gtk.CheckButton;
import gtk.Widget;

import cairo.Context;

import gtkutils;
import event;
import eventdatabase;

enum ui = q{
	ListBoxRow this {
		.Activatable = false
		#style = event-row
		Stack stack {
			.TransitionType = StackTransitionType.SLIDE_UP_DOWN
			Box defaultBox {
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
				Label ratioLabel {
					|label = ""
					#style = dim-label
				}
				Button menuButton {
					Image {
						.FromIconName = "open-menu-symbolic", IconSize.BUTTON
					}
				}
			}

			Box menuBox {
				|orientation = Orientation.HORIZONTAL
				|spacing = 12
				Button deleteButton {
					Image {
						.FromIconName = "user-trash-symbolic", IconSize.BUTTON
					}
				}
				Button renameButton {
					.Label = "Rename"
				}
				Button statsButton {
					.Label = "Statistics"
					.Hexpand = true
					.Halign = Align.START
				}
				Button backButton {
					.Label = "Back"
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

		menuButton.addOnClicked((button) {
			stack.setVisibleChild(menuBox);
		});

		backButton.addOnClicked((button) {
			stack.setVisibleChild(defaultBox);
		});

		deleteButton.addOnClicked((button) {
			db.removeEvent(event);
			db.save();
			ListBox parent = cast(ListBox)this.getParent();
			parent.remove(this);
		});

		addOnDraw(&onDrawCb);
	}

	void updateStyleClasses() {
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

		import std.conv: to;
		this.ratioLabel.setLabel(to!string(event.getCheckedDays()) ~ " / " ~ to!string(event.getDays()));
	}
private:
	mixin(uiMembers(ui));
	Event event;

	bool onDrawCb(Scoped!Context ct, Widget w) {
		return false;
	}
}
