package;

#if android
import haxe.CallStack;
import lime.app.Application;
import openfl.Lib;
import openfl.events.UncaughtErrorEvent;
#end

/**
 * Mostra o erro numa caixa de dialogo quando o jogo crasha no Android.
 * Funciona sem logcat: tire um print da caixa e envie.
 *
 * Uso: chame AndroidCrashAlert.init(); no construtor de Main, logo depois de super();
 *
 * Limite: so pega excecoes do Haxe. Se o jogo fechar SEM mostrar a caixa,
 * o crash e nativo (libs C++, falta de memoria) e precisa do logcat.
 */
class AndroidCrashAlert
{
	public static function init():Void
	{
		#if android
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);
		#end
	}

	#if android
	static function onCrash(e:UncaughtErrorEvent):Void
	{
		var stack:String = CallStack.toString(CallStack.exceptionStack(true));
		var msg:String = 'Erro: ' + Std.string(e.error) + '\n\n' + stack;
		trace(msg);
		Application.current.window.alert(msg, 'Crash');
	}
	#end
}
