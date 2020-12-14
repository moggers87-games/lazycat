package lazycat;

import lazycat.Constants.BigFontNumbers;
import lazycat.Constants.ImageSizes;
import lazycat.Constants.SmallFontNumbers;
import lazycat.Constants.TextStrings;

class Main extends hxd.App {

	var assets:Assets;

	public function new(assets:Assets) {
		super();
		this.assets = assets;
	}

	override function init() {
		s2d.scaleMode = h2d.Scene.ScaleMode.LetterBox(ImageSizes.screenWidth, ImageSizes.screenHeight);

		assets.initFonts();

		var titleText:h2d.Text = new h2d.Text(assets.bigFont);
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

		var startText:h2d.Text = new h2d.Text(assets.smallFont);
		startText.text = TextStrings.start;
		startText.textColor = SmallFontNumbers.colour;
		s2d.addChild(startText);
		startText.x = ImageSizes.screenWidth / 2 - startText.textWidth / 2;
		startText.y = titleText.y + titleText.textHeight;

		var startInteraction:h2d.Interactive = new h2d.Interactive(startText.textWidth,
																	startText.textHeight,
																	startText);
		startInteraction.onOver = function(event:hxd.Event) {
			startText.textColor = SmallFontNumbers.selectColour;
		}
		startInteraction.onOut = function(event:hxd.Event) {
			startText.textColor = SmallFontNumbers.colour;
		}
		startInteraction.onClick = function(event:hxd.Event) {
			new Game(assets);
		}

		var creditsText:h2d.Text = new h2d.Text(assets.smallFont);
		creditsText.text = TextStrings.credits;
		creditsText.textColor = SmallFontNumbers.colour;
		s2d.addChild(creditsText);
		creditsText.x = ImageSizes.screenWidth / 2 - creditsText.textWidth / 2;
		creditsText.y = startText.y + startText.textHeight;

		var creditsInteraction:h2d.Interactive = new h2d.Interactive(creditsText.textWidth,
																	creditsText.textHeight,
																	creditsText);
		creditsInteraction.onOver = function(event:hxd.Event) {
			creditsText.textColor = SmallFontNumbers.selectColour;
		}
		creditsInteraction.onOut = function(event:hxd.Event) {
			creditsText.textColor = SmallFontNumbers.colour;
		}
		creditsInteraction.onClick = function(event:hxd.Event) {
			hxd.System.setNativeCursor(hxd.Cursor.Default);
			new Credits(assets);
		}

		var versionText:h2d.Text = new h2d.Text(assets.smallFont);
		versionText.text = TextStrings.version;
		versionText.textColor = SmallFontNumbers.colour;
		s2d.addChild(versionText);
		versionText.y = ImageSizes.screenHeight - versionText.textHeight;
	}

	static function main() {
		hxd.Res.initEmbed();
		new Main(new Assets());
	}
}
