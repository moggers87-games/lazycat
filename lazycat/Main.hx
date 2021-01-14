package lazycat;

import lazycat.Constants.BigFontNumbers;
import lazycat.Constants.Controls;
import lazycat.Constants.ImageSizes;
import lazycat.Constants.SmallFontNumbers;
import lazycat.Constants.TextStrings;

class Main extends hxd.App {

	var assets:Assets;
	var menuItems:Array<h2d.Interactive>;
	var menuIdx:Int;
	var titleText:h2d.Text;

	public function new(assets:Assets) {
		super();
		this.assets = assets;
		menuItems = [];
		menuIdx = -1;

		var window:hxd.Window = hxd.Window.getInstance();
		window.title = TextStrings.title;
	}

	override function init() {
		s2d.scaleMode = h2d.Scene.ScaleMode.LetterBox(ImageSizes.screenWidth, ImageSizes.screenHeight);
		s2d.addEventListener(keyboardControl);
		assets.initFonts();

		titleText = new h2d.Text(assets.bigFont);
		titleText.text = TextStrings.title;
		titleText.textColor = BigFontNumbers.colour;
		titleText.dropShadow = {
			dy: BigFontNumbers.dropShadowY,
			dx: BigFontNumbers.dropShadowX,
			color: BigFontNumbers.dropShadowColour,
			alpha: 1
		};
		s2d.addChild(titleText);
		titleText.x = ImageSizes.screenWidth / 2 - titleText.textWidth / 2;
		titleText.y = ImageSizes.screenHeight / 2 - titleText.textHeight / 2;

		var startText:h2d.Text = addMenuItem(TextStrings.start, titleText.y + titleText.textHeight, startHandler);
		var instructionsText:h2d.Text = addMenuItem(TextStrings.instructions, startText.y + startText.textHeight, instructionsHandler);
		var creditsText:h2d.Text = addMenuItem(TextStrings.credits, instructionsText.y + instructionsText.textHeight, creditsHandler);
		#if sys
		addMenuItem(TextStrings.quit, creditsText.y + creditsText.textHeight, quitHandler);
		#end

		var versionText = new h2d.Text(assets.smallFont);
		versionText.text = TextStrings.version;
		versionText.textColor = SmallFontNumbers.colour;
		s2d.addChild(versionText);
		versionText.y = ImageSizes.screenHeight - versionText.textHeight;
	}

	function startHandler(event:hxd.Event) {
		new Game(assets);
	}

	function instructionsHandler(event:hxd.Event) {
		hxd.System.setNativeCursor(hxd.Cursor.Default);
		new TextScroller(assets, TextStrings.instructions, hxd.Res.instructions.entry.getText());
	}

	function creditsHandler(event:hxd.Event) {
		hxd.System.setNativeCursor(hxd.Cursor.Default);
		new TextScroller(assets, TextStrings.credits, hxd.Res.credits.entry.getText());
	}

	#if sys
	function quitHandler(event:hxd.Event) {
		hxd.System.setNativeCursor(hxd.Cursor.Default);
		assets.dispose();
		Sys.exit(0);
	}
	#end

	function keyboardControl(event:hxd.Event) {
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
		else if (Controls.MENUSELECT.contains(event.keyCode) && menuItem != null) {
			menuItem.onClick(event);
		}
		else {
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

	function addMenuItem(text, yPosition, callback):h2d.Text {
		var textObj = new h2d.Text(assets.smallFont);
		textObj.text = text;
		textObj.textColor = SmallFontNumbers.colour;
		s2d.addChild(textObj);
		textObj.x = ImageSizes.screenWidth / 2 - textObj.textWidth / 2;
		textObj.y = yPosition;

		var interaction = new h2d.Interactive(titleText.textWidth,
												textObj.textHeight,
												textObj);
		menuItems.push(interaction);
		interaction.onOver = function(event:hxd.Event) {
			menuIdx = menuItems.indexOf(interaction);
			textObj.textColor = SmallFontNumbers.selectColour;
		}
		interaction.onOut = function(event:hxd.Event) {
			textObj.textColor = SmallFontNumbers.colour;
		}
		interaction.onClick = callback;

		return textObj;
	}

	static function main() {
		hxd.Res.initEmbed();
		new Main(new Assets());
	}
}
