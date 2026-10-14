package;

#if android
import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSubState;
import openfl.display.Sprite;
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
			for (button in buttons)
				if (button.containsPoint(touch.gameX, touch.gameY)) held.set(button.action, true);
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
		if (playing)
		{
			var buttonWidth = (width - 60) / 4;
			for (i in 0...4)
				add('note_' + directions[i], directions[i].toUpperCase(), 12 + i * (buttonWidth + 12),
					ClientPrefs.touchButtonsTop ? 104 : height - ClientPrefs.touchButtonHeight - 12, buttonWidth, ClientPrefs.touchButtonHeight);
			add('pause', 'PAUSE', width - 172, 16, 156, 76);
		}
		else
		{
			for (i in 0...4)
				add('ui_' + directions[i], directions[i].toUpperCase(), 12 + i * 122, height - 122, 110, 110);
			add('accept', 'OK', width - 172, height - 122, 156, 110);
			add('back', 'BACK', width - 172, height - 242, 156, 100);
			if (Std.isOfType(state, FreeplayState) || Std.isOfType(state, FreeplayStateFollowed))
				add('options', 'SETTINGS', width - 172, 16, 156, 76);
		}
	}

	static function add(action:String, label:String, x:Float, y:Float, w:Float, h:Float):Void
	{
		var button = new TouchButton(action, label, x, y, w, h);
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
		for (button in buttons) button.alpha = held.exists(button.action) ? Math.min(1, ClientPrefs.touchButtonOpacity + 0.4) : ClientPrefs.touchButtonOpacity;
	}
}

private class TouchButton extends Sprite
{
	public var action:String;
	var buttonWidth:Float;
	var buttonHeight:Float;

	public function new(action:String, label:String, x:Float, y:Float, width:Float, height:Float)
	{
		super();
		this.action = action;
		this.x = x;
		this.y = y;
		buttonWidth = width;
		buttonHeight = height;
		graphics.lineStyle(3, 0xFFFFFF);
		graphics.beginFill(0x281D3D);
		graphics.drawRoundRect(0, 0, width, height, 18, 18);
		graphics.endFill();
		var text = new TextField();
		text.defaultTextFormat = new TextFormat('_sans', 24, 0xFFFFFF, true, null, null, null, null, 'center');
		text.text = label;
		text.width = width;
		text.height = 36;
		text.y = (height - 36) / 2;
		text.selectable = false;
		addChild(text);
	}

	public function containsPoint(px:Float, py:Float):Bool
	{
		return px >= x && px < x + buttonWidth && py >= y && py < y + buttonHeight;
	}
}
#end
