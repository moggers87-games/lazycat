package lazycat;

import lazycat.Constants.BigFontNumbers;
import lazycat.Constants.ImageSizes;
import lazycat.Constants.SmallFontNumbers;
import lazycat.Constants.TextStrings;

class TextScroller extends hxd.App {

	var assets:Assets;
	var text:String;

	var scrollText:h2d.Text;
	var titleText:h2d.Text;

	var yScrollMin:Float;
	var yScrollMax:Float;

	public function new(assets:Assets, text:String) {
		super();
		this.assets = assets;
		this.text = text;
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

		scrollText = new h2d.Text(assets.smallFont);
		scrollText.maxWidth = ImageSizes.screenWidth - SmallFontNumbers.size * 2;
		scrollText.text = text;
		scrollText.textColor = SmallFontNumbers.colour;
		s2d.addChild(scrollText);
		scrollText.y = BigFontNumbers.size * 1.5;
		scrollText.x = SmallFontNumbers.size;

		yScrollMin = ImageSizes.screenHeight - scrollText.textHeight;
		yScrollMax = scrollText.y;

		s2d.under(scrollText);
		s2d.over(titleText);
		if (scrollText.textHeight > (ImageSizes.screenHeight - scrollText.y)) {
			s2d.addEventListener(scrollMe);
		}
	}

	function scrollMe(event:hxd.Event) {
		if (event.kind == EWheel) {
			scrollText.y += (event.wheelDelta * 100);
			if (scrollText.y > yScrollMax) {
				scrollText.y = yScrollMax;
			} else if (scrollText.y < yScrollMin) {
				scrollText.y = yScrollMin;
			}
		}
	}
}
