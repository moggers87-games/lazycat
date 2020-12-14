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
}

enum abstract MiscFloats(Float) from Float to Float {
	var musicVolume = 0.25;
	var percentMultiplier = 0.01;
	var overlayAlpha = 0.5;
	var catScalePercent = 0.2;
	var mouseScalePercent = 0.1;
}
