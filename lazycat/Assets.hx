package lazycat;

import lazycat.Constants.BigFontNumbers;
import lazycat.Constants.ImageSizes;
import lazycat.Constants.MiscFloats;
import lazycat.Constants.SmallFontNumbers;
import lazycat.Constants.MediumFontNumbers;

class Assets {

	public var music:hxd.snd.Channel;
	var spriteTileSplit:Array<h2d.Tile>;
	public var sprites:h2d.Tile;
	public var bigFont:h2d.Font;
	public var mediumFont:h2d.Font;
	public var smallFont:h2d.Font;

	public function new() {}

	public function initFonts() {
		if (bigFont == null) {
			bigFont = hxd.res.DefaultFont.get().clone();
			bigFont.resizeTo(BigFontNumbers.size);
		}
		if (mediumFont == null) {
			mediumFont = hxd.res.DefaultFont.get().clone();
			mediumFont.resizeTo(MediumFontNumbers.size);
		}
		if (smallFont == null) {
			smallFont = hxd.res.DefaultFont.get().clone();
			smallFont.resizeTo(SmallFontNumbers.size);
		}
	}

	public function initSprites() {
		if (sprites == null) {
			sprites = hxd.Res.sprites.toTile();
		}
		if (spriteTileSplit == null) {
			spriteTileSplit = sprites.split(ImageSizes.spriteFrames, true);
		}
	}

	public function catTile():h2d.Tile {
		return spriteTileSplit[0];
	}

	public function eyesTile():h2d.Tile {
		return spriteTileSplit[1];
	}

	public function mouseTile():h2d.Tile {
		return spriteTileSplit[2];
	}

	public function initMusic() {
		if (music == null) {
			music = hxd.Res.gaslampfunworks.play(true, MiscFloats.musicVolume);
		}
		else {
			music.position = 0.0;
			music.pause = false;
		}
	}

	public function dispose() {
		if (music != null) {
			music.stop();
			music = null;
		}
		if (sprites != null) {
			sprites.dispose();
			sprites = null;
		}
		if (bigFont != null) {
			bigFont.dispose();
			bigFont = null;
		}
		if (smallFont != null) {
			smallFont.dispose();
			smallFont = null;
		}
	}
}
