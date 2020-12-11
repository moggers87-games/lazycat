package lazycat;

enum abstract ImageSizes(Int) from Int to Int {
	var screenHeight = 600;
	var screenWidth = 800;
	var spriteFrames = 3;
}

enum abstract LaserNumbers(Int) from Int to Int {
	var eyePulseMin = 8;
	var eyePulseMax = 15;
	var eyeOffsetX = 40;
	var eyeOffsetY = 15;
	var colour = 0xFF33CC;
	var width = 10;
	var squareOfMaxLaserDistance = 40000;
	var damage = 5;

	@:op(A > B) static function gt(lhs:LaserNumbers, rhs:LaserNumbers):Bool;
	@:op(A >= B) static function gte(lhs:LaserNumbers, rhs:LaserNumbers):Bool;
	@:op(A < B) static function lt(lhs:LaserNumbers, rhs:LaserNumbers):Bool;
	@:op(A <= B) static function lte(lhs:LaserNumbers, rhs:LaserNumbers):Bool;
}

enum abstract MouseNumbers(Int) from Int to Int {
	var initialCount = 4;
	var maxCount = 230;
	var breedChance = 50;
	var directionChance = 50;
	var distanceMin = 1;
	var distanceMax = 10;
	var initialHealth = 100;

	@:op(A > B) static function gt(lhs:MouseNumbers, rhs:MouseNumbers):Bool;
	@:op(A >= B) static function gte(lhs:MouseNumbers, rhs:MouseNumbers):Bool;
	@:op(A < B) static function lt(lhs:MouseNumbers, rhs:MouseNumbers):Bool;
	@:op(A <= B) static function lte(lhs:MouseNumbers, rhs:MouseNumbers):Bool;
}

enum abstract MouseDirection(Int) from Int to Int {
	var right;
	var down;
	var left;
	var up;
	var all;
}

enum abstract WinningNumbers(Int) from Int to Int {
	var size = 100;
	var colour = 0xFFFFFF;
	var dropShadowX = 7;
	var dropShadowY = 5;
	var dropShadowColour = 0x737373;
}

enum abstract MiscFloats(Float) from Float to Float {
	var musicVolume = 0.25;
	var percentMultiplier = 0.01;
	var overlayAlpha = 0.5;
	var catScalePercent = 0.2;
	var mouseScalePercent = 0.1;
}

enum abstract TextStrings(String) from String to String {
	var winner = "Winner!";
	var paused = "Paused";
	var title = "LazyCat";
}

class Utils {

	public static function randomInt(start:Int, end:Int):Int {
		var multiplier:Int = end - start;
		return Math.floor(Math.random() * multiplier) + start;
	}

	public static inline function randomChance(chance:Int):Bool {
		return randomInt(0, chance) == 0;
	}
}

class Assets {

	public var music:hxd.snd.Channel;
	var spriteTileSplit:Array<h2d.Tile>;
	public var sprites:h2d.Tile;
	public var font:h2d.Font;

	public function new() {}

