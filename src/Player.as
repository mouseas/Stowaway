package {
	
	import org.flixel.*;
	
	/**
	 * Player character class
	 * @author Martin Carney
	 */
	public class Player extends FlxSprite {
		
		/**
		 * Player's spritesheet.
		 */
		[Embed(source = "../lib/playerSprite.png")]public var graphic:Class;
		
		public var walkSpeed:Number;
		
		/**
		 * Constructor function.
		 */
		public function Player():void {
			super();
			loadGraphic(graphic, true);
			addAnimation("down", [0], 10);
			addAnimation("right", [1], 10);
			addAnimation("up", [2], 10);
			addAnimation("left", [3], 10);
			
			walkSpeed = 100;
		}
		
		override public function update():void {
			super.update();
			
			updateKeys();
		}
		
		private function updateKeys():void {
			if (FlxG.keys.UP) {
				if (FlxG.keys.LEFT) {
					velocity.x = -diag(walkSpeed);
					velocity.y = -diag(walkSpeed);
				} else if (FlxG.keys.RIGHT) {
					velocity.x = diag(walkSpeed);
					velocity.y = -diag(walkSpeed);
				} else {
					velocity.x = 0;
					velocity.y = -walkSpeed;
				}
			} else if (FlxG.keys.DOWN) {
				if (FlxG.keys.LEFT) {
					velocity.x = -diag(walkSpeed);
					velocity.y = diag(walkSpeed);
				} else if (FlxG.keys.RIGHT) {
					velocity.x = diag(walkSpeed);
					velocity.y = diag(walkSpeed);
				} else {
					velocity.x = 0;
					velocity.y = walkSpeed;
				}
			} else if (FlxG.keys.LEFT) {
				velocity.x = -walkSpeed;
				velocity.y = 0;
			} else if (FlxG.keys.RIGHT) {
				velocity.x = walkSpeed;
				velocity.y = 0;
			} else {
				velocity.x = velocity.y = 0;
			}
		}
		
		private function diag(speed:Number):Number {
			return Math.sqrt(2 * speed * speed) / 2;
		}
		
	}
	
}