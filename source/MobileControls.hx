package;

#if android
import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSubState;
import openfl.display.Sprite;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.GradientType;
import openfl.geom.ColorTransform;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.utils.Assets;
import openfl.text.TextField;
import openfl.text.TextFormat;

/** A camera-independent overlay; one action remains held while any finger holds it. */
class MobileControls
{
	static var layer:Sprite;
	static var buttons:Array<TouchButton> = [];
	static var held:Map<String, Bool> = [];
	static var previous:Map<String, Bool> = [];
	static var ignoredTouches:Map<Int, Bool> = [];
	static var state:FlxState;
	static var substate:FlxSubState;
	static var playing:Bool = false;
	static var width:Int = 0;
	static var height:Int = 0;

	public static function install(parent:Sprite):Void
	{
		layer = new Sprite();
		layer.mouseEnabled = false;
		layer.mouseChildren = false;
		parent.addChild(layer);
		FlxG.signals.preUpdate.add(update);
		FlxG.signals.postDraw.add(draw);
		FlxG.signals.focusLost.add(clear);
	}

	static function clear():Void
	{
		held = [];
		previous = [];
		for (touch in FlxG.touches.list)
			if (touch.pressed) ignoredTouches.set(touch.touchPointID, true);
	}

	static function update():Void
	{
		// The bootstrap has its own screen; do not load overlay images during it.
		if (Std.isOfType(FlxG.state, AndroidBootstrapState))
		{
			clear();
			state = null;
			return;
		}
		var nextPlaying = Std.isOfType(FlxG.state, PlayState) && FlxG.state.subState == null
			&& !cast(FlxG.state, PlayState).inCutscene;
		if (state != FlxG.state || substate != FlxG.state.subState || playing != nextPlaying
			|| width != FlxG.width || height != FlxG.height)
		{
			clear();
			state = FlxG.state;
			substate = state.subState;
			playing = nextPlaying;
			width = FlxG.width;
			height = FlxG.height;
			buildLayout();
		}

		previous = held;
		held = [];
		var activeTouches:Map<Int, Bool> = [];
		for (touch in FlxG.touches.list)
		{
			if (!touch.pressed) continue;
			activeTouches.set(touch.touchPointID, true);
			if (ignoredTouches.exists(touch.touchPointID)) continue;
			// Later buttons (pause) take priority over an overlapping hitbox lane.
			var i = buttons.length;
			while (i-- > 0)
				if (buttons[i].containsPoint(touch.gameX, touch.gameY))
				{
					held.set(buttons[i].action, true);
					break;
				}
		}
		for (id in ignoredTouches.keys())
			if (!activeTouches.exists(id)) ignoredTouches.remove(id);
	}

	public static function check(action:String):Bool
	{
		var parts = action.toLowerCase().split('-');
		var down = held.exists(parts[0]);
		var wasDown = previous.exists(parts[0]);
		return switch (parts[1])
		{
			case 'press': down && !wasDown;
			case 'release': !down && wasDown;
			default: (parts[0] == 'accept' || parts[0] == 'back' || parts[0] == 'pause' || parts[0] == 'reset' || parts[0] == 'options') ? down && !wasDown : down;
		};
	}

	static function buildLayout():Void
	{
		layer.removeChildren();
		buttons = [];
		var directions = ['left', 'down', 'up', 'right'];
		var colors = [0xC24B99, 0x00FFFF, 0x12FA05, 0xF9393F];
		if (playing)
		{
			if (ClientPrefs.touchControlMode == 'Hitbox')
			{
				for (i in 0...4)
					add('note_' + directions[i], directions[i], i * width / 4, 0, width / 4, height, colors[i], true);
			}
			else
			{
				var size = ClientPrefs.touchButtonHeight;
				for (i in 0...4)
					add('note_' + directions[i], directions[i], (i + 0.5) * width / 4 - size / 2,
						ClientPrefs.touchButtonsTop ? 104 : height - size - 12, size, size, colors[i]);
			}
			add('pause', 'p', width - 92, 12, 80, 80, 0xFFFFFF);
		}
		else
		{
			// Psych-style D-pad with A/B action buttons.
			add('ui_left', 'left', 12, height - 208, 96, 96, colors[0]);
			add('ui_down', 'down', 112, height - 108, 96, 96, colors[1]);
			add('ui_up', 'up', 112, height - 308, 96, 96, colors[2]);
			add('ui_right', 'right', 212, height - 208, 96, 96, colors[3]);
			add('accept', 'a', width - 116, height - 116, 104, 104, 0xFF0000);
			add('back', 'b', width - 224, height - 220, 104, 104, 0xFFFF00);
			if (Std.isOfType(state, FreeplayState) || Std.isOfType(state, FreeplayStateFollowed))
				add('options', 'c', width - 104, 12, 92, 92, 0x00FFFF);
		}
	}

