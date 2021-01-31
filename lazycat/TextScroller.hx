package lazycat;

import lazycat.Constants.BigFontNumbers;
import lazycat.Constants.SmallFontNumbers;
import lazycat.Constants.MediumFontNumbers;
import gameUtils.ScrollController;

class TextScroller extends TitledScreen {

	var text:String;

	var scrollText:h2d.Text;

	public function new(assets:Assets, title:String, text:String) {
		super(assets, title);
		this.text = text;
	}

	override function init() {
		super.init();
		scrollText = new h2d.Text(assets.smallFont);
		scrollText.text = text;
		scrollText.textColor = SmallFontNumbers.colour;
		s2d.addChild(scrollText);

		s2d.under(scrollText);

		new ScrollController(scrollText, s2d, BigFontNumbers.size * 2, SmallFontNumbers.size,
								MediumFontNumbers.size * 2, SmallFontNumbers.size);
	}
}
