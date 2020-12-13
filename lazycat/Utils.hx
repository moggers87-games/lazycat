package lazycat;

class Utils {

	public static function randomInt(start:Int, end:Int):Int {
		var multiplier:Int = end - start;
		return Math.floor(Math.random() * multiplier) + start;
	}

	public static inline function randomChance(chance:Int):Bool {
		return randomInt(0, chance) == 0;
	}
}
