import event;
import std.algorithm;
import std.string;

class EventDatabase {
public:
	this() {

	}

	void load() {
		import std.file;

		if (!exists(CONFIG_DIR)) {
			mkdir(CONFIG_DIR);
		}

		if (!exists(CONFIG_FILE)) {
			return;
		}

		string contents = readText(CONFIG_FILE);

		assert(this.events == []);

		// Parse file...
		foreach (line; contents.lineSplitter) {
			this.events ~= new Event(line);
		}
	}

	void save() {
		import std.file;
		string output;

		foreach (Event e; events) {
			output ~= e.getName() ~ "\n";
		}

		std.file.write(CONFIG_FILE, output);
	}

	public Event[] getEvents() {
		return events;
	}

	public void addNewEvent(string eventName) {
		events ~= new Event(eventName);
	}


private:
	static enum CONFIG_DIR  = "/home/baedert/.config/dailies/";
	static enum CONFIG_FILE = CONFIG_DIR ~ "event.dailies";

	private Event[] events;
}
