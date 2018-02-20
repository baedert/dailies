import std.datetime;

import gtk.ApplicationWindow;
import gtk.Application;
import gtk.Box;
import gtk.HeaderBar;
import gtk.Button;
import gtk.ToggleButton;
import gtk.Image;
import gtk.ListBox;
import gtk.ListBoxRow;
import gtk.ScrolledWindow;
import gtk.Popover;
import gtk.Label;
import gtk.Entry;
import gtk.Stack;
import gtk.Widget;

import GdkEvent = gdk.Event;

import gtkutils;
import event;
import eventdatabase;
import eventrow;


enum ui = q{
	ApplicationWindow this {
		|app = app
		HeaderBar header_bar $Titlebar {
			.ShowCloseButton = true
			.Title = "Dailies"
			ToggleButton addButton {
				Image {
					.FromIconName = "list-add-symbolic", IconSize.BUTTON
				}
			}

			Stack titleStack $CustomTitle {
				.TransitionType = StackTransitionType.SLIDE_LEFT_RIGHT

				Box addEventBox {
					|orientation = Orientation.HORIZONTAL
					|spacing = 12
					.Hexpand = true
					.Halign = Align.CENTER

					Entry eventNameEntry {
					}
					Button addEventButton {
						.Label = "Save"
						#style = suggested-action
					}
				}

				Label titleLabel {
					|label = "Dailies"
					.Visible = true
					#style = title
				}
			}
		}
		Box {
			|orientation = Orientation.VERTICAL
			|spacing = 0
			ScrolledWindow {
				.Hexpand = true
				.Vexpand = true
				.Policy = PolicyType.NEVER, PolicyType.NEVER
				.PropagateNaturalHeight = true
				ListBox eventListBox {
					.SelectionMode = SelectionMode.NONE
					Label pl $Placeholder {
						|label = "No events found"
						.Visible = true
					}
				}
			}
		}
	}
};

class MainWindow : ApplicationWindow {
public:
	this(Application app) {
		mixin(uiInit(ui));

		this.today = Clock.currTime();
		// Load events, insert them into the list
		eventDb = new EventDatabase();
		eventDb.load();
		foreach(Event e; eventDb.getEvents()) {
			eventListBox.add(new EventRow(e, eventDb));
		}

		addButton.addOnToggled(&addButtonToggled);
		addEventButton.addOnClicked(&addEventButtonClicked);

		this.addOnFocusIn(&updateDay);
		titleStack.setVisibleChild(titleLabel);
	}

private:
	mixin(uiMembers(ui));
	EventDatabase eventDb;
	SysTime today;

	void addButtonToggled(ToggleButton button) {
		if (button.getActive()) {
			titleStack.setVisibleChild(addEventBox);
			eventNameEntry.grabFocus();
		} else {
			titleStack.setVisibleChild(titleLabel);
		}
	}

	void addEventButtonClicked(Button button) {
		string eventName = eventNameEntry.getText();
		auto e = eventDb.addNewEvent(eventName);
		auto row =  new EventRow(e, eventDb);
		row.showAll();
		eventListBox.add(row);
		eventDb.save();
		titleStack.setVisibleChild(titleLabel);
	}

	  bool updateDay(GdkEvent.Event evt, Widget widget) {
		import std.stdio;
		auto now = Clock.currTime;
		writeln("Updating day. Now: ", now);

		if (now.day != today.day) {
			int i = 0;
			ListBoxRow row = eventListBox.getRowAtIndex(0);

			while (row !is null) {
				EventRow erow = cast(EventRow)row;

				erow.updateDay();

				i ++;
				row = eventListBox.getRowAtIndex(i);
			}

			this.today = now;
		}

		return false;
	}
}
