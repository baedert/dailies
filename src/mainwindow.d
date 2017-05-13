import gtk.ApplicationWindow;
import gtk.Application;
import gtk.Box;
import gtk.HeaderBar;
import gtk.Button;
import gtk.Image;
import gtk.ListBox;
import gtk.ScrolledWindow;
import gtk.Popover;
import gtk.Label;
import gtk.Entry;

import gtkutils;
import event;
import eventdatabase;
import eventrow;


enum ui = q{
	ApplicationWindow this {
		|app = app
		HeaderBar header_bar $titlebar {
			.ShowCloseButton = true
			.Title = "Dailies"
			Button addButton {
				Image {
					.FromIconName = "list-add-symbolic", IconSize.BUTTON
				}
			}
		}
		Box {
			|orientation = Orientation.VERTICAL
			|spacing = 0
			ScrolledWindow {
				.Hexpand = true
				.Vexpand = true
				ListBox eventListBox {
					.SelectionMode = SelectionMode.NONE
				}
			}
		}
	}
};

class MainWindow : ApplicationWindow {
public:
	this(Application app) {
		mixin(uiInit(ui));

		addButton.addOnClicked(&addButtonClicked);

		// Load events, insert them into the list
		eventDb = new EventDatabase();
		eventDb.load();
		foreach(Event e; eventDb.getEvents()) {
			eventListBox.add(new EventRow(e, eventDb));
		}

		this.resize(600, 400);
	}

private:
	mixin(uiMembers(ui));
	EventDatabase eventDb;

	void addButtonClicked(Button button) {
		// Construct a popover and show it.
		auto popover = new Popover(button);
		auto box = new Box(Orientation.HORIZONTAL, 12);
		box.add(new Label("Name:"));
		auto entry = new Entry();
		entry.setActivatesDefault(true);
		box.add(entry);
		auto submitButton = new Button("Save");
		submitButton.setReceivesDefault(true);
		submitButton.setCanDefault(true);
		popover.setDefaultWidget(submitButton);
		box.add(submitButton);

		submitButton.addOnClicked((button) {
			auto e = eventDb.addNewEvent(entry.getText());
			auto row =  new EventRow(e, eventDb);
			row.showAll();
			eventListBox.add(row);
			eventDb.save();
			popover.popdown();
		});


		box.showAll();
		popover.add(box);
		popover.popup();
	}
}
