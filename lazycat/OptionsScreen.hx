package lazycat;

import lazycat.Constants.BigFontNumbers;
import lazycat.Constants.Controls;
import lazycat.Constants.MediumFontNumbers;
import lazycat.Constants.MiscFloats;
import lazycat.Constants.SliderNumbers;
import lazycat.Constants.TextStrings;

class OptionsScreen extends TitledScreen {

	var music:h2d.Slider;
	var laser:h2d.Slider;
	var menu:Menu;

	public function new(assets:Assets) {
		super(assets, TextStrings.options);
		menu = new Menu();
	}

	override function init() {
		super.init();
		s2d.addEventListener(menu.keyboardControl);
		music = generateSlider(MediumFontNumbers.size, BigFontNumbers.size * 2, TextStrings.musicVolume, "musicVolume");
		s2d.addChild(music);
		laser = generateSlider(music.x, MediumFontNumbers.size + music.y + music.height, TextStrings.laserVolume, "laserVolume");
		s2d.addChild(laser);
	}

	function generateSlider(x:Float, y:Float, text:String, key:String):h2d.Slider {
		var slide = new h2d.Slider(SliderNumbers.width, SliderNumbers.height);
		slide.cursorTile = h2d.Tile.fromColor(SliderNumbers.cursorColour, SliderNumbers.cursorWidth, SliderNumbers.cursorHeight);
		slide.tile = h2d.Tile.fromColor(SliderNumbers.sliderColour, SliderNumbers.width, SliderNumbers.sliderHeight);
		slide.tile.dy = (SliderNumbers.height - SliderNumbers.sliderHeight) / 2;
		slide.y = y;
		slide.x = x;
		slide.value = assets.options.get(key);
		slide.onChange = function() {
			assets.options.set(key, slide.value);
		}

		var textText = new h2d.Text(assets.mediumFont);
		textText.text = text;
		textText.textColor = MediumFontNumbers.colour;
		textText.x = slide.x + slide.width;
		textText.y = (SliderNumbers.height - textText.textHeight) / 2;
		slide.addChild(textText);

		menu.addItem(slide);
		slide.onOver = function(event:hxd.Event) {
			menu.pick(slide);
			textText.textColor = MediumFontNumbers.selectColour;
		}
		slide.onOut = function(event:hxd.Event) {
			textText.textColor = MediumFontNumbers.colour;
		}
		slide.onKeyDown = function(event:hxd.Event) {
			if (Controls.MOVELEFT.contains(event.keyCode)) {
				slide.value -= cast(MiscFloats.sliderStep, Float);
			}
			else if (Controls.MOVERIGHT.contains(event.keyCode)) {
				slide.value += cast(MiscFloats.sliderStep, Float);
			}
			slide.onChange();
		}

		return slide;
	}

	override function goBack(?event:hxd.Event) {
		assets.options.save();
		super.goBack(event);
	}
}
