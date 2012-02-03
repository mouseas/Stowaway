package {
	
	import flash.media.*;
	import org.flixel.FlxObject;
	
	/**
	 * Manages looping ambient sounds for the game.
	 * @author Martin Carney
	 */
	public class SoundManager extends FlxObject {
		
		[Embed(source = "../lib/sound/background-noise.mp3")]public static var sndBackgroundNoise:Class;
		[Embed(source = "../lib/sound/cinematic-boom.mp3")]public static var sndCinematicBoom:Class;
		
		public var whichSound:Class;
		
		public var snd:Sound;
		public var sndChannel:SoundChannel;
		
		public function SoundManager(_whichSound:Class = null):void {
			super();
			if (whichSound != null) {
				whichSound = _whichSound;
			} else {
				whichSound = sndBackgroundNoise; // Backup sound, in case input is null.
			}
			snd = new whichSound();
			sndChannel = snd.play();
		}
		
		override public function update():void {
			super.update();
			
			
			//This bit keeps the background noise running.
			if (whichSound == null) {
				whichSound = sndBackgroundNoise;
			}
			if (snd == null) {
				snd = new whichSound();
			}
			if (sndChannel == null) {
				sndChannel = snd.play();
			}
			var position:Number = sndChannel.position;
			if (position * 1.1 > snd.length) {
				sndChannel = snd.play();
			}
		}
		
		
		
		
		
	}
	
}