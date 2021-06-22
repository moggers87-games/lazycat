package lazycat;

import lazycat.Constants.BigFontNumbers;
import lazycat.Constants.ImageSizes;
import lazycat.Constants.SmallFontNumbers;
import lazycat.Constants.MediumFontNumbers;

class Assets {

	public var bigFont:h2d.Font;
	public var mediumFont:h2d.Font;
	public var music:hxd.snd.Channel;
	public var smallFont:h2d.Font;
	public var sprites:h2d.Tile;
	public var options:Options;
	var laser:hxd.snd.Channel;
	var spriteTileSplit:Array<h2d.Tile>;

	public function new() {
		options = new Options();
		options.load();
	}

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
			music = hxd.Res.gaslampfunworks.play(true, options.get("musicVolume"));
		}
		else {
			music.position = 0.0;
			music.volume = options.get("musicVolume");
			music.pause = false;
		}
	}

	public function fireLaser() {
		if (laser == null) {
			laser = hxd.Res.laser.play(true, options.get("laserVolume"));
		}
		else {
			laser.volume = options.get("laserVolume");
			laser.pause = false;
		}
	}

	public function stopLaser() {
		if (laser != null) {
			laser.pause = true;
		}
	}

	@:access(hxd.snd.Channel.manager)
	public function dispose() {
		var manager:hxd.snd.Manager = null;
		if (music != null) {
			manager = music.manager;
			music.stop();
			music = null;
		}
		if (laser != null) {
			manager = laser.manager;
			laser.stop();
			laser = null;
		}
		if (manager != null) {
			manager.dispose();
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
