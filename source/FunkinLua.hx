package;

#if LUA_ALLOWED

import openfl.display.BitmapData;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
import flixel.sound.FlxSound;
import flixel.input.keyboard.FlxKey;
import openfl.utils.Assets;
import openfl.filters.BitmapFilter;

#if sys
import sys.FileSystem;
import sys.io.File;
#end

using StringTools;

/*
 * FunkinLua
 *
 * Este arquivo contém a implementação Lua original.
 *
 * IMPORTANTE:
 * A implementação antiga do Psych Engine só deve ser compilada
 * quando LUA_ALLOWED estiver habilitado.
 *
 * Para Android deste projeto, LUA_ALLOWED fica desabilitado.
 */

class FunkinLua
{
	public static var Function_Stop:Dynamic = "##PSYCHLUA_FUNCTIONSTOP";
	public static var Function_Continue:Dynamic = "##PSYCHLUA_FUNCTIONCONTINUE";
	public static var Function_StopLua:Dynamic = "##PSYCHLUA_FUNCTIONSTOPLUA";

	public var scriptName:String = "";
	public var closed:Bool = false;

	public function new(script:String)
	{
		scriptName = script;
	}

	public function call(func:String, ?args:Array<Dynamic>):Dynamic
	{
		return null;
	}

	public function set(variable:String, value:Dynamic):Void
	{
	}

	public function get(variable:String):Dynamic
	{
		return null;
	}

	public function stop():Void
	{
		closed = true;
	}

	public function destroy():Void
	{
		closed = true;
	}

	public static function callOnLuas(
		funcName:String,
		?args:Array<Dynamic>,
		ignoreStops:Bool = false,
		?exclusions:Array<String>
	):Dynamic
	{
		return null;
	}

	public function luaTrace(
		text:String,
		ignoreCheck:Bool = false,
		?deprecated:Bool = false,
		?color:FlxColor
	):Void
	{
		trace(text);
	}
}

#else

/*
 * Android / Lua desativado
 *
 * O PlayState possui:
 *
 *     public var luaArray:Array<FunkinLua> = [];
 *
 * Portanto o tipo FunkinLua precisa continuar existindo mesmo
 * quando LUA_ALLOWED não está definido.
 *
 * Esta classe vazia evita que o compilador tente compilar a
 * implementação antiga do Psych Engine.
 */

class FunkinLua
{
	public static var Function_Stop:Dynamic = "##PSYCHLUA_FUNCTIONSTOP";
	public static var Function_Continue:Dynamic = "##PSYCHLUA_FUNCTIONCONTINUE";
	public static var Function_StopLua:Dynamic = "##PSYCHLUA_FUNCTIONSTOPLUA";

	public var scriptName:String = "";
	public var closed:Bool = true;

	public function new(?script:String = "")
	{
		scriptName = script;
	}

	public function call(?func:String = "", ?args:Array<Dynamic> = null):Dynamic
	{
		return null;
	}

	public function set(?variable:String = "", ?value:Dynamic = null):Void
	{
	}

	public function get(?variable:String = ""):Dynamic
	{
		return null;
	}

	public function stop():Void
	{
		closed = true;
	}

	public function destroy():Void
	{
		closed = true;
	}

	public function luaTrace(
		?text:String = "",
		ignoreCheck:Bool = false,
		?deprecated:Bool = false,
		?color:FlxColor = null
	):Void
	{
	}
}

#end
