package lazycat;

import lazycat.Constants.BigFontNumbers;
import lazycat.Constants.ImageSizes;
import lazycat.Constants.MiscFloats;
import lazycat.Constants.SmallFontNumbers;
import lazycat.Constants.TextStrings;

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

class Game extends hxd.App {

	var assets:Assets;
	var cat:h2d.SpriteBatch;
	var catEyes:Cat;
	var catFace:Cat;
	var laser:h2d.Graphics;
	var mice:h2d.SpriteBatch;
	var pausedOverlay:h2d.Bitmap;
	var pausedText:h2d.Text;
	var timer:Float;
	var timerText:h2d.Text;

	var paused:Bool;
	var winner:Bool;

	public function new(assets:Assets) {
		super();
		this.assets = assets;

		timer = 0;

		paused = false;
		winner = false;

		assets.initFonts();
		assets.initMusic();
		assets.initSprites();
	}

	override function init() {
		hxd.System.setNativeCursor(hxd.Cursor.Hide);
		s2d.scaleMode = h2d.Scene.ScaleMode.LetterBox(ImageSizes.screenWidth, ImageSizes.screenHeight);

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

		timerText = new h2d.Text(assets.smallFont);
		printScore();
		timerText.textColor = SmallFontNumbers.colour;
		s2d.addChild(timerText);

		pausedText = new h2d.Text(assets.bigFont);
		pausedText.text = TextStrings.paused;
		pausedText.textColor = BigFontNumbers.colour;
		pausedText.dropShadow = {
			dy: BigFontNumbers.dropShadowY,
			dx: BigFontNumbers.dropShadowX,
			color: BigFontNumbers.dropShadowColour,
			alpha: 1
		};
		pausedOverlay = new h2d.Bitmap(h2d.Tile.fromColor(0, ImageSizes.screenWidth, ImageSizes.screenHeight, MiscFloats.overlayAlpha));

		s2d.addEventListener(checkPause);
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
				pausedText.x = ImageSizes.screenWidth / 2 - pausedText.textWidth / 2;
				pausedText.y = ImageSizes.screenHeight / 2 - pausedText.textHeight / 2;
			}
			else if (!paused && pausedText.parent != null) {
				s2d.removeChild(pausedOverlay);
				s2d.removeChild(pausedText);
			}
		}
	}

	function generateWinningText() {
		var winningText:h2d.Text = new h2d.Text(assets.bigFont);
		winningText.text = TextStrings.winner;
		winningText.textColor = BigFontNumbers.colour;
		winningText.dropShadow = {
			dy: BigFontNumbers.dropShadowY,
			dx: BigFontNumbers.dropShadowX,
			color: BigFontNumbers.dropShadowColour,
			alpha: 1
		};
		s2d.addChild(winningText);
		winningText.x = ImageSizes.screenWidth / 2 - winningText.textWidth / 2;
		winningText.y = ImageSizes.screenHeight / 2 - winningText.textHeight / 2;

		var backText:h2d.Text = new h2d.Text(assets.smallFont);
		backText.text = TextStrings.back;
		backText.textColor = SmallFontNumbers.colour;

		var backInteraction:h2d.Interactive = new h2d.Interactive(backText.textWidth,
																	backText.textHeight,
																	backText);
		backInteraction.onOver = function(event:hxd.Event) {
			backText.textColor = SmallFontNumbers.selectColour;
		}
		backInteraction.onOut = function(event:hxd.Event) {
			backText.textColor = SmallFontNumbers.colour;
		}
		backInteraction.onClick = function(event:hxd.Event) {
			hxd.System.setNativeCursor(hxd.Cursor.Default);
			assets.music.pause = true;
			new Main(assets);
		}

		s2d.addChild(backText);
		backText.x = ImageSizes.screenWidth / 2 - backText.textWidth / 2;
		backText.y = winningText.y + winningText.textHeight;
	}

	override function update(dt:Float) {
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
			s2d.over(timerText);

			generateWinningText();
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

		timer += 1;
		printScore();
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

	inline function printScore() {
		timerText.text = TextStrings.scorePrefix + Std.string(timer);
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