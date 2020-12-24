package lazycat;

class Utils {

	public static function randomInt(start:Int, end:Int):Int {
		var multiplier:Int = end - start;
		return Math.floor(Math.random() * multiplier) + start;
	}

	public static inline function randomChance(chance:Int):Bool {
		return randomInt(0, chance) == 0;
	}

	macro public static function getVersion():haxe.macro.Expr.ExprOf<String> {
		var process = new sys.io.Process("git", ["describe", "--long", "--dirty"]);
		if (process.exitCode() != 0) {
			var message:String = process.stderr.readAll().toString();
			haxe.macro.Context.error("Git error: " + message, haxe.macro.Context.currentPos());
		}

		var version:String = process.stdout.readLine();
		return macro $v{version};
	}
}
