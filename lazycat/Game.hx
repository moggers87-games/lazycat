package lazycat;

import lazycat.Constants.BigFontNumbers;
import lazycat.Constants.Controls;
import lazycat.Constants.ImageSizes;
import lazycat.Constants.MediumFontNumbers;
import lazycat.Constants.MiscFloats;
import lazycat.Constants.MiscInts;
import lazycat.Constants.SmallFontNumbers;
import lazycat.Constants.TextStrings;
import gameUtils.RandomUtils;
import gameUtils.State;

enum abstract LaserNumbers(Int) from Int to Int {
	var eyePulseMin = 8;
	var eyePulseMax = 15;
	var eyeOffsetX = 40;
	var eyeOffsetY = 15;
	var colour = 0xFF0000;
	var pulseColour = 0xFF33CC;
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
	var reproduceFrame = 50;
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
	var backInteraction:h2d.Interactive;
	var backText:h2d.Text;
	var cat:h2d.SpriteBatch;
	var catEyes:Cat;
	var catFace:Cat;
	var highScore:Int;
	var highScoreText:h2d.Text;
	var laser:h2d.Graphics;
	var mice:h2d.SpriteBatch;
	var miceCount:Int;
	var pausedOverlay:h2d.Bitmap;
	var pausedText:h2d.Text;
	var timer:Int;
	var timerText:h2d.Text;

	var paused:State<Bool>;
	var winner:State<Bool>;

