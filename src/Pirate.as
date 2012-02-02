package {
	
	import org.flixel.*;
	
	/**
	 * Pirate (enemy) class. These guys mostly wander around the ship, and chase you down if they spot you.
	 * @author Martin Carney
	 */
	public class Pirate extends FlxSprite {
		
		/**
		 * Pirate's sprite sheet.
		 */
		[Embed(source = "../lib/playerSprite.png")]public var graphic:Class; // Holder until I get the Pirates' graphics made.
		
		/**
		 * Constructor Class.
		 * @param whichSkin Which graphic to use for this Pirate instance.
		 */
		public function Pirate(whichSkin:uint = 0):void {
			super();
			loadGraphic(graphic, true);
		}
		
	}
	
}