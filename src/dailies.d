import GApplication = gio.Application;
import GtkApplication = gtk.Application;
import gio.ApplicationCommandLine;
import gtk.CssProvider;
import gtk.StyleContext;
import gdk.Screen;

import mainwindow;

enum appCss = "
	popover {
		padding: 12px;
	}

	.event-row {
		border-bottom: 1px solid alpha(grey, 0.4);
		padding-top: 12px;
		padding-bottom: 12px;
		padding-right: 24px;
		padding-left: 24px;
		background-image: none;
	}

	.over-90 {
		background-color: #95ff99;
	}
	.over-75 {
		background-color: #c184ff;
	}
	.over-50 {
		background-color: #84a2ff;
	}
	.over-25 {
		background-color: #ffc484;
	}
	.over-00 {
		background-color: #ff8c84;
	}
";


class Dailies : GtkApplication.Application {
public:
	this() {
		super("org.baedert.dailies", cast(ApplicationFlags)0);
		this.addOnStartup(&startup);
		this.addOnActivate(&activate);
	}
private:
	void startup(GApplication.Application app) {
		// Apply application CSS
		auto provider = new CssProvider();
		provider.loadFromData(appCss);
		StyleContext.addProviderForScreen(Screen.getDefault(),
		                                  provider,
		                                  600); // PRIORITY_APPLICATION
	}

	void activate(GApplication.Application app) {
		auto window = new MainWindow(this);

		this.addWindow(window);
		window.showAll();
	}
}


