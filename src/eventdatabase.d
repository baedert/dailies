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

		string configDir = getConfigDir();
		string configFile = getConfigFile();

		// TODO: Doing this is racy but I couldn't care less.
		if (!exists(configDir)) {
			mkdir(configDir);
		}

		if (!exists(configFile)) {
			return;
		}

		string contents = readText(configFile);

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
		string configFile = getConfigFile();
		string output;

		foreach (Event e; events) {
			output ~= e.getName() ~ "\n";
			output ~= (e.getCheckedTimes()
			                        .map!(a => to!string(a.toUnixTime()))
			                        .join(',')
			                        .array.to!string) ~ "\n";
		}

		auto f = File(configFile, "w");
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
	private Event[] events;
}

string getConfigDir() {
	version(windows) {
		static assert(0);
	} else {
		import std.path: expandTilde;
		return expandTilde("~/.config/dailies");
	}
}

string getConfigFile() {
	return getConfigDir() ~ "/dailies.txt";
}
