package lazycat;

import lazycat.Constants.MiscInts;
import lazycat.Constants.MiscFloats;

class Options extends gameUtils.Options {
	public function new() {
		super("lazycat");
	}

	override function generateDefaults():Dynamic {
		return {
			"highscore": MiscInts.defaultHighScore,
			"musicVolume": MiscFloats.musicVolume,
			"laserVolume": MiscFloats.laserVolume,
		};
	}
}
