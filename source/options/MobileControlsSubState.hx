package options;

#if android
class MobileControlsSubState extends BaseOptionsMenu
{
 public function new()
 {
  title = 'Touch Controls';
  rpcTitle = 'Touch Controls';
  addOption(new Option('Control Mode',
   'Hitbox: four full-height touch lanes. Buttons: four arrow buttons.\nA confirms, B goes back, P pauses and C opens settings.',
   'touchControlMode', 'string', 'Hitbox', ['Hitbox', 'Buttons']));
  addOption(new Option('Hitbox Style',
   'Choose the feedback shown when touching a lane. Hidden keeps the lanes invisible.',
   'touchHitboxStyle', 'string', 'Gradient', ['Gradient', 'Outline', 'Hidden']));
  var option = new Option('Button Height',
   'Use LEFT/RIGHT to resize the four gameplay buttons.', 'touchButtonHeight', 'int', 150);
  option.minValue = 80;
  option.maxValue = 240;
  option.changeValue = 10;
  option.scrollSpeed = 100;
  addOption(option);
  addOption(new Option('Buttons at Top',
   'Press OK to move gameplay buttons between the top and bottom.', 'touchButtonsTop', 'bool', false));
  option = new Option('Button Opacity',
   'Use LEFT/RIGHT to change button visibility.', 'touchButtonOpacity', 'percent', 0.35);
  option.minValue = 0.1;
  option.maxValue = 1;
  option.changeValue = 0.05;
  addOption(option);
  super();
 }
}
#end
