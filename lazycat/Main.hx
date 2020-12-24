package lazycat;

import lazycat.Constants.BigFontNumbers;
import lazycat.Constants.ImageSizes;
import lazycat.Constants.SmallFontNumbers;
import lazycat.Constants.TextStrings;

class Main extends hxd.App {

	var assets:Assets;
	var titleText:h2d.Text;

	public function new(assets:Assets) {
		super();
		this.assets = assets;
	}

	override function init() {
		s2d.scaleMode = h2d.Scene.ScaleMode.LetterBox(ImageSizes.screenWidth, ImageSizes.screenHeight);

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

		var startText:h2d.Text = addMenuItem(
			TextStrings.start,
			titleText.y + titleText.textHeight,
			function(event:hxd.Event) {
				new Game(assets);
			}
		);

		var instructionsText:h2d.Text = addMenuItem(
			TextStrings.instructions,
			startText.y + startText.textHeight,
			function(event:hxd.Event) {
				hxd.System.setNativeCursor(hxd.Cursor.Default);
				new TextScroller(assets, TextStrings.instructions, hxd.Res.instructions.entry.getText());
			}
		);

		addMenuItem(
			TextStrings.credits,
			instructionsText.y + instructionsText.textHeight,
			function(event:hxd.Event) {
				hxd.System.setNativeCursor(hxd.Cursor.Default);
				new TextScroller(assets, TextStrings.credits, hxd.Res.credits.entry.getText());
			}
		);

		var versionText = new h2d.Text(assets.smallFont);
		versionText.text = TextStrings.version;
		versionText.textColor = SmallFontNumbers.colour;
		s2d.addChild(versionText);
		versionText.y = ImageSizes.screenHeight - versionText.textHeight;
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
		interaction.onOver = function(event:hxd.Event) {
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
