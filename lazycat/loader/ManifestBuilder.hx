package lazycat.loader;

import hxd.res.EmbedOptions;
import haxe.io.Path;
import haxe.io.Bytes;

typedef ManifestFileInfo = {
	var path:String;
	var original:String;
}

class ManifestBuilder {

	@SuppressWarnings("checkstyle:Return")
	macro public static function initManifest(?basePath:String, ?options:hxd.res.EmbedOptions, ?storeManifest:String) {
		@SuppressWarnings("checkstyle:VarTypeHint")
		var data = makeManifest(basePath, options, storeManifest);
		if (basePath == null) basePath = "res";
		return macro {
			var loader = new lazycat.loader.ManifestLoader(
				@:privateAccess new lazycat.loader.ManifestFileSystem($v{basePath}, haxe.io.Bytes.ofString($v{data.manifest.toString()}))
			);
			hxd.Res.loader = loader;
			loader;
		}
	}

	@SuppressWarnings("checkstyle:Return")
	macro public static function generate(?basePath:String, ?options:hxd.res.EmbedOptions, ?storeManifest:String) {
		makeManifest(basePath, options, storeManifest);
		return macro {};
	}

	@SuppressWarnings("checkstyle:Return")
	macro public static function create(?basePath:String, ?options:hxd.res.EmbedOptions, ?storeManifest:String) {
		@SuppressWarnings("checkstyle:VarTypeHint")
		var data = makeManifest(basePath, options, storeManifest);

		return macro @:privateAccess new engine.utils.fs.ManifestFileSystem($v{basePath}, haxe.io.Bytes.ofString($v{data.manifest.toString()}));
	}

	#if macro

	private static function makeManifest(?basePath : String, ?options : hxd.res.EmbedOptions, ?storeManifest:String) {
		var f = new hxd.res.FileTree(basePath);
		var manifest:Bytes = build(f, options);

		if (storeManifest != null) {
			if (!haxe.macro.Context.defined("display")) {
				#if !display
				var tmp:String = Path.join([@:privateAccess f.paths[0], storeManifest + ".manifest"]);
				sys.io.File.saveBytes(tmp, manifest);
				#end
			}
		}
		return { tree: f, manifest: manifest };
	}

	public static function build(tree:hxd.res.FileTree, ?options:hxd.res.EmbedOptions, ?manifestOptions:ManifestOptions):Bytes {
		var manifest = new Array<ManifestFileInfo>();
		scan(tree, options, manifest);

		if (manifestOptions == null) {
			manifestOptions = { format: ManifestFormat.json };
		}
		if (manifestOptions.format == null) manifestOptions.format = ManifestFormat.list;

		switch (manifestOptions.format) {
			case json:
				return haxe.io.Bytes.ofString(haxe.Json.stringify(manifest));
			case v:
				throw "unsupported manifest foramt: " + v;
		}
	}

	static var options:EmbedOptions;
	static function scan(t:hxd.res.FileTree, _options:EmbedOptions, out:Array<ManifestFileInfo>) {
		if ( _options == null ) _options = {};
		ManifestBuilder.options = _options;

		var tree:hxd.res.FileTree.FileTreeData = @:privateAccess t.scan();

		for ( path in @:privateAccess t.paths ) {
			var fs = new hxd.fs.LocalFileSystem(path, options.configuration);
			fs.convert.onConvert = function(f) Sys.println("Converting " + f.srcPath);
			convertRec(tree, path, fs, out);
		}
		return tree;
	}

	static function convertRec(tree:hxd.res.FileTree.FileTreeData, basePath:String, fs:hxd.fs.LocalFileSystem, out:Array<ManifestFileInfo>) {
		@:privateAccess for( file in tree.files ) {
			// try later with another fs
			if (!StringTools.startsWith(file.fullPath, basePath)) continue;
			@SuppressWarnings("checkstyle:VarTypeHint")
			var info = { path: file.relPath, original: file.relPath };
			out.push(info);
			var f:hxd.fs.LocalFileSystem.LocalEntry = fs.get(file.relPath); // convert
			if (f.originalFile != null && f.originalFile != f.file) {
				info.original = f.relPath;
				info.path = StringTools.startsWith(f.file, fs.baseDir) ? f.file.substr(fs.baseDir.length) : f.file;
			}
		}

		for (t in tree.dirs) convertRec(t, basePath, fs, out);
	}
	#end
}

typedef ManifestOptions = {
	@:optional var format:ManifestFormat;
}

enum ManifestFormat {
	keyValue;
	list;
	serialized;
	json;
}
