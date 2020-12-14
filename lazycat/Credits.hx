package lazycat;

import lazycat.Constants.BigFontNumbers;
import lazycat.Constants.ImageSizes;
import lazycat.Constants.SmallFontNumbers;
import lazycat.Constants.TextStrings;

class Credits extends hxd.App {

	var main:Main;
	var assets:Assets;

	var creditText:h2d.Text;
	var titleText:h2d.Text;

	var yCreditMin:Float;
	var yCreditMax:Float;

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

		var titleInteraction:h2d.Interactive = new h2d.Interactive(titleText.textWidth,
																	titleText.textHeight,
																	titleText);
		titleInteraction.onOver = function(event:hxd.Event) {
			titleText.textColor = BigFontNumbers.dropShadowColour;
			titleText.dropShadow.color = BigFontNumbers.colour;
		}
		titleInteraction.onOut = function(event:hxd.Event) {
			titleText.textColor = BigFontNumbers.colour;
			titleText.dropShadow.color = BigFontNumbers.dropShadowColour;
		}
		titleInteraction.onClick = function(event:hxd.Event) {
			hxd.System.setNativeCursor(hxd.Cursor.Default);
			new Main(assets);
		}

		/* make height slightly taller so we can bump tile up later */
		var titleBackground:h2d.Bitmap = new h2d.Bitmap(h2d.Tile.fromColor(0, s2d.width, Math.ceil(titleText.textHeight) + 1, 1));
		s2d.addChild(titleBackground);

		/* bump up to cover up weird edge case */
		titleBackground.setPosition(0, -1);

		creditText = new h2d.Text(assets.smallFont);
		creditText.text = hxd.Res.credits.entry.getText();
		creditText.textColor = SmallFontNumbers.colour;
		creditText.maxWidth = ImageSizes.screenWidth - SmallFontNumbers.size * 2;
		s2d.addChild(creditText);
		creditText.y = BigFontNumbers.size * 1.5;
		creditText.x = SmallFontNumbers.size;

		yCreditMin = -creditText.textHeight + (ImageSizes.screenHeight + titleText.textHeight);
		yCreditMax = creditText.y;

		s2d.under(creditText);
		s2d.over(titleText);
		s2d.addEventListener(scrollMe);
	}

	function scrollMe(event:hxd.Event) {
		if (event.kind == EWheel) {
			creditText.y += (event.wheelDelta * 100);
			if (creditText.y > yCreditMax) {
				creditText.y = yCreditMax;
			} else if (creditText.y < yCreditMin) {
				creditText.y = yCreditMin;
			}
		}
	}
}
