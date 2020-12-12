package lazycat;

import lazycat.Constants.BigFontNumbers;
import lazycat.Constants.ImageSizes;
import lazycat.Constants.TextStrings;

class Main extends hxd.App {

	var game:Game;
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
		titleText.x = screenWidth / 2 - titleText.textWidth / 2;
		titleText.y = screenHeight / 2 - titleText.textHeight / 2;
	}

	override function update(dt:Float) {
		if (hxd.Key.isDown(hxd.Key.MOUSE_LEFT)) {
			game = new Game(this, assets);
		}
	}

	static function main() {
		hxd.Res.initEmbed();
		new Main(new Assets());
	}
}
