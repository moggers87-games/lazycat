package;


enum abstract ImageSizes(Int) from Int to Int {
	var screenHeight = 600;
	var screenWidth = 800;
	var catHeight = 212;
	var catWidth = 200;
	var mouseScalePercent = 10;
}

enum abstract LaserNumbers(Int) from Int to Int {
	var eyePulseMin = 8;
	var eyePulseMax = 15;
	var leftEye = -20;
	var rightEye = 50;
	var colour = 0xFF0000;
	var width = 10;
	var squareOfMaxLaserDistance = 40000;
	var damage = 5;

	@:op(A>B) private static function gt(lhs:LaserNumbers, rhs:LaserNumbers):Bool;
	@:op(A>=B) private static function gte(lhs:LaserNumbers, rhs:LaserNumbers):Bool;
	@:op(A<B) private static function lt(lhs:LaserNumbers, rhs:LaserNumbers):Bool;
	@:op(A<=B) private static function lte(lhs:LaserNumbers, rhs:LaserNumbers):Bool;
}

enum abstract MouseNumbers(Int) from Int to Int {
	var initialCount = 4;
	var maxCount = 230;
	var breedChance = 50;
	var directionChance = 50;
	var distanceMin = 1;
	var distanceMax = 10;

	@:op(A>B) private static function gt(lhs:MouseNumbers, rhs:MouseNumbers):Bool;
	@:op(A>=B) private static function gte(lhs:MouseNumbers, rhs:MouseNumbers):Bool;
	@:op(A<B) private static function lt(lhs:MouseNumbers, rhs:MouseNumbers):Bool;
	@:op(A<=B) private static function lte(lhs:MouseNumbers, rhs:MouseNumbers):Bool;
}

enum abstract MouseDirection(Int) from Int to Int {
	var Right;
	var Down;
	var Left;
	var Up;
	var All;
}

enum abstract WinningNumbers(Int) from Int to Int {
	var size = 100;
	var colour = 0xFFFFFF;
	var dropShadowX = 7;
	var dropShadowY = 5;
	var dropShadowColour = 0x909090;
}

enum abstract TextStrings(String) from String to String {
	var winner = "Winner!";
	var paused = "Paused";
}

class Utils {
	static public function randomInt(start:Int, end:Int):Int {
		var multiplier = end - start;
		return Math.floor(Math.random() * multiplier) + start;
	}

	static inline public function randomChance(chance:Int):Bool {
		return randomInt(0, chance) == 0;
	}
}

class Main extends hxd.App {

	var cat:h2d.Bitmap;
	var laser:h2d.Graphics;
	var mice:h2d.SpriteBatch;
	var mouseTile:h2d.Tile;
	var music:hxd.snd.Channel;
	var pausedOverlay:h2d.Bitmap;
	var pausedText:h2d.Text;
	var winningText:h2d.Text;

	var paused:Bool = false;
	var winner:Bool = false;

	override function init() {
		hxd.System.setNativeCursor(hxd.Cursor.Hide);

		s2d.scaleMode = h2d.Scene.ScaleMode.LetterBox(ImageSizes.screenWidth, ImageSizes.screenHeight);
		cat = new h2d.Bitmap(hxd.Res.lasercat.toTile());
		cat.height = ImageSizes.catHeight;
		cat.width = ImageSizes.catWidth;
		s2d.addChild(cat);

		mouseTile = hxd.Res.lasermouse.toTile();
		mice = new h2d.SpriteBatch(mouseTile);
		mice.hasUpdate = true;
		mice.hasRotationScale = true;
		for (i in 0...MouseNumbers.initialCount) {
			var mouse = new Mouse(mouseTile);
			mice.add(mouse);
			mouse.x = ImageSizes.screenWidth / 2;
			mouse.y = ImageSizes.screenHeight / 2;
		}
		s2d.addChild(mice);
		laser = new h2d.Graphics(s2d);

		var font = hxd.res.DefaultFont.get();
		font.resizeTo(WinningNumbers.size);

		winningText = new h2d.Text(font);
		winningText.text = TextStrings.winner;
		winningText.textColor = WinningNumbers.colour;
		winningText.dropShadow = {
			dy: WinningNumbers.dropShadowY,
			dx: WinningNumbers.dropShadowX,
			color: WinningNumbers.dropShadowColour,
			alpha: 1
		};

		pausedText = new h2d.Text(font);
		pausedText.text = TextStrings.paused;
		pausedText.textColor = WinningNumbers.colour;
		pausedText.dropShadow = {
			dy: WinningNumbers.dropShadowY,
			dx: WinningNumbers.dropShadowX,
			color: WinningNumbers.dropShadowColour,
			alpha: 1
		};
		pausedOverlay = new h2d.Bitmap(h2d.Tile.fromColor(0, s2d.width, s2d.height, 0.5));

		music = hxd.Res.gaslampfunworks.play();

		s2d.addEventListener(checkPause);
	}

