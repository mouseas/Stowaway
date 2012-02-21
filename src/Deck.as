package {
	
	import org.flixel.*;
	
	public class Deck extends FlxObject {
		
		[Embed(source = "../lib/mirk.png")]public var mirkGraphic:Class;
		
		/**
		 * How many pixels wide each tile is.
		 */
		public var tileWidth:uint;
		
		/**
		 * How many pixels tall each tile is.
		 */
		public var tileHeight:uint;
		
		/**
		 * 2D Array of each tiles' opacity; whether each tile can be seen through. Used for line-of-sight calculations.
		 * 0 is opaque, 1 is transparent.
		 */
		public var tilesOpacity:Array;
		
		/**
		 * 2D array of which tiles have been explored (1) and which have not (0).
		 */
		public var tilesExplored:Array;
		
		/**
		 * 2D Array of which tiles are currently visible.
		 */
		public var tilesCurrVisible:Array;
		
		/**
		 * Optional 2D array of the Deck's lighting. Create and use this only if the Deck has dark areas. Values range from 0 (black) to 9 (fully lit).
		 */
        public var tilesLighting:Array
		
		/**
		 * The actual tiles of the Deck.
		 */
		public var tilesMap:FlxTilemap;
		
		/**
		 * Tilemap with transparent black tiles, overlaying tilesMap. Tile values are updated based on line of sight and lighting.
		 * Tiles range from 0 (black) to 9 (clear).
		 */
		public var tilesMirk:FlxTilemap;
		
		/**
		 * The x position of the Deck.
		 */
		public function get x():Number { return _x; }
		public function set x(newX:Number):void {
			_x = newX;
			if (tilesMap != null) { tilesMap.x = newX; }
			if (tilesMirk != null) { tilesMirk.x = newX; }
		}
		
		/**
		 * The y position of the Deck.
		 */
		public function get y():Number { return _y; }
		public function set y(newY:Number):void {
			_y = newY;
			if (tilesMap != null) { tilesMap.y = newY; }
			if (tilesMirk != null) { tilesMirk.y = newY; }
		}
		
		private var _x:Number;
		
		private var _y:Number;
		
		/**
		 * How many tiles wide the Deck is. This should match the width of all the 2D arrays and FlxTilemaps.
		 */
		public var widthInTiles:uint;
		
		/**
		 * How many tiles tall the Deck is. This should match the height of all the 2D arrays and FlxTilemaps.
		 */
		public var heightInTiles:uint;
		
		/**
		 * Reference to the parent PlayState object.
		 */
		public var parent:PlayState;
		
		/**
		 * Constructor for a Deck object. Doesn't do much - You need to use loadDeck.
		 * Add the Deck object for line of sight updating, and use addDeck(state:PlayState) to add the deck's parts to gameplay.
		 */
		public function Deck():void {
			super();
			
		}
		
		/**
		 * Loads and prepares a Deck.
		 * @param	tileData The CSV text string with the TileMap's layout.
		 * @param	tileGrahics The graphic file used for the tiles
		 * @param   exploredData If loading a previously explored Deck (eg from a saved game), this is what has already been explored.
		 * @param	lightingData If the area has dimly lit areas, this is the CSV text string with the lighting layout.
		 */
		public function loadDeck(tileData:String, tileGrahics:Class, exploredData:String = null, lightingData:String = null, StartingIndex:uint=0, DrawIndex:uint=1, CollideIndex:uint=1):void {
			if (tileData == null || tileGrahics == null) {
				trace ("Inputs for loadDeck contained null data.")
				return;
			}
			tilesMap = new FlxTilemap();
			tilesMap.loadMap(tileData, tileGrahics, 0, 0, 0, StartingIndex, DrawIndex, CollideIndex);
			
		}
		
		override public function update():void {
			super.update();
			if (tilesLighting != null) {
				// Do lighting calculation here.
			}
		}
		
		/**
		 * Calculates the X tile position from a given point. This is not verified to be within the
		 * Deck's limits, so checking that the result is between 0 and widthInTiles is vital.
		 * @param	point The point to get the Deck's X tile position from.
		 * @return uint with the X tile position matching the input point.
		 */
		public function getTileX(point:FlxPoint):int {
			var localX:Number = point.x - _x;
			return (int)(localX / tileWidth);
		}
		
		/**
		 * Calculates the Y tile position from a given point. This is not verified to be within the
		 * Deck's limits, so checking that the result is between 0 and heightInTiles is vital.
		 * @param	point The point to get the Deck's Y tile position from.
		 * @return uint with the Y tile position matching the input point.
		 */
		public function getTileY(point:FlxPoint):int {
			var localY:Number = point.y - _y;
			return (int)(localY / tileHeight);
		}
		
	}
	
}