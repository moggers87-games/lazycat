package lazycat;

import lazycat.Constants.MiscInts;
import lazycat.Constants.MiscFloats;

class Options {

	var savePath:String;
	var data:Dynamic;
	var defaults:Dynamic;

	public function new() {
		defaults = generateDefaults();

		savePath = "data";

		#if sys
		try {
			var xdgConfig:String = Sys.getEnv("XDG_CONFIG_HOME");
			if (xdgConfig == null) {
				xdgConfig = haxe.io.Path.join([Sys.getEnv("HOME"), ".config"]);
			}
			var saveDir:String = haxe.io.Path.join([xdgConfig, "lazycat"]);
			if (!sys.FileSystem.exists(saveDir)) {
				sys.FileSystem.createDirectory(saveDir);
			}
			savePath = haxe.io.Path.join([saveDir, savePath]);
		}
		catch (e) {
			Sys.stderr().writeString("Couldn't create config directory, saving data to current working directory instead");
		}
		#end
	}

	public function load() {
		var serialised:String;
		#if sys
		try {
			serialised = sys.io.File.getContent(savePath);
		}
		catch (e) {
			Sys.stderr().writeString("Couldn't find config dir");
			serialised = "{}";
		}
		#elseif js
		serialised = js.Browser.window.localStorage.getItem(savePath);
		#else
		throw "Not implemented";
		#end
		data = haxe.Json.parse(serialised);
	}

	public function save() {
		if (data == null) {
			data = {};
		}
		var serialised:String = haxe.Json.stringify(data);
		#if sys
		sys.io.File.saveContent(savePath, serialised);
		#elseif js
		js.Browser.window.localStorage.setItem(savePath, serialised);
		#else
		throw "Not implemented";
		#end
		load();
	}

	public function get(key:String):Dynamic {
		if (data == null) {
			load();
		}
		var result:Dynamic = Reflect.field(data, key);
		if (result == null) {
			return Reflect.field(defaults, key);
		}
		else {
			return result;
		}
	}

	public function set(key:String, value) {
		if (data == null) {
			data = {};
		}
		Reflect.setField(data, key, value);
	}

	inline function generateDefaults():Dynamic {
		return {
			"highscore": MiscInts.defaultHighScore,
			"musicVolume": MiscFloats.musicVolume,
			"laserVolume": MiscFloats.laserVolume,
		};
	}
}
