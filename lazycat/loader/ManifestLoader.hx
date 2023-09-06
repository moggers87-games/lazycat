package lazycat.loader;

@:allow(lazycat.loader.ManifestLoader.LoaderTask)
class ManifestLoader extends hxd.res.Loader {

	/**
		Amount of concurrent file loadings. Defaults to 4 on JS and to 1 native (since there's no threaded loading implemented for native)
	**/
	public static final CONCURRENT_FILES:Int = #if js 4 #else 1 #end;

	public var mfs:ManifestFileSystem;

	public var totalFiles(default, null):Int;
	public var loadedFiles(default, null):Int;
	public var loading(default, null):Bool;

	var entries:Iterator<ManifestEntry>;
	var current:ManifestEntry;
	/**
		List of loading tasks used during loading.
	**/
	public var tasks:Array<LoaderTask>;

	public function new(fs:ManifestFileSystem) {
		super(fs);
		mfs = fs;
		totalFiles = 0;
		for (f in fs.manifest) totalFiles++;
		loadedFiles = 0;
		loading = false;
	}

	public function loadManifestFiles() {
		if (!loading) {
			tasks = [];
			for (i in 0...CONCURRENT_FILES) tasks.push(@:privateAccess new LoaderTask(i, this));
			loading = true;
			entries = mfs.manifest.iterator();
			for (t in tasks) {
				if (entries.hasNext()) t.load(entries.next());
				else break;
			}
		}
	}

	function next(task:LoaderTask) {
		loadedFiles++;
		onFileLoaded(task);
		if (entries.hasNext()) task.load(entries.next());
		else {
			for (t in tasks) if (t.busy) return;
			loading = false;
			tasks = null;
			onLoaded();
		}
	}

	// Called when loader starts loading of specific file.
	public dynamic function onFileLoadStarted(task:LoaderTask) {}

	// Called during file loading. loaded and total refer to loaded bytes and total file size.
	public dynamic function onFileProgress(task:LoaderTask) {}

	// Called when file is loaded.
	public dynamic function onFileLoaded(task:LoaderTask) {}

	public dynamic function onLoaded() {}

}

class LoaderTask {

	public var entry(default, null):ManifestEntry;
	/** Loading slot occupied by this task **/
	public var slot(default, null):Int;
	public var loaded(default, null):Int;
	public var total(default, null):Int;
	public var owner(default, null):ManifestLoader;
	public var busy(default, null):Bool;

	function new(slot:Int, owner:ManifestLoader) {
		this.slot = slot;
		this.owner = owner;
	}

	public function load(entryObj:ManifestEntry) {
		entry = entryObj;
		loaded = 0;
		total = 1;
		busy = true;
		owner.onFileLoadStarted(this);
		entry.fancyLoad(ready, progress);
	}

	function ready() {
		busy = false;
		@:privateAccess owner.next(this);
	}

	function progress(l:Int, t:Int) {
		loaded = l;
		total = t;
		owner.onFileProgress(this);
	}

}
