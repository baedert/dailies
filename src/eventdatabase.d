import event;
import std.algorithm;
import std.string;
import std.array;

class EventDatabase {
public:
	this() {

	}

	void load() {
		import std.file;
		import std.conv: to;
		import std.datetime;
		import std.range;
		import std.stdio;

		if (!exists(CONFIG_DIR)) {
			mkdir(CONFIG_DIR);
		}

		if (!exists(CONFIG_FILE)) {
			return;
		}

		string contents = readText(CONFIG_FILE);

		assert(this.events == []);

		// Parse file...
		auto lines = contents.lineSplitter();
		while (!lines.empty) {
			this.events ~= new Event(lines.front);
			lines.popFront();
			// Now a times line
			SysTime[] times = lines.front()
			                       .split(",")
			                       .map!(a => SysTime.fromUnixTime(to!long(a)))
			                       .array;
			this.events[$ - 1].setCheckedTimes(times);
			lines.popFront();
		}
	}

	void save() {
		import std.file;
		import std.stdio;
		import std.conv: to;
		string output;

		foreach (Event e; events) {
			output ~= e.getName() ~ "\n";
			output ~= (e.getCheckedTimes()
			                        .map!(a => to!string(a.toUnixTime()))
			                        .join(',')
			                        .array.to!string) ~ "\n";
		}

		auto f = File(CONFIG_FILE, "w");
		f.write(output);
		f.close();
	}

	public Event[] getEvents() {
		return events;
	}

	public Event addNewEvent(string eventName) {
		Event e = new Event(eventName);
		events ~= e;
		return e;
	}

	public void removeEvent(Event e) {
		int offset = 0;
		foreach (event; events) {
			if (e == event) {
				break;
			}
			offset ++;
		}

		this.events = std.algorithm.remove(events, offset);
	}

private:
	static enum CONFIG_DIR  = "/home/baedert/.config/dailies/";
	static enum CONFIG_FILE = CONFIG_DIR ~ "dailies.txt";

	private Event[] events;
}
