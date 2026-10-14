package;

#if android
import hxcodec.VideoHandler;
import hxcodec.vlc.LibVLC;
import openfl.events.Event;

/** Touch skipping and idempotent cleanup for Android cutscenes. */
@:access(hxcodec.vlc.VLCBitmap)
@:access(hxcodec.VideoHandler)
class AndroidVideoHandler extends VideoHandler
{
 public var finished(default, null):Bool = false;

 override private function update(?event:Event):Void
 {
  if (canSkip && MobileControls.check('accept') && isPlaying && isDisplaying)
   onVLCEndReached();
  else
   super.update(event);
 }

 override private function onVLCEndReached():Void
 {
  if (finished) return;
  finished = true;
  super.onVLCEndReached();
 }

 override public function dispose():Void
 {
  super.dispose();
  releaseNative(this);
 }

 // hxCodec 2.6.1 clears rendering resources but leaves native VLC handles alive.
 static function releaseNative(handler:VideoHandler):Void
 {
  if (handler.mediaPlayer != null)
  {
   LibVLC.media_player_release(handler.mediaPlayer);
   handler.mediaPlayer = null;
  }
  if (handler.audioOutput != null)
  {
   LibVLC.audio_output_list_release(handler.audioOutput);
   handler.audioOutput = null;
  }
  if (handler.instance != null)
  {
   LibVLC.release(handler.instance);
   handler.instance = null;
  }
 }

 public static function closeSprite(handler:VideoHandler):Void
 {
  handler.finishCallback = null;
  // Finished sprites are already detached and disposed by hxCodec.
  if (handler.stage != null) handler.onVLCEndReached();
  releaseNative(handler);
 }

 public function cancel():Void
 {
  finishCallback = null;
  onVLCEndReached();
 }
}
#end
