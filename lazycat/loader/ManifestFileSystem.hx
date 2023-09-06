package lazycat.loader;

import hxd.fs.NotFound;
import hxd.fs.FileEntry;
import hxd.fs.FileSystem;
import haxe.io.Path;
import haxe.io.Bytes;

class ManifestFileSystem implements FileSystem {

	var baseDir:String;
	public var manifest:Map<String, ManifestEntry>;

	var root : ManifestEntry;

	public function new(dir:String, _manifest:Bytes) {
		this.baseDir = Path.addTrailingSlash(dir);
		this.root = new ManifestEntry(this, "<root>", ".", null);

		this.manifest = new Map();

		inline function insert(path:String, file:String, original:String):Void {
			var dir:Array<String> = Path.directory(original).split("/");
			var r:ManifestEntry = root;
			for (n in dir) {
				if (n == "") continue;
				var found = false;
				for (c in r.contents) {
					if (c.name == n) {
						r = c;
						found = true;
						break;
					}
				}
				if (!found) {
					var dirEntry = new ManifestEntry(this, n, r.relPath + "/" + n, null);
					r.contents.push(dirEntry);
					r = dirEntry;
				}
			}
			var entry = new ManifestEntry(this, Path.withoutDirectory(original), original, file, original);
			r.contents.push(entry);
			manifest.set(path, entry);
		}

		switch (_manifest.get(0)) {
			case 0:
				// binary
				throw "Binary manifest not yet supported!";
			case 1:
				// serialized
				throw "Serialized manifest not yet supported!";
			case "m".code:
				// id:path mapping
				throw "Mapping manifest not yet supported";
			case "l".code:
				// path mapping
				throw "List manifest not yet supported";
			case "[".code:
				// JSON
				var json:Array<{ path:String, original:String }> = haxe.Json.parse(_manifest.toString());
				for (entry in json) {
					insert(entry.path, baseDir + entry.path, entry.original);
				}
		}
	}

	public function getRoot():FileEntry {
		return root;
	}

	function splitPath(path:String):Array<String> {
		if (path == ".") return [];
		return path.split("/");
	}

	function find(path:String):ManifestEntry {
		var r:ManifestEntry = root;
		for (p in splitPath(path)) {
			r = r.get(p);
			if (r == null) return null;
		}
		return r;
	}

	public function exists( path : String ):Bool {
		return find(path) != null;
	}

	public function get(path:String):ManifestEntry {
		var entry:ManifestEntry = find(path);
		if (entry == null) throw new NotFound(path);
		return entry;
	}

	public function dispose() {
		root.dispose();
		root = null;
	}

	public function dir(path:String) : Array<FileEntry> {
		var entry:ManifestEntry = find(path);
		if (entry == null) throw new NotFound(path);
		return cast entry.contents.copy();
	}

}
