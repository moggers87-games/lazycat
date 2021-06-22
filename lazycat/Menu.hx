package lazycat;

import lazycat.Constants.Controls;

class Menu {

	var menuItems:Array<h2d.Interactive>;
	var menuIdx:Int;

	public function new() {
		menuItems = [];
		menuIdx = -1;
	}

	public function addItem(interaction:h2d.Interactive) {
		menuItems.push(interaction);
	}

	public function pick(interaction:h2d.Interactive) {
		var oldItem:h2d.Interactive = menuItems[menuIdx];
		if (oldItem != null) {
			oldItem.onOut(new hxd.Event(EOut));
		}
		menuIdx = menuItems.indexOf(interaction);
	}

	public function keyboardControl(event:hxd.Event) {
		if (event.kind != EKeyDown) {
			return;
		}
		var newIndex:Int = menuIdx;
		var menuItem:h2d.Interactive = menuItems[menuIdx];
		if (Controls.MOVEUP.contains(event.keyCode)) {
			newIndex -= 1;
		}
		else if (Controls.MOVEDOWN.contains(event.keyCode)) {
			newIndex += 1;
		}
		else if (menuItem != null) {
			menuItem.onKeyDown(event);
			return;
		}

		if (newIndex < 0) {
			newIndex = 0;
		}
		else if (newIndex >= menuItems.length) {
			newIndex = menuItems.length - 1;
		}
		var oldItem:h2d.Interactive = menuItems[menuIdx];
		if (oldItem != null) {
			oldItem.onOut(new hxd.Event(EOut));
		}
		menuIdx = newIndex;
		menuItems[menuIdx].onOver(new hxd.Event(EOver));
	}
}
