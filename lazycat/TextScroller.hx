package lazycat;

import lazycat.Constants.BigFontNumbers;
import lazycat.Constants.Controls;
import lazycat.Constants.ImageSizes;
import lazycat.Constants.SmallFontNumbers;
import lazycat.Constants.TextStrings;
import lazycat.Constants.MediumFontNumbers;
import gameUtils.ScrollController;

class TextScroller extends hxd.App {

	var assets:Assets;
	var text:String;
	var title:String;

	var scrollText:h2d.Text;
	var titleText:h2d.Text;
	var backText:h2d.Text;

	public function new(assets:Assets, title:String, text:String) {
		super();
		this.assets = assets;
		this.text = text;
		this.title = title;
	}

	override function init() {
		s2d.scaleMode = h2d.Scene.ScaleMode.LetterBox(ImageSizes.screenWidth, ImageSizes.screenHeight);

		assets.initFonts();
		generateTitleText();
		generateBackText();

		scrollText = new h2d.Text(assets.smallFont);
		scrollText.text = text;
		scrollText.textColor = SmallFontNumbers.colour;
		s2d.addChild(scrollText);

		s2d.under(scrollText);
		s2d.over(titleText);
		s2d.over(backText);

		new ScrollController(scrollText, s2d, BigFontNumbers.size * 2, SmallFontNumbers.size,
								MediumFontNumbers.size * 2, SmallFontNumbers.size);

		s2d.addEventListener(function(event:hxd.Event) {
			if (event.kind == EKeyDown && Controls.BACK.contains(event.keyCode)) {
				goBack();
				return;
			}
		});
	}

	inline function generateTitleText() {
		titleText = new h2d.Text(assets.bigFont);
		titleText.text = title;
		titleText.textColor = BigFontNumbers.colour;
		titleText.dropShadow = {
			dy: BigFontNumbers.dropShadowY,
			dx: BigFontNumbers.dropShadowX,
			color: BigFontNumbers.dropShadowColour,
			alpha: 1
		};
		s2d.addChild(titleText);
		titleText.x = ImageSizes.screenWidth / 2 - titleText.textWidth / 2;

		var titleInteraction = new h2d.Interactive(titleText.textWidth,
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
		titleInteraction.onClick = goBack;

		var titleBackground = new h2d.Bitmap(h2d.Tile.fromColor(0, ImageSizes.screenWidth, Math.ceil(titleText.textHeight), 1));
		s2d.addChild(titleBackground);
	}

	inline function generateBackText() {
		backText = new h2d.Text(assets.mediumFont);
		backText.text = TextStrings.back;
		backText.textColor = MediumFontNumbers.colour;
		s2d.addChild(backText);
		backText.x = ImageSizes.screenWidth / 2 - backText.textWidth / 2;
		backText.y = ImageSizes.screenHeight - backText.textHeight;

		var backInteraction = new h2d.Interactive(backText.textWidth * 2,
													backText.textHeight,
													backText);
		backInteraction.onOver = function(event:hxd.Event) {
			backText.textColor = MediumFontNumbers.selectColour;
		}
		backInteraction.onOut = function(event:hxd.Event) {
			backText.textColor = MediumFontNumbers.colour;
		}
		backInteraction.onClick = goBack;

		var backBackground = new h2d.Bitmap(h2d.Tile.fromColor(0, ImageSizes.screenWidth, Math.ceil(backText.textHeight), 1));
		s2d.addChild(backBackground);
		backBackground.y = backText.y;
	}

	function goBack(?event:hxd.Event) {
		hxd.System.setNativeCursor(hxd.Cursor.Default);
		new Main(assets);
	}
}
