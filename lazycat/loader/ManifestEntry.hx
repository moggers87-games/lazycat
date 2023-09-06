package lazycat.loader;

import hxd.net.BinaryLoader;
import hxd.impl.ArrayIterator;
import hxd.fs.LoadedBitmap;
import hxd.fs.FileEntry;
import haxe.io.Bytes;

@:allow(lazycat.loader.ManifestFileSystem)
class ManifestEntry extends FileEntry {

	var fs:ManifestFileSystem;
	var relPath:String;

	var isDir:Bool;
	var contents:Array<ManifestEntry>;

	var file:String;
	var originalFile:String;
	#if sys
	var fio:sys.io.FileInput;
	#else
	var bytes:Bytes;
	var loaded:Bool;
	#end

	public function new(fs:ManifestFileSystem, name:String, relPath:String, file:String, ?originalFile:String) {
		this.fs = fs;
		this.name = name;
		this.relPath = relPath;
		this.originalFile = originalFile;
		this.file = file;
		if (file == null) {
			isDir = true;
			contents = [];
		}
	}

	override public function readBytes( out : haxe.io.Bytes, outPos : Int, pos : Int, len : Int ) : Int {
		#if sys
		if (fio == null) {
			fio = sys.io.File.read(file);
		}
		fio.seek(pos, SeekBegin);
		var tot:Int = fio.readBytes(out, outPos, len);
		fio.close();
		return tot;
		#else
		if ( pos + len > bytes.length ) {
			len = bytes.length - pos;
		}
		if ( len < 0 ) len = 0;
		out.blit(outPos, bytes, pos, len);
		return len;
		#end
	}

	override public function getBytes():Bytes {
		#if sys
		return sys.io.File.getBytes(file);
		#else
		return bytes;
		#end
	}

	public function fancyLoad(onReady:() -> Void, onProgress:(cur:Int, max:Int) -> Void) {
		#if js
		if (loaded) {
			haxe.Timer.delay(onReady, 1);
		}
		else {
			var br = new BinaryLoader(file);
			br.onLoaded = function(b) {
				loaded = true;
				bytes = b;
				onReady();
			}
			br.onProgress = onProgress;
			br.load();
		}
		#else
		load(onReady);
		#end
	}

	override public function load(?onReady:() -> Void) {
		#if macro
		onReady();
		#elseif js
		function bytesLoad(buf:js.lib.ArrayBuffer) {
			loaded = true;
			bytes = Bytes.ofData(buf);
			if (onReady != null) onReady();
		}

		if (loaded) {
			if (onReady != null) haxe.Timer.delay(onReady, 1);
		}
		else {
			js.Browser.window.fetch(file).then(
				res -> res.arrayBuffer()
			).then(bytesLoad);
		}
		#else
		if (onReady != null) haxe.Timer.delay(onReady, 1);
		#end
	}

	override public function loadBitmap(onLoaded:LoadedBitmap -> Void) {
		#if sys
		var bmp = new hxd.res.Image(this).toBitmap();
		onLoaded(new hxd.fs.LoadedBitmap(bmp));
		#elseif js
		function fn() {
			var img = new js.html.Image();
			img.onload = _ -> onLoaded(new LoadedBitmap(img));
			img.src = file;
		}
		load(fn);
		#else
		throw "Unsupported platform";
		#end
	}

	override public function exists(name:String):Bool {
		if (isDir) {
			for (c in contents) if (c.name == name) return true;
		}
		return false;
	}

	override public function get(name:String):ManifestEntry {
		if (isDir) {
			for (c in contents) if (c.name == name) return c;
		}
		return null;
	}

	override public function iterator():ArrayIterator<FileEntry> {
		if (isDir) {
			return new ArrayIterator(cast contents);
		}
		return null;
	}

	#if !sys
	override function get_isAvailable():Bool {
		return loaded;
	}
	#end

	override function get_isDirectory():Bool {
		return isDir;
	}

	override function get_path():String {
		if (relPath == ".") return "<root>";
		return relPath;
	}

	override function get_size():Int {
		#if sys
		return sys.FileSystem.stat(file).size;
		#else
		var size = 0;
		if (bytes != null) size = bytes.length;
		return size;
		#end
	}

	function dispose() {
		if (isDir) {
			for (c in contents) c.dispose();
			contents = null;
		}
		#if sys
		fio.close();
		#else
		bytes = null;
		#end
	}

}
