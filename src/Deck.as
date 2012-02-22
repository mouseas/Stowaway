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
		 * True for opaque (blocks line of sight), false for transparent.
		 */
		public var tilesOpacity:Array;
		
		/**
		 * What tile index to start having tiles block line of sight.
		 */
		public var opacityIndex:uint;
		
		/**
		 * 2D array of which tiles have been explored (true) and which have not (false).
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
		 * @param deckNumber Which deck this is. This is the Deck's ID, and is used to save and load deck data.
		 */
		public function Deck(deckNumber:uint):void {
			super();
			ID = deckNumber;
			_x = 0;
			_y = 0;
		}
		
		/**
		 * Loads and prepares a Deck.
		 * @param	tileData The CSV text string with the TileMap's layout.
		 * @param	tileGrahics The graphic file used for the tiles
		 * @param   exploredData If loading a previously explored Deck (eg from a saved game), this is what has already been explored.
		 * @param	lightingData If the area has dimly lit areas, this is the CSV text string with the lighting layout.
		 */
		public function loadDeck(tileData:String, tileGrahics:Class, exploredData:String = null, lightingData:String = null, StartingIndex:uint=0, DrawIndex:uint=1, CollideIndex:uint=1, OpaqueIndex:uint=1):void {
			if (tileData == null || tileGrahics == null) {
				trace ("Inputs for loadDeck contained null data.")
				return;
			}
			tilesMap = new FlxTilemap();
			tilesMap.loadMap(tileData, tileGrahics, 0, 0, 0, StartingIndex, DrawIndex, CollideIndex);
			
			widthInTiles = tilesMap.widthInTiles;
			heightInTiles = tilesMap.heightInTiles;
			tileWidth = (int)(tilesMap.width / tilesMap.widthInTiles);
			tileHeight = (int)(tilesMap.height / tilesMap.heightInTiles);
			opacityIndex = OpaqueIndex;
			
			// Creates a grid of 0's sized to match the tilesMap to generate tilesMirk.
			var mirkString:String = "";
			for (var i:int = 0; i < widthInTiles; i++) {
				for (var j:int = 0; j < heightInTiles; j++) {
					mirkString += "0";
					if (j - 1 < heightInTiles) {
						mirkString += ",";
					} else {
						mirkString += "\n";
					}
				}
			}
			
			tilesMirk = new FlxTilemap();
			tilesMirk.loadMap(mirkString, mirkGraphic, tileWidth, tileHeight);
			
			// Figure out each tile's opacity (if it blocks line of sight or not).
			tilesOpacity = createGrid(widthInTiles, heightInTiles);
			for (i = 0; i < widthInTiles; i++) {
				for (j = 0; j < heightInTiles; j++) {
					if (tilesMap.getTile(i, j) >= opacityIndex) {
						tilesOpacity[i][j] = true;
					} else {
						tilesOpacity[i][j] = false;
					}
				}
			}
			
			
			tilesExplored = createGrid(widthInTiles, heightInTiles);
			tilesCurrVisible = createGrid(widthInTiles, heightInTiles);
			if (parent.saveGame.data.deck[ID] != null) {
				// Load save game explored data, and set all CurrVisible to false (changes at update).
			} else {
				// New game, nothing explored yet.
				for (i = 0; i < widthInTiles; i++) {
					for (j = 0; j < heightInTiles; j++) {
						tilesExplored[i][j] = false;
						tilesCurrVisible[i][j] = false;
					}
				}
			}
			
			
			// Load the lighting if there is any data to load. Can cause errors if the lighting data is too small.
			if (lightingData != null) {
				tilesLighting = createGrid(widthInTiles, heightInTiles);
				var lightArray:Array = lightingData.split("\n");
				for (i = 0; i < lightArray.length; i++) {
					lightArray[i] = (String)(lightArray[i]).split(",");
				}
				for (i = 0; i < tilesLighting.length; i++) {
					for (j = 0; j < tilesLighting[i].length && j < lightArray.length && i < lightArray[j].length; j++) {
						tilesLighting[i][j] = lightArray[j][i]; // Note that lightArray is flipped for tilesLighting.
					}
				}
			}
		}
		
		/**
		 * Creates a 2D array with empty cells in a grid. result[x][y] for each cell.
		 * @param	width How many columns in the grid.
		 * @param	height How many cells in each column, ie how many rows in the grid.
		 * @return Array object full of Array objects with empty cells.
		 */
		public static function createGrid(width:uint, height:uint):Array {
			var result:Array = new Array;
			for (var i:int = 0; i < width; i++) {
				var column:Array = new Array();
				result.push(column);
				column.length = height;
			}
			return result;
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