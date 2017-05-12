import GApplication = gio.Application;
import GtkApplication = gtk.Application;
import gio.ApplicationCommandLine;
import gtk.CssProvider;
import gtk.StyleContext;
import gdk.Screen;

import mainwindow;

enum appCss = q{
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
		/* Light green */
		background-color: rgb(124,255,105);
	}
	.over-75 {

	}
	.over-50 {

	}
	.over-25 {

	}
	.over-00 {
		background-color: red;
	}
};


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


