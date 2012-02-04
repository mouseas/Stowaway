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
		public function Player(_x:Number = 0, _y:Number = 0):void {
			super(_x, _y);
			loadGraphic(graphic, true);
			addAnimation("down", [0], 10);
			addAnimation("right", [1], 10);
			addAnimation("up", [2], 10);
			addAnimation("left", [3], 10);
			
			width = 8;
			height = 13;
			offset.x = 4;
			offset.y = 2;
			
			
			walkSpeed = 100;
		}
		
		override public function update():void {
			super.update();
			movementKeys();
		}
		
		private function movementKeys():void {
			if (FlxG.keys.UP) {
				if (FlxG.keys.LEFT) {
					velocity.x = -diag(walkSpeed);
					velocity.y = -diag(walkSpeed);
					play("left");
				} else if (FlxG.keys.RIGHT) {
					velocity.x = diag(walkSpeed);
					velocity.y = -diag(walkSpeed);
					play("right");
				} else {
					velocity.x = 0;
					velocity.y = -walkSpeed;
					play("up");
				}
			} else if (FlxG.keys.DOWN) {
				if (FlxG.keys.LEFT) {
					velocity.x = -diag(walkSpeed);
					velocity.y = diag(walkSpeed);
					play("left");
				} else if (FlxG.keys.RIGHT) {
					velocity.x = diag(walkSpeed);
					velocity.y = diag(walkSpeed);
					play("right");
				} else {
					velocity.x = 0;
					velocity.y = walkSpeed;
					play("down");
				}
			} else if (FlxG.keys.LEFT) {
				velocity.x = -walkSpeed;
				velocity.y = 0;
					play("left");
			} else if (FlxG.keys.RIGHT) {
				velocity.x = walkSpeed;
				velocity.y = 0;
					play("right");
			} else {
				velocity.x = velocity.y = 0;
			}
		}
		
		private function diag(speed:Number):Number {
			return Math.sqrt(2 * speed * speed) / 2;
		}
		
	}
	
}