	public function initFonts() {
		if (font == null) {
			font = hxd.res.DefaultFont.get();
			font.resizeTo(WinningNumbers.size);
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

	public function catTile() {
		return spriteTileSplit[0];
	}

	public function eyesTile() {
		return spriteTileSplit[1];
	}

	public function mouseTile() {
		return spriteTileSplit[2];
	}

	public function initMusic() {
		if (music == null) {
			music = hxd.Res.gaslampfunworks.play(true, MiscFloats.musicVolume);
		}
	}
}

class Main extends hxd.App {

	var game:Game;
	var assets:Assets;
	var titleText:h2d.Text;

	public function new(assets:Assets) {
		super();
		this.assets = assets;
	}

	override function init() {
		s2d.scaleMode = h2d.Scene.ScaleMode.LetterBox(ImageSizes.screenWidth, ImageSizes.screenHeight);

		assets.initFonts();

		titleText = new h2d.Text(assets.font);
		titleText.text = TextStrings.title;
		titleText.textColor = WinningNumbers.colour;
		titleText.dropShadow = {
			dy: WinningNumbers.dropShadowY,
			dx: WinningNumbers.dropShadowX,
			color: WinningNumbers.dropShadowColour,
			alpha: 1
		};

		s2d.addChild(titleText);
		titleText.x = screenWidth / 2 - titleText.textWidth / 2;
		titleText.y = screenHeight / 2 - titleText.textHeight / 2;
	}

	override function update(dt:Float) {
		if (hxd.Key.isDown(hxd.Key.MOUSE_LEFT)) {
			game = new Game(this, assets);
		}
	}

	static function main() {
		hxd.Res.initEmbed();
		new Main(new Assets());
	}
}

class Game extends hxd.App {

	var cat:h2d.SpriteBatch;
	var catFace:Cat;
	var catEyes:Cat;
	var laser:h2d.Graphics;
	var mice:h2d.SpriteBatch;
	var pausedOverlay:h2d.Bitmap;
	var pausedText:h2d.Text;
	var winningText:h2d.Text;
	var assets:Assets;

	var paused:Bool;
	var winner:Bool;

	var main:Main;

	public function new(main:Main, assets:Assets) {
		super();
		this.main = main;
		this.assets = assets;
	}

	override function init() {
		hxd.System.setNativeCursor(hxd.Cursor.Hide);
		s2d.scaleMode = h2d.Scene.ScaleMode.LetterBox(ImageSizes.screenWidth, ImageSizes.screenHeight);

		assets.initSprites();

		paused = false;
		winner = false;

		cat = new h2d.SpriteBatch(assets.sprites);
		cat.hasUpdate = true;
		cat.hasRotationScale = true;

		catFace = new Cat(assets.catTile());
		cat.add(catFace);
		catEyes = new Cat(assets.eyesTile());
		s2d.addChild(cat);

		mice = new h2d.SpriteBatch(assets.sprites);
		mice.hasUpdate = true;
		mice.hasRotationScale = true;
		for (i in 0...MouseNumbers.initialCount) {
			var mouse:Mouse = new Mouse(assets.mouseTile());
			mice.add(mouse);
			mouse.x = ImageSizes.screenWidth / 2;
			mouse.y = ImageSizes.screenHeight / 2;
		}
		s2d.addChild(mice);
		laser = new h2d.Graphics(s2d);

		assets.initFonts();

		winningText = new h2d.Text(assets.font);
		winningText.text = TextStrings.winner;
		winningText.textColor = WinningNumbers.colour;
		winningText.dropShadow = {
			dy: WinningNumbers.dropShadowY,
			dx: WinningNumbers.dropShadowX,
			color: WinningNumbers.dropShadowColour,
			alpha: 1
		};

		pausedText = new h2d.Text(assets.font);
		pausedText.text = TextStrings.paused;
		pausedText.textColor = WinningNumbers.colour;
		pausedText.dropShadow = {
			dy: WinningNumbers.dropShadowY,
			dx: WinningNumbers.dropShadowX,
			color: WinningNumbers.dropShadowColour,
			alpha: 1
		};
		pausedOverlay = new h2d.Bitmap(h2d.Tile.fromColor(0, s2d.width, s2d.height, MiscFloats.overlayAlpha));

		s2d.addEventListener(checkPause);

		assets.initMusic();
	}

	function checkPause(event:hxd.Event) {
		if (winner) {
			return;
		}

		switch (event.kind) {
			case EFocusLost:
				paused = true;
			case EKeyDown:
				if (event.keyCode == hxd.Key.P) {
					paused = !paused;
				}
				else {
					paused = false;
				}
			case EPush:
				paused = false;
			default:
				return;
		}

		assets.music.pause = paused;

		if (!paused) {
			hxd.System.setNativeCursor(hxd.Cursor.Hide);
		}

		if (!winner) {
			for (el in mice.getElements()) {
				var mouse:Mouse = cast(el, Mouse);
				mouse.paused = paused;
			}

			if (paused && pausedText.parent == null) {
				s2d.addChild(pausedOverlay);
				s2d.addChild(pausedText);
				pausedText.x = screenWidth / 2 - pausedText.textWidth / 2;
				pausedText.y = screenHeight / 2 - pausedText.textHeight / 2;
			}
			else if (!paused && pausedText.parent != null) {
				s2d.removeChild(pausedOverlay);
				s2d.removeChild(pausedText);
			}
		}
	}

	override function update(dt:Float) {
		trace("bye");
		if (paused || winner) {
			hxd.System.setNativeCursor(hxd.Cursor.Default);
			return;
		}

		laser.clear();
		catEyes.remove();
		catFace.x = s2d.mouseX - catFace.scaledWidth / 2;
		catFace.y = s2d.mouseY - catFace.scaledHeight / 2;

		var miceArray:Array<Mouse> = [for (m in mice.getElements()) cast(m, Mouse)];
		if (miceArray.length == 0 ) {
			hxd.System.setNativeCursor(hxd.Cursor.Default);
			winner = true;
			s2d.addChild(pausedOverlay);
			s2d.addChild(winningText);
			winningText.x = screenWidth / 2 - winningText.textWidth / 2;
			winningText.y = screenHeight / 2 - winningText.textHeight / 2;
			return;
		}
		if (hxd.Key.isDown(hxd.Key.MOUSE_LEFT)) {
			cat.add(catEyes);
			catEyes.x = catFace.x;
			catEyes.y = catFace.y;
			var catCentre:Array<Float> = catFace.centre;
			for (chosenMouse in miceArray) {
				var mouseCentre:Array<Float> = chosenMouse.centre;
				var distance:Float = Math.pow(catCentre[0] - mouseCentre[0], 2) + Math.pow(catCentre[1] - mouseCentre[1], 2);
				if (Math.floor(distance) <= LaserNumbers.squareOfMaxLaserDistance) {
					fireAt(chosenMouse, catCentre, mouseCentre);
					break;
				}
			}
		}

		if (miceArray.length < MouseNumbers.maxCount && Utils.randomChance(MouseNumbers.breedChance)) {
			var lastMouse:Mouse = miceArray.pop();
			var mouse:Mouse = new Mouse(assets.mouseTile());
			mice.add(mouse);
			mouse.x = lastMouse.x;
			mouse.y = lastMouse.y;
		}
	}

	function fireAt(mouse:Mouse, catCentre:Array<Float>, mouseCentre:Array<Float>) {
		var rightEyeX:Float = catCentre[0] + LaserNumbers.eyeOffsetX;
		var rightEyeY:Float = catCentre[1] + LaserNumbers.eyeOffsetY;
		var leftEyeX:Float = catCentre[0] - LaserNumbers.eyeOffsetX;
		var leftEyeY:Float = rightEyeY;

		laser.beginFill(0, 0);
		laser.lineStyle(LaserNumbers.width, LaserNumbers.colour);

		laser.moveTo(rightEyeX, rightEyeY);
		laser.lineTo(mouseCentre[0], mouseCentre[1]);
		laser.moveTo(leftEyeX, leftEyeY);
		laser.lineTo(mouseCentre[0], mouseCentre[1]);

		var eyePulse:Int = Utils.randomInt(LaserNumbers.eyePulseMin, LaserNumbers.eyePulseMax);
		laser.beginFill(LaserNumbers.colour, 1);
		laser.lineStyle(0, 0, 0);
		laser.drawCircle(rightEyeX, rightEyeY, eyePulse);
		laser.drawCircle(leftEyeX, leftEyeY, eyePulse);
		laser.drawCircle(mouseCentre[0], mouseCentre[1], Utils.randomInt(LaserNumbers.eyePulseMin, LaserNumbers.eyePulseMax));
		laser.endFill();

		mouse.hit();
	}
}

class ElementWithCentre extends h2d.SpriteBatch.BatchElement {

	public var centre(get, null): Array<Float>;
	public var scaledHeight(get, null): Float;
	public var scaledWidth(get, null): Float;

	function get_centre(): Array<Float> {
		return [
			x + scaledWidth / 2,
			y + scaledHeight / 2,
		];
	}

	function get_scaledWidth(): Float {
		return t.width * scaleX;
	}

	function get_scaledHeight(): Float {
		return t.height * scaleY;
	}
}

class Cat extends ElementWithCentre {

	public function new(t:h2d.Tile) {
		super(t);
		scale = MiscFloats.catScalePercent;
	}

}

class Mouse extends ElementWithCentre {

	var health:Int;
	var direction:Int;
	public var paused:Bool;

	public function new(t:h2d.Tile) {
		super(t);
		paused = false;
		health = MouseNumbers.initialHealth;
		scale = MiscFloats.mouseScalePercent;
		changeDirection();
	}

	function changeDirection() {
		direction = Utils.randomInt(0, MouseDirection.all);
	}

	override function update(dt:Float):Bool {
		if (paused) {
			return true;
		}
		var distance:Int = Utils.randomInt(MouseNumbers.distanceMin, MouseNumbers.distanceMax);
		var change:Bool = Utils.randomChance(MouseNumbers.directionChance);

		super.update(dt);

		switch (direction) {
			case MouseDirection.right:
				x += distance;
				var max:Float = ImageSizes.screenWidth - scaledWidth;
				if (x > max) {
					x = max;
					direction = MouseDirection.left;
					change = false;
				}
			case MouseDirection.left:
				x -= distance;
				if (x < 0) {
					x = 0;
					direction = MouseDirection.right;
					change = false;
				}
			case MouseDirection.down:
				y += distance;
				var max:Float = ImageSizes.screenHeight - scaledHeight;
				if (y > max) {
					y = max;
					direction = MouseDirection.up;
					change = false;
				}
			case MouseDirection.up:
				y -= distance;
				if (y < 0) {
					y = 0;
					direction = MouseDirection.down;
					change = false;
				}
			default:
		}

		if (change) {
			changeDirection();
		}

		return true;
	}

	public function hit() {
		health -= LaserNumbers.damage;
		if (health <= 0) {
			remove();
		}
	}
}
