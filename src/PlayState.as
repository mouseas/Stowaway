package {
	
	import org.flixel.*;
	
	/**
	 * Main class. Holds whatever is being displayed and updated.
	 * @author Martin Carney
	 */
	public class PlayState extends FlxState {
		
		public function PlayState() {
			add(new FlxText(10, 10, 100, "Hello, Sol system."));
		}
		
		
		
	}
	
}