	function checkPause(event:hxd.Event) {
		switch(event.kind) {
			case EFocusLost:
				paused = true;
			case EKeyDown:
				if (event.keyCode == hxd.Key.P) {
					paused = !paused;
				} else {
					paused = false;
				}
			case EPush:
				paused = false;
			default:
		}

		music.pause = paused;

		if (!winner) {
			for (mouse in mice.getElements()) {
				cast(mouse, Mouse).paused = paused;
			}

			if (paused && pausedText.parent == null) {
				s2d.addChild(pausedOverlay);
				s2d.addChild(pausedText);
				pausedText.x = screenWidth / 2 - pausedText.textWidth / 2;
				pausedText.y = screenHeight / 2 - pausedText.textHeight / 2;
			} else if (!paused && pausedText.parent != null) {
				s2d.removeChild(pausedOverlay);
				s2d.removeChild(pausedText);
			}
		}
	}

	override function update(dt:Float) {
		if (paused) {
			return;
		}

		laser.clear();
		cat.x = s2d.mouseX - (ImageSizes.catHeight / 2);
		cat.y = s2d.mouseY - (ImageSizes.catWidth / 2);

		if (winner) {
			return;
		}

		var miceArray = [for (m in mice.getElements()) m];
		if (miceArray.length > 0) {
			if (hxd.Key.isDown(hxd.Key.MOUSE_LEFT)) {
				var catCentre = [cat.x + (cat.width * 0.5), cat.y + (cat.height * 0.5)];
				for (chosenMouse in miceArray) {
					var mouseCentre = [chosenMouse.x + (chosenMouse.t.width * 0.5 * chosenMouse.scaleX), chosenMouse.y + (chosenMouse.t.height * 0.5 * chosenMouse.scaleY)];
					var distance = Math.pow(catCentre[0] - mouseCentre[0], 2) + Math.pow(catCentre[1] - mouseCentre[1], 2);
					if (Math.floor(distance) <= LaserNumbers.squareOfMaxLaserDistance) {
						fireAt(cast(chosenMouse, Mouse), catCentre, mouseCentre);
						break;
					}
				}
			}

			if (miceArray.length < MouseNumbers.maxCount && Utils.randomChance(MouseNumbers.breedChance)) {
				var lastMouse = miceArray.pop();
				var mouse = new Mouse(mouseTile);
				mice.add(mouse);
				mouse.x = lastMouse.x;
				mouse.y = lastMouse.y;
			}
		} else {
			winner = true;
			s2d.addChild(winningText);
			s2d.under(winningText);
			winningText.x = screenWidth / 2 - winningText.textWidth / 2;
			winningText.y = screenHeight / 2 - winningText.textHeight / 2;
		}
	}

	function fireAt(mouse:Mouse, catCentre:Array<Float>, mouseCentre:Array<Float>) {
		var rightEye = catCentre[0] + LaserNumbers.rightEye;
		var leftEye = catCentre[0] + LaserNumbers.leftEye;

		laser.beginFill(0, 0);
		laser.lineStyle(LaserNumbers.width, LaserNumbers.colour);

		laser.moveTo(rightEye, catCentre[1]);
		laser.lineTo(mouseCentre[0], mouseCentre[1]);
		laser.moveTo(leftEye, catCentre[1]);
		laser.lineTo(mouseCentre[0], mouseCentre[1]);

		var eyePulse = Utils.randomInt(LaserNumbers.eyePulseMin, LaserNumbers.eyePulseMax);
		laser.beginFill(LaserNumbers.colour, 1);
		laser.lineStyle(0, 0, 0);
		laser.drawCircle(rightEye, catCentre[1], eyePulse);
		laser.drawCircle(leftEye, catCentre[1], eyePulse);
		laser.drawCircle(mouseCentre[0], mouseCentre[1], Utils.randomInt(LaserNumbers.eyePulseMin, LaserNumbers.eyePulseMax));
		laser.endFill();

		mouse.hit();
	}

	static function main() {
		hxd.Res.initEmbed();
		new Main();
	}
}

class Mouse extends h2d.SpriteBatch.BatchElement {

	var health:Int = 100;
	var direction:Int;
	public var paused:Bool = false;

	public function new(t:h2d.Tile) {
		super(t);
		scale = ImageSizes.mouseScalePercent / 100;
		changeDirection();
	}

	function changeDirection() {
		direction = Utils.randomInt(0, 4);
	}

	override function update(dt:Float) {
		final padding = 60;
		if (paused) {
			return true;
		}
		var distance = Utils.randomInt(MouseNumbers.distanceMin, MouseNumbers.distanceMax);
		var change = Utils.randomChance(MouseNumbers.directionChance);

		super.update(dt);

		switch (direction) {
			case MouseDirection.Right:
				x += distance;
				if (x > batch.tile.width - padding) {
					x = batch.tile.width - padding;
					direction = MouseDirection.Left;
					change = false;
				}
			case MouseDirection.Left:
				x -= distance;
				if (x < 0) {
					x = 0;
					direction = MouseDirection.Right;
					change = false;
				}
			case MouseDirection.Down:
				y += distance;
				if (y > batch.tile.height - padding) {
					y = batch.tile.height - padding;
					direction = MouseDirection.Up;
					change = false;
				}
			case MouseDirection.Up:
				y -= distance;
				if (y < 0) {
					y = 0;
					direction = MouseDirection.Down;
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
