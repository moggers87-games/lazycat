package lazycat;

enum abstract ImageSizes(Int) from Int to Int {
	var screenHeight = 600;
	var screenWidth = 800;
	var spriteFrames = 3;
}

enum abstract BigFontNumbers(Int) from Int to Int {
	var size = 100;
	var colour = 0xFFFFFF;
	var dropShadowX = 7;
	var dropShadowY = 5;
	var dropShadowColour = 0x737373;
}

enum abstract SmallFontNumbers(Int) from Int to Int {
	var size = 20;
	var colour = 0xFFFFFF;
	var selectColour = 0x737373;
}

enum abstract TextStrings(String) from String to String {
	var winner = "Winner!";
	var paused = "Paused";
	var title = "LazyCat";
	var quit = "Quit";
	var start = "Start";
	var credits = "Credits";
	var back = "Back";
	var version = "LazyCat version " + Utils.getVersion();
	var instructions = "Instructions";
	var scorePrefix = "Score: ";
	var highScorePrefix = "Best: ";
}

enum abstract MiscFloats(Float) from Float to Float {
	var musicVolume = 0.25;
	var percentMultiplier = 0.01;
	var overlayAlpha = 0.5;
	var catScalePercent = 0.2;
	var mouseScalePercent = 0.1;
}

enum abstract MiscStrings(String) from String to String {
	var savePath = "lazycat/highscore";
}

enum abstract MiscInts(Int) from Int to Int {
	var defaultHighScore = 1000;
	var catMove = 3;

	@:op(A > B) static function gt(lhs:MiscInts, rhs:MiscInts):Bool;
	@:op(A >= B) static function gte(lhs:MiscInts, rhs:MiscInts):Bool;
	@:op(A < B) static function lt(lhs:MiscInts, rhs:MiscInts):Bool;
	@:op(A <= B) static function lte(lhs:MiscInts, rhs:MiscInts):Bool;
}

class Controls {
	public static var fireLasers:haxe.ds.ReadOnlyArray<Int> = [hxd.Key.MOUSE_LEFT, hxd.Key.SPACE];
	public static var moveUp:haxe.ds.ReadOnlyArray<Int> = [hxd.Key.UP];
	public static var moveDown:haxe.ds.ReadOnlyArray<Int> = [hxd.Key.DOWN];
	public static var moveLeft:haxe.ds.ReadOnlyArray<Int> = [hxd.Key.LEFT];
	public static var moveRight:haxe.ds.ReadOnlyArray<Int> = [hxd.Key.RIGHT];
	public static var back:haxe.ds.ReadOnlyArray<Int> = [hxd.Key.ESCAPE];
	public static var pause:haxe.ds.ReadOnlyArray<Int> = [hxd.Key.ESCAPE, hxd.Key.P];

	public static function isDown(keys:Iterable<Int>) {
		for (key in keys) {
			if (inline hxd.Key.isDown(key)) {
				return true;
			}
		}
		return false;
	}

}