	static function add(action:String, icon:String, x:Float, y:Float, w:Float, h:Float, color:Int, hitbox:Bool = false):Void
	{
		var button = new TouchButton(action, icon, x, y, w, h, color, hitbox);
		buttons.push(button);
		layer.addChild(button);
	}

	static function draw():Void
	{
		layer.x = FlxG.game.x;
		layer.y = FlxG.game.y;
		layer.scaleX = FlxG.scaleMode.scale.x;
		layer.scaleY = FlxG.scaleMode.scale.y;
		layer.visible = !Std.isOfType(FlxG.state, AndroidBootstrapState);
		for (button in buttons) button.updateVisual(held.exists(button.action));
	}
}

private class TouchButton extends Sprite
{
	public var action:String;
	var buttonWidth:Float;
	var buttonHeight:Float;
	var hitbox:Bool;
	var bitmap:Bitmap;
	var frames:Array<BitmapData>;
	static var frameCache:Map<String, Array<BitmapData>> = [];

	public function new(action:String, icon:String, x:Float, y:Float, width:Float, height:Float, color:Int, hitbox:Bool)
	{
		super();
		this.action = action;
		this.x = x;
		this.y = y;
		this.hitbox = hitbox;
		buttonWidth = width;
		buttonHeight = height;
		if (hitbox)
		{
			graphics.lineStyle(3, color);
			if (ClientPrefs.touchHitboxStyle == 'Gradient')
			{
				var matrix = new Matrix();
				matrix.createGradientBox(width, height);
				graphics.beginGradientFill(GradientType.RADIAL, [color, color], [0, 0.7], [0, 255], matrix);
			}
			graphics.drawRect(2, 2, width - 4, height - 4);
			graphics.endFill();
		}
		else
		{
			frames = frameCache.get(icon);
			if (frames == null)
			{
				var asset = 'assets/images/mobile/' + icon + '.png';
				var sheet:BitmapData = null;
				try
				{
					if (Assets.exists(asset)) sheet = Assets.getBitmapData(asset);
				}
				catch (error:Dynamic) trace('Unable to load touch button: ' + asset);
				if (sheet != null && sheet.width >= 2 && sheet.width % 2 == 0 && sheet.height > 0)
				{
					var frameWidth = Std.int(sheet.width / 2);
					frames = [];
					for (i in 0...2)
					{
						var frame = new BitmapData(frameWidth, sheet.height, true, 0);
						frame.copyPixels(sheet, new Rectangle(i * frameWidth, 0, frameWidth, sheet.height), new Point());
						frames.push(frame);
					}
					frameCache.set(icon, frames);
				}
			}
			if (frames != null)
			{
				bitmap = new Bitmap(frames[0]);
				bitmap.width = width;
				bitmap.height = height;
				bitmap.smoothing = true;
				bitmap.transform.colorTransform = new ColorTransform(((color >> 16) & 255) / 255, ((color >> 8) & 255) / 255, (color & 255) / 255);
				addChild(bitmap);
			}
			else
			{
				// Keep menus usable even if a button sheet was omitted from the APK.
				graphics.lineStyle(3, color);
				graphics.beginFill(0x281D3D);
				graphics.drawRoundRect(0, 0, width, height, 18, 18);
				graphics.endFill();
				var label = new TextField();
				label.defaultTextFormat = new TextFormat('_sans', 32, 0xFFFFFF, true, null, null, null, null, 'center');
				label.text = switch (icon) { case 'left': '<'; case 'right': '>'; case 'up': '^'; case 'down': 'v'; default: icon.toUpperCase(); };
				label.width = width;
				label.height = 44;
				label.y = (height - 44) / 2;
				label.selectable = false;
				addChild(label);
			}
		}
		updateVisual(false);
	}

	public function updateVisual(pressed:Bool):Void
	{
		if (hitbox)
			alpha = pressed && ClientPrefs.touchHitboxStyle != 'Hidden' ? ClientPrefs.touchButtonOpacity : 0;
		else
		{
			if (bitmap != null) bitmap.bitmapData = frames[pressed ? 1 : 0];
			alpha = pressed ? Math.min(1, ClientPrefs.touchButtonOpacity + 0.4) : ClientPrefs.touchButtonOpacity;
		}
	}

	public function containsPoint(px:Float, py:Float):Bool
	{
		return px >= x && px < x + buttonWidth && py >= y && py < y + buttonHeight;
	}
}
#end
