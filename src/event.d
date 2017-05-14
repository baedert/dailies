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

	// Returns the amount of days considered in getPercentage()
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
		return min (14, now.day - checked[0].day + 1);
	}

	int getCheckedDays() {
		import std.stdio;
		import std.algorithm: min;
		auto now = Clock.currTime();
		int nChecked = 0;
		auto nTimes = this.getDays();

		if (nTimes == 0)
			return 0;

		// TODO: getDays() uses the difference of two weekdays,
		//       so it will break when weeks or months wrap...

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

	void check() {
		auto now = Clock.currTime();
		if (checked.length > 0 && checked[$ - 1].day == now.day) {
			return;
		}
		// Add the current day to the list of
		// days this even has been checked
		this.checked ~= now;
	}

	void setCheckedTimes(SysTime[] times) {
		this.checked = times;
	}

	bool todayChecked() {
		if (checked.length == 0)
			return false;

		auto now = Clock.currTime();
		if (checked[$ - 1].day == now.day)
			return true;

		return false;
	}

private:
	string name;
	SysTime[] checked;
}
