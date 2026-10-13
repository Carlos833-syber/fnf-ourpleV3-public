package;

#if android
import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import haxe.Json;
import haxe.io.Path;
import lime.system.System;
import lime.utils.Assets;
import lime.utils.AssetLibrary;
import sys.FileSystem;
import sys.io.File;

/** APK assets are not ordinary files; Lua and the mod loader need real paths. */
class AndroidBootstrapState extends FlxState
{
	static inline var MARKER = '.bundled-assets.json';
	var manifest:AndroidManifest;
	var position:Int = 0;
	var status:FlxText;
	var failure:Bool = false;

	override public function create():Void
	{
		super.create();
		status = new FlxText(24, FlxG.height / 2 - 60, FlxG.width - 48, 'Preparing Ourple V3...', 28);
		status.alignment = CENTER;
		add(status);
		try
		{
			// Register native libraries without preloading their large images/audio into RAM.
			for (name in ['songs', 'shared', 'shaders', 'ourplesecrets'])
			{
				if (Assets.getLibrary(name) == null)
				{
					var library = AssetLibrary.fromFile('manifest/' + name + '.json', 'manifest');
					if (library == null) throw 'Missing asset library: ' + name;
					Assets.registerLibrary(name, library);
				}
			}
			var storage = System.applicationStorageDirectory;
			FileSystem.createDirectory(storage);
			Sys.setCwd(storage);
			manifest = Json.parse(Assets.getText('assets/android-files.json'));
			for (entry in manifest.files)
			{
				validatePath(entry.path);
				if (!Reflect.hasField(entry, 'size') || entry.size < 0)
					throw 'Outdated asset manifest. Update scripts/prepare_android_assets.py and rebuild the APK.';
			}
			if (FileSystem.exists(MARKER))
			{
				var old:AndroidManifest = Json.parse(File.getContent(MARKER));
				if (old.version == manifest.version && allFilesExist())
				{
					FlxG.switchState(new TitleState());
					return;
				}
				// Remove only files previously managed by this bootstrap.
				var current:Map<String, Bool> = [];
				for (entry in manifest.files) current.set(entry.path, true);
				for (entry in old.files)
				{
					validatePath(entry.path);
					if (!current.exists(entry.path) && FileSystem.exists(entry.path) && !FileSystem.isDirectory(entry.path))
						FileSystem.deleteFile(entry.path);
				}
			}
		}
		catch (error:Dynamic) showError(error);
	}

	function allFilesExist():Bool
	{
		for (entry in manifest.files)
			if (!FileSystem.exists(entry.path)) return false;
		return true;
	}

	static function validatePath(path:String):Void
	{
		if (path == null || (!StringTools.startsWith(path, 'mods/') && !StringTools.startsWith(path, 'assets/'))
			|| path.indexOf('..') != -1 || path.indexOf('\\') != -1 || path.indexOf(':') != -1)
			throw 'Invalid bundled asset path';
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		if (failure) return;
		try
		{
			// Yield between files so Android keeps drawing and processing events.
			var start = haxe.Timer.stamp();
			while (position < manifest.files.length && haxe.Timer.stamp() - start < 0.01)
			{
				var entry = manifest.files[position];
				// Lime returns null for zero-byte native files; they are valid mod metadata.
				var bytes = entry.size == 0 ? lime.utils.Bytes.alloc(0) : Assets.getBytes(entry.path);
				if (bytes == null) throw 'Missing APK asset: ' + entry.path;
				FileSystem.createDirectory(Path.directory(entry.path));
				File.saveBytes(entry.path + '.tmp', bytes);
				FileSystem.rename(entry.path + '.tmp', entry.path);
				position++;
			}
			status.text = 'Preparing Ourple V3... ' + Std.int(position * 100 / manifest.files.length) + '%\n'
				+ 'Bundled files are copied on the first launch. Please wait.';
			if (position == manifest.files.length)
			{
				File.saveContent(MARKER + '.tmp', Json.stringify(manifest));
				FileSystem.rename(MARKER + '.tmp', MARKER);
				FlxG.switchState(new TitleState());
			}
		}
		catch (error:Dynamic) showError(error);
	}

	function showError(error:Dynamic):Void
	{
		failure = true;
		status.text = 'Unable to prepare game files.\nCheck available storage and restart the app.\n' + Std.string(error);
	}
}

private typedef AndroidManifest =
{
	var version:String;
	var files:Array<{path:String, size:Int, sha256:String}>;
}
#end
