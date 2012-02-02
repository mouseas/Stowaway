package {
	
	import org.flixel.*;
	
	/**
	 * Main class. Holds whatever is being displayed and updated.
	 * @author Martin Carney
	 */
	public class PlayState extends FlxState {
		
		/**
		 * Constructor function.
		 */
		public function PlayState():void {
			add(new FlxText(10, 10, 100, "Hello, Sol system."));
			add(new Player());
		}
		
	}
	
}