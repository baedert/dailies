import std.datetime;

class Event {
public:
	this(string name) {
		this.name = name;
	}

	string getName() {
		return name;
	}

	SysTime[] getCheckedTimes() {
		return checked;
	}

	// Returns the amount of days considered in getPercentage()s

	int getDays() {
		import std.algorithm;
		if (checked.length == 0) {
			// Still consider today
			return 1;
		}
		auto now = Clock.currTime();
		// Consider at most 14 days, but not if the event
		// is not even 14 days old...
		// So: 14 days from the day it has first been checked
		auto result = min (14, (now - checked[0]).total!"days");

		assert(result >= 0);
		return cast(int)result;
	}

	int getCheckedDays() {
		import std.stdio;
		import std.algorithm: min;
		auto now = Clock.currTime();
		int nChecked = 0;
		auto nTimes = this.getDays();

		if (nTimes == 0)
			return 0;

		for (ulong i = 0; i < min(checked.length, nTimes); i ++) {
			// Only check times in the last 14 days
			if ((now - checked[$ - 1 - i]) > days(14))
				break;

			nChecked++;
		}

		return nChecked;
	}

	// We check how often the event was checked in the last 14 days
	// and return the percentage.
	float getPercentage() {
		return cast(float)getCheckedDays() / cast(float)getDays();
	}

	void check(bool status) {
		auto now = Clock.currTime();

		if (status) {
			if (checked.length > 0 && checked[$ - 1].day == now.day) {
				return;
			}
			// Add the current day to the list of
			// days this even has been checked
			this.checked ~= now;
		} else {
			import std.algorithm;
			// Uncheck
			if (checked.length > 0 && checked[$ - 1].day == now.day) {
				this.checked = std.algorithm.remove(this.checked, this.checked.length - 1);
			}
		}
	}

	void setCheckedTimes(SysTime[] times) {
		this.checked = times;
	}

	bool todayChecked() {
		if (checked.length == 0)
			return false;

		// Just comparing the days here is fine, even if they turn around on months
		// because we only track events over 14 days and that's not enough for it to matter.
		auto now = Clock.currTime();
		if (checked[$ - 1].day == now.day)
			return true;

		return false;
	}

private:
	string name;
	SysTime[] checked;
}
