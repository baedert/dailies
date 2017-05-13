import std.stdio;
import std.string;
import std.algorithm;
import std.conv;

import gtk.Bin;

string uiMembers(const string ui_data) {
	return __generate_ui (ui_data, true);
}

string uiInit(const string ui_data) {
	return __generate_ui(ui_data, false);
}


private string __generate_ui(const string ui_data, bool just_members = false) {
	immutable char EOF = cast(char)255;
	string result;
	auto input = ui_data.strip();
	int pos = 0;
	char c = input[0];
	string ident = null;
	string[string] objectIds;

	struct ChildInfo {
		string childType;
		string id;
	}

	uint irrelevant_id = 0;
	string get_irrelevant_ident() {
		return "__object__" ~ to!string(irrelevant_id ++);
	}

	pure
	bool separates(char c) {
		return ['{', '}', '=', ' ', '\n', '\t', '|'].canFind(c);
	}

	pure @nogc
	void advance() {
		if (pos < input.length - 1) {
			pos ++;
			c = input[pos];
		} else {
			c = EOF;
		}
	}

	pure @nogc
	void skipWhitespace() {
		while (c == ' ' || c == '\t' || c == '\n') {
			advance();
		}
	}

	pure
	void next() {
		if (pos >= input.length) {
			c = EOF;
			ident = [EOF];
			return;
		}

		skipWhitespace();
		ident = "";
		int i = 0;
		do {
			ident ~= c;
			advance();
			i ++;
		}
		while (!separates(c) && pos < input.length - 1 );

		skipWhitespace();
	}

	void expect(string e, int line = __LINE__) {
		if (ident != e) {
			if (!__ctfe)
				  writeln ("Expected ", e, ", but found ", ident, " at pos ", pos, " from line ", line);
			assert(ident == e);
		}
	}

	pure
	string getUntil(char _c) {
		string result;
		while (c != _c && c != EOF) {
			result ~= c;
			advance();
		}
		return result;
	}

	ChildInfo parseObject (bool toplevel = false) {
		ChildInfo childInfo;
		string objectType = ident;
		string objectId = null;
		next();
		if (ident != "{") {
			// Read object ID (optional!)
			childInfo.id = ident;
			next();
			if (!toplevel)
				objectIds[childInfo.id] = objectType;
		} else {
			childInfo.id = get_irrelevant_ident();
		}

		if (ident != "{") {
			// child type
			assert(ident[0] == '$');
			childInfo.childType = ident[1..$];
			next();
		}

		if (toplevel)
			assert(childInfo.id == "this");

		string[string] constructProps;
		string[string] nonConstructProps;
		string[] styleClasses;
		expect("{");
		next();
		while (ident[0] == '.' || ident[0] == '|' || ident[0] == '#') {
			if (ident[0] == '#') {
				// Style classes
				next();
				expect("=");
				string classesStr = getUntil('\n').strip();
				styleClasses = classesStr.split(',');
			} else {
				bool construct = (ident[0] == '|');
				string prop_name = ident;
				next();
				expect("=");
				string prop_value = getUntil('\n').strip();
				if (construct) {
					constructProps[prop_name[1..$]] = prop_value;
				} else {
					nonConstructProps[prop_name[1..$]] = prop_value;
				}
			}

			next();
		}


		if (!toplevel) {
			// Generate the declaration
			if (!just_members && childInfo.id in objectIds)
				result ~= childInfo.id ~ " = new " ~ objectType ~ "(";
			else
				result ~= objectType ~ " " ~ childInfo.id ~ " = new " ~ objectType ~ "(";

			// This will leave a trailing comma but whatever
			foreach (prop_name; constructProps.keys) {
				result ~= constructProps[prop_name] ~ ", ";
			}
			result ~= ");\n";
		} else {
			result ~= "super(";
			foreach (foo; constructProps.keys) {
				result ~= constructProps[foo] ~ ", ";
			}
			result ~= ");\n";
		}

		foreach (prop_name; nonConstructProps.keys) {
			result ~= childInfo.id ~ ".set" ~ prop_name ~ "(" ~ nonConstructProps[prop_name] ~ ");\n";
		}
		foreach (c; styleClasses) {
			result ~= childInfo.id ~ ".getStyleContext().addClass(\"" ~ c.strip() ~ "\");\n";
		}

		while (ident != "}") { // until this object ends
			auto child = parseObject();
			if (child.childType !is null)
				result ~= childInfo.id ~ ".set" ~ child.childType ~ "(" ~ child.id ~ ");\n";
				//result ~= childInfo.id ~ ".setTitlebar(" ~ child.id ~ ");\n";
			else
				result ~= childInfo.id ~ ".add(" ~ child.id ~ ");\n";
		}

		next();

		return childInfo;
	}

	// Kick off
	next();
	// Parse toplevel obj
	parseObject(true);

	// We simply do both things in both cases...
	if (just_members) {
		string member_result;
		foreach (m; objectIds.keys) {
			if (m != "this")
				member_result ~= objectIds[m] ~ " " ~ m ~ ";\n";
		}
		return member_result;
	}

	return result;
}

unittest {
	string s = __generate_ui("Box this{}");
	//writeln(s);
	assert(s.strip == "super();"); // empty object, no properties, ...

	string s2 = __generate_ui("Box this{|spacing = 12\n|foo = \"bla\"\n}");
	//writeln(s2);
	assert(s2.strip() == "super(12, \"bla\", );");

	string s3 = __generate_ui("Box this{|spacing = 12\n|foo = _(\"bla\")\n}");
	assert(s3.strip() == "super(12, _(\"bla\"), );");

	// child with type
	string s4 = __generate_ui("Box this{|spacing = 12\n|foo = _(\"bla\")\nButton btn $titlebar {\n.l = 4\n}\n}");
}
