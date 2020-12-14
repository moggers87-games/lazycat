package lazycat;

class Utils {

	public static function randomInt(start:Int, end:Int):Int {
		var multiplier:Int = end - start;
		return Math.floor(Math.random() * multiplier) + start;
	}

	public static inline function randomChance(chance:Int):Bool {
		return randomInt(0, chance) == 0;
	}

	public static macro function getVersion():haxe.macro.Expr.ExprOf<String> {
		var process = new sys.io.Process("git", ["describe", "--long", "--dirty"]);
		if (process.exitCode() != 0) {
			var message = process.stderr.readAll().toString();
			var pos = haxe.macro.Context.currentPos();
			haxe.macro.Context.error("Git error: " + message, pos);
		}

		var version:String = process.stdout.readLine();
		return macro $v{version};
	}
}
