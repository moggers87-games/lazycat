package lazycat;

import lazycat.Constants.BigFontNumbers;
import lazycat.Constants.Controls;
import lazycat.Constants.ImageSizes;
import lazycat.Constants.MediumFontNumbers;
import lazycat.Constants.SmallFontNumbers;
import lazycat.Constants.TextStrings;

class Main extends hxd.App {

	var assets:Assets;
	var titleText:h2d.Text;
	var menu:Menu;

	public function new(assets:Assets) {
		super();
		this.assets = assets;
		menu = new Menu();

		var window:hxd.Window = hxd.Window.getInstance();
		window.title = TextStrings.title;
	}

	override function init() {
		s2d.scaleMode = h2d.Scene.ScaleMode.LetterBox(ImageSizes.screenWidth, ImageSizes.screenHeight);
		s2d.addEventListener(menu.keyboardControl);
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
		titleText.y = ImageSizes.screenHeight / 2 / 2 - titleText.textHeight / 2;

		var startText:h2d.Text = addMenuItem(TextStrings.start, titleText.y + titleText.textHeight, startHandler);
		var optionsText:h2d.Text = addMenuItem(TextStrings.options, startText.y + startText.textHeight, optionsHandler);
		var instructionsText:h2d.Text = addMenuItem(TextStrings.instructions, optionsText.y + optionsText.textHeight, instructionsHandler);
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
		new TextScroller(assets, TextStrings.instructions, gameUtils.FileMacro.getContent("lazycat/data/instructions.txt"));
	}

	function creditsHandler(event:hxd.Event) {
		hxd.System.setNativeCursor(hxd.Cursor.Default);
		var text:String = gameUtils.FileMacro.getContent("lazycat/data/credits.txt") +
		gameUtils.FileMacro.getContent("lazycat/data/creditsLazycat.txt") +
		gameUtils.FileMacro.getContent("lazycat/data/creditsSound.txt") +
		gameUtils.FileMacro.getContent("lazycat/data/creditsHaxe.txt") +
		#if hl
		gameUtils.FileMacro.getContent("lazycat/data/creditsHashlink.txt") +
		#end
		gameUtils.FileMacro.getContent("lazycat/data/creditsHeaps.txt");

		new TextScroller(assets, TextStrings.credits, text);
	}

	#if sys
	function quitHandler(event:hxd.Event) {
		hxd.System.setNativeCursor(hxd.Cursor.Default);
		assets.dispose();
		Sys.exit(0);
	}
	#end

	function optionsHandler(event:hxd.Event) {
		new OptionsScreen(assets);
	}

	function addMenuItem(text, yPosition, callback):h2d.Text {
		var textObj = new h2d.Text(assets.mediumFont);
		textObj.text = text;
		textObj.textColor = MediumFontNumbers.colour;
		s2d.addChild(textObj);
		textObj.x = ImageSizes.screenWidth / 2 - textObj.textWidth / 2;
		textObj.y = yPosition;

		var interaction = new h2d.Interactive(titleText.textWidth,
												textObj.textHeight,
												textObj);
		menu.addItem(interaction);
		interaction.onOver = function(event:hxd.Event) {
			menu.pick(interaction);
			textObj.textColor = MediumFontNumbers.selectColour;
		}
		interaction.onOut = function(event:hxd.Event) {
			textObj.textColor = MediumFontNumbers.colour;
		}
		interaction.onKeyDown = function(event:hxd.Event) {
			if (Controls.MENUSELECT.contains(event.keyCode)) {
				callback(event);
			}
		}
		interaction.onClick = callback;

		return textObj;
	}

	override function loadAssets(done) {
		var loader:lazycat.loader.ManifestLoader = lazycat.loader.ManifestBuilder.initManifest("assets");
		loader.onLoaded = done;
		loader.loadManifestFiles();
	}

	static function main() {
		#if sys
		var currentPath:String = Sys.programPath();
		currentPath = haxe.io.Path.directory(currentPath);
		Sys.setCwd(currentPath);
		#end
		new Main(new Assets());
	}
}
