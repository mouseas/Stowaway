package {
	
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import org.flixel.*;
	
	/**
	 * Main class. Holds whatever is being displayed and updated.
	 * @author Martin Carney
	 */
	public class PlayState extends FlxState {
		
		public var soundManager:SoundManager;
		
		/**
		 * Constructor function.
		 */
		public function PlayState():void {
			add(new FlxText(10, 10, 100, "Hello, Sol system."));
			add(new Player());
			
			soundManager = new SoundManager(SoundManager.sndBackgroundNoise);
			add(soundManager);
		}
		
	}
	
}