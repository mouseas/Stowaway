package 
{
	import org.flixel.*;
	
	/**
	 * Starter class for the game.
	 * @author Martin Carney
	 */
	public class Main extends FlxGame {
		
		/**
		 * Starts the program, opens an instance of PlayState.
		 */
		public function Main():void {
			super(320, 240, PlayState, 2);
		}
		
	}
	
}