	public function new(assets:Assets) {
		super();
		this.assets = assets;

		timer = 0;
		highScore = assets.options.get("highscore");

		paused = new State(false);
		winner = new State(false);

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
		catFace.x = ImageSizes.screenWidth / 2;
		catFace.y = ImageSizes.screenHeight / 2;

		mice = new h2d.SpriteBatch(assets.sprites);
		miceCount = MouseNumbers.initialCount;
		mice.hasUpdate = true;
		mice.hasRotationScale = true;
		for (i in 0...MouseNumbers.initialCount) {
			var mouse = new Mouse(assets.mouseTile(), paused);
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

		highScoreText = new h2d.Text(assets.smallFont);
		highScoreText.text = TextStrings.highScorePrefix + Std.string(highScore);
		highScoreText.textColor = SmallFontNumbers.colour;
		s2d.addChild(highScoreText);
		highScoreText.y = timerText.y + timerText.textHeight;

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
		s2d.addEventListener(moveCat);

		paused.addChangeHandler(setPause);
		winner.addChangeHandler(setWinner);
	}

	function moveCat(event:hxd.Event) {
		if (event.kind == EMove) {
			event.propagate = false;
			catFace.x = event.relX - catFace.scaledWidth / 2;
			catFace.y = event.relY - catFace.scaledHeight / 2;
		}
	}

	function checkPause(event:hxd.Event) {
		switch (event.kind) {
			case EFocusLost:
				paused.change(true);
			case EKeyDown:
				if (paused.value && Controls.BACK.contains(event.keyCode)) {
					backToMain();
				}
				else if (Controls.PAUSE.contains(event.keyCode)) {
					paused.change(!paused.value);
				}
				else {
					paused.change(false);
				}
			case EPush:
				paused.change(false);
			default:
				return;
		}
	}

	function setPause(oldState:Bool, newState:Bool) {
		if (oldState == newState) {
			return;
		}
		assets.music.pause = newState;

		if (newState) {
			hxd.System.setNativeCursor(hxd.Cursor.Default);
			assets.stopLaser();
			s2d.addChild(pausedOverlay);
			s2d.addChild(pausedText);
			pausedText.x = ImageSizes.screenWidth / 2 - pausedText.textWidth / 2;
			pausedText.y = ImageSizes.screenHeight / 2 / 2 - pausedText.textHeight / 2;
			addBackText(pausedText);

			s2d.removeEventListener(moveCat);
		}
		else {
			hxd.System.setNativeCursor(hxd.Cursor.Hide);
			s2d.removeChild(pausedOverlay);
			s2d.removeChild(pausedText);
			s2d.removeChild(backText);

			s2d.addEventListener(moveCat);
		}
	}

	function setWinner(oldState:Bool, newState:Bool) {
		hxd.System.setNativeCursor(hxd.Cursor.Default);
		assets.music.pause = true;
		assets.stopLaser();
		s2d.addChild(pausedOverlay);
		s2d.over(timerText);
		s2d.over(highScoreText);

		if (timer < highScore) {
			assets.options.set("highscore", timer);
		}
		generateWinningText();

		s2d.addEventListener(function (event:hxd.Event) {
			if (event.kind == EKeyDown && Controls.BACK.contains(event.keyCode)) {
				backToMain();
			}
		});
		s2d.removeEventListener(moveCat);
		s2d.removeEventListener(checkPause);
	}

	function generateWinningText() {
		var winningText = new h2d.Text(assets.bigFont);
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
		winningText.y = ImageSizes.screenHeight / 2 / 2 - winningText.textHeight / 2;

		addBackText(winningText);
	}

	function addBackText(textAbove:h2d.Text) {
		backText = new h2d.Text(assets.mediumFont);
		backText.text = TextStrings.mainMenuBack;
		backText.textColor = MediumFontNumbers.colour;

		backInteraction = new h2d.Interactive(textAbove.textWidth,
													backText.textHeight,
													backText);
		backInteraction.onOver = function(event:hxd.Event) {
			backText.textColor = MediumFontNumbers.selectColour;
		}
		backInteraction.onOut = function(event:hxd.Event) {
			backText.textColor = MediumFontNumbers.colour;
		}
		backInteraction.onClick = function(event:hxd.Event) {
			backToMain();
		}

		s2d.addChild(backText);
		backText.x = ImageSizes.screenWidth / 2 - backText.textWidth / 2;
		backText.y = textAbove.y + textAbove.textHeight;
	}

	override function update(dt:Float) {
		if (paused.value || winner.value) {
			return;
		}

		laser.clear();
		catEyes.remove();

		if (mice.isEmpty()) {
			winner.change(true);

			return;
		}

		keyboardMovement();
		fireLasers();

		if (miceCount < MouseNumbers.maxCount && hxd.Timer.frameCount % MouseNumbers.reproduceFrame == 0) {
			var lastMouse:Mouse = cast(mice.getElements().next(), Mouse);
			var mouse = new Mouse(assets.mouseTile(), paused);
			mice.add(mouse);
			miceCount += 1;
			mouse.x = lastMouse.x;
			mouse.y = lastMouse.y;
		}

		timer += 1;
		printScore();
	}

	function fireLasers() {
		if (Controls.isDown(Controls.FIRELASERS)) {
			cat.add(catEyes);
			catEyes.x = catFace.x;
			catEyes.y = catFace.y;
			var catCentre:Array<Float> = catFace.centre;
			for (m in mice.getElements()) {
				var chosenMouse:Mouse = cast(m, Mouse);
				var mouseCentre:Array<Float> = chosenMouse.centre;
				var distance:Float = Math.pow(catCentre[0] - mouseCentre[0], 2) + Math.pow(catCentre[1] - mouseCentre[1], 2);
				if (Math.floor(distance) <= LaserNumbers.squareOfMaxLaserDistance) {
					fireAt(chosenMouse, catCentre, mouseCentre);
					assets.fireLaser();
					return;
				}
			}
		}

		assets.stopLaser();
	}

	function fireAt(mouse:Mouse, catCentre:Array<Float>, mouseCentre:Array<Float>) {
		var rightEyeX:Float = catCentre[0] + LaserNumbers.eyeOffsetX;
		var rightEyeY:Float = catCentre[1] + LaserNumbers.eyeOffsetY;
		var leftEyeX:Float = catCentre[0] - LaserNumbers.eyeOffsetX;
		var leftEyeY:Float = rightEyeY;

		var eyePulse:Int = RandomUtils.randomInt(LaserNumbers.eyePulseMin, LaserNumbers.eyePulseMax);
		laser.beginFill(LaserNumbers.pulseColour, 1);
		laser.lineStyle(0, 0, 0);
		laser.drawCircle(rightEyeX, rightEyeY, eyePulse);
		laser.drawCircle(leftEyeX, leftEyeY, eyePulse);
		laser.drawCircle(mouseCentre[0], mouseCentre[1], RandomUtils.randomInt(LaserNumbers.eyePulseMin, LaserNumbers.eyePulseMax));

		laser.beginFill(0, 0);
		laser.lineStyle(LaserNumbers.width, LaserNumbers.colour);

		laser.moveTo(rightEyeX, rightEyeY);
		laser.lineTo(mouseCentre[0], mouseCentre[1]);
		laser.moveTo(leftEyeX, leftEyeY);
		laser.lineTo(mouseCentre[0], mouseCentre[1]);
		laser.endFill();

		mouse.hit();
		if (mouse.batch == null) {
			miceCount -= 1;
		}
	}

	function keyboardMovement() {
		var x = 0;
		var y = 0;
		if (Controls.isDown(Controls.MOVERIGHT)) {
			x += MiscInts.catMove;
		}
		if (Controls.isDown(Controls.MOVELEFT)) {
			x -= MiscInts.catMove;
		}
		if (Controls.isDown(Controls.MOVEDOWN)) {
			y += MiscInts.catMove;
		}
		if (Controls.isDown(Controls.MOVEUP)) {
			y -= MiscInts.catMove;
		}

		if (x != 0 && y != 0) {
			x = Math.floor(x / 2);
			y = Math.floor(y / 2);
		}

		catFace.x += x;
		catFace.y += y;
	}

	function backToMain() {
		hxd.System.setNativeCursor(hxd.Cursor.Default);
		assets.options.save();
		new Main(assets);
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
	var paused:State<Bool>;

	public function new(t:h2d.Tile, paused:State<Bool>) {
		super(t);
		this.paused = paused;
		health = MouseNumbers.initialHealth;
		scale = MiscFloats.mouseScalePercent;
		changeDirection();
	}

	function changeDirection() {
		direction = RandomUtils.randomInt(0, MouseDirection.all);
	}

	override function update(dt:Float):Bool {
		if (paused.value) {
			return true;
		}
		var distance:Int = RandomUtils.randomInt(MouseNumbers.distanceMin, MouseNumbers.distanceMax);
		var change:Bool = RandomUtils.randomChance(MouseNumbers.directionChance);

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
