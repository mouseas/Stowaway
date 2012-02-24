package {
	
	import org.flixel.*;
	import flash.geom.Point;
	
	public class Deck extends FlxBasic {
		
		[Embed(source = "../lib/mirk.png")]public var mirkGraphic:Class;
		
		/**
		 * Whichever deck is the current one.
		 */
		public static var currentDeck:Deck;
		
		/**
		 * How many pixels wide each tile is.
		 */
		public var tileWidth:uint;
		
		/**
		 * How many pixels tall each tile is.
		 */
		public var tileHeight:uint;
		
		/**
		 * Width in pixels of the Deck.
		 */
		public var width:Number;
		
		/**
		 * Height in pixels of the Deck.
		 */
		public var height:Number;
		
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
		 * 2D Array of which tiles have had their visibility processed each update cycle.
		 */
		public var tilesProcessed:Array;
		
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
		 * Whether the Deck has been loaded/initialized.
		 */
		public var initialized:Boolean;
		
		/**
		 * The sprites that belong on this deck, including Pirates, projectiles, and various objects to interact with.
		 */
		public var sprites:FlxGroup;
		
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
		public function Deck(deckNumber:uint, _parent:PlayState):void {
			super();
			ID = deckNumber;
			_x = 0;
			_y = 0;
			initialized = false;
			parent = _parent;
			sprites = new FlxGroup();
		}
		
		/**
		 * Loads and prepares a Deck.
		 * @param	tileData The CSV text string with the TileMap's layout.
		 * @param	tileGrahics The graphic file used for the tiles
		 * @param	lightingData If the area has dimly lit areas, this is the CSV text string with the lighting layout.
		 * @param   StartingIndex Index of the first frame to use. Default is 0.
		 * @param   DrawIndex Index Index of the first frame to use graphics. Default is 0.
		 * @param   CollideIndex Index of tiles to start colliding with. Default is 1. This will usually be changed.
		 * @param   OpaqueIndex Index of tiles to start blocking line of sight. Default is 1. Usually this will match CollideIndex.
		 */
		public function loadDeck(tileData:String, tileGrahics:Class, lightingData:String = null, StartingIndex:uint=0, DrawIndex:uint=0, CollideIndex:uint=1, OpaqueIndex:uint=1):void {
			if (tileData == null || tileGrahics == null) {
				trace ("Inputs for loadDeck contained null data.")
				return;
			}
			tilesMap = new FlxTilemap();
			tilesMap.loadMap(tileData, tileGrahics, 0, 0, 0, StartingIndex, DrawIndex, CollideIndex);
			
			widthInTiles = tilesMap.widthInTiles;
			heightInTiles = tilesMap.heightInTiles;
			width = tilesMap.width;
			height = tilesMap.height;
			tileWidth = (int)(tilesMap.width / tilesMap.widthInTiles);
			tileHeight = (int)(tilesMap.height / tilesMap.heightInTiles);
			opacityIndex = OpaqueIndex;
			
			// Creates a grid of 0's sized to match the tilesMap to generate tilesMirk.
			var mirkString:String = "";
			for (var i:int = 0; i < heightInTiles; i++) {
				for (var j:int = 0; j < widthInTiles; j++) {
					mirkString += "0";
					if (j + 1 < widthInTiles) {
						mirkString += ",";
					} else {
						if (i + 1 < heightInTiles) {
							mirkString += "\n";
						}
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
			
			// Prepare the tilesExplored and tilesCurrVisible arrays, initializing each cell. Load explored data, if any.
			tilesExplored = createGrid(widthInTiles, heightInTiles);
			tilesCurrVisible = createGrid(widthInTiles, heightInTiles);
			tilesProcessed = createGrid(widthInTiles, heightInTiles);
			if (parent.saveGame.data.deck != null && parent.saveGame.data.deck[ID] != null) {
				// Load save game explored data, and set all CurrVisible to false (changes at update).
				trace("No loading functionality yet for explored areas.")
			} else {
				// New game, nothing explored yet.
				for (i = 0; i < widthInTiles; i++) {
					for (j = 0; j < heightInTiles; j++) {
						tilesExplored[i][j] = false;
						// Also initialize the tilesCurrVisible array and tilesProcessed arry and save yourself some loops.
						tilesCurrVisible[i][j] = false;
						tilesProcessed[i][j] = false;
					}
				}
			}
			
			
			// Load the lighting if there is any data to load. Can cause errors if the lighting data is too small.
			if (lightingData != null) {
				tilesLighting = createGrid(widthInTiles, heightInTiles);
				var lightArray:Array = lightingData.split("/n");
				for (i = 0; i < lightArray.length; i++) {
					lightArray[i] = (String)(lightArray[i]).split(",");
				}
				for (i = 0; i < tilesLighting.length; i++) {
					for (j = 0; j < tilesLighting[i].length && j < lightArray.length && i < lightArray[j].length; j++) {
						tilesLighting[i][j] = lightArray[j][i]; // Note that lightArray is flipped for tilesLighting.
					}
				}
			}
			
			// When done...
			initialized = true;
		}
		
		/**
		 * Adds the deck, if prepared, to the PlayState, with each part going to the correct layer.
		 * @param state Which PlayState to add this deck to. You know. The only one.
		 */
		public function addToState(state:PlayState):void {
			if (initialized && state != null) {
				state.backgroundProcessingLyr.add(this);
				state.deckExploredLyr.add(tilesMirk);
				state.deckTileLyr.add(tilesMap);
				state.deckSpriteLyr.add(sprites);
			}
		}
		
		/**
		 * Removes a deck, if initialized, from the PlayState, removing each part from the correct layer.
		 * @param	state Which PlayState to remove this deck from.
		 */
		public function removeFromState(state:PlayState):void {
			if (initialized && state != null) {
				state.backgroundProcessingLyr.remove(this, true);
				state.deckExploredLyr.remove(tilesMirk, true);
				state.deckTileLyr.remove(tilesMap, true);
				state.deckSpriteLyr.remove(sprites, true);
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
		
		/**
		 * Update cycle.
		 */
		override public function update():void {
			super.update();
			if (tilesLighting != null) {
				// Do lighting calculation here.
			}
			if (currentDeck != this) {
				if (parent.player.x >= x && parent.player.x <= x + width && parent.player.y >= y && parent.player.y <= y + height) {
					currentDeck = this;
				}
			}
			updateLineOfSight();
			updateMirk();
		}
		
		/**
		 * Line of sight calculation. This must be done before updating tilesMirk.
		 */
		public function updateLineOfSight():void {
			var playerCenter:FlxPoint = parent.player.getMidpoint();
			
			// Clear visibility and processed.
			for (var i:int = 0; i < widthInTiles; i++) {
				for (var j:int = 0; j < heightInTiles; j++) {
					tilesCurrVisible[i][j] = false;
					tilesProcessed[i][j] = false;
				}
			}
			if (!tilesMap.onScreen()) {
				return; // No need to calculate for off-screen Decks
			}
			
			// Then run rays from the player to each tile along the outside edge of the TileMap.
			// Need to change this to a series of points outside the edge of the screen.
			var point:FlxPoint = new FlxPoint();
			for (i = 0; i < FlxG.width / (tileWidth * 0.8); i++) {
				point.x = FlxG.camera.scroll.x + (i * tileWidth * 0.8);
				// top side
				if (parent.player.y >= y) { // These if statements reduce useless lineOfSight rays.
					point.y = FlxG.camera.scroll.y;
					lineOfSightRay(playerCenter, point);
				}
				// bottom side
				if (parent.player.y <= y + height) {
					point.y = FlxG.camera.scroll.y + FlxG.height;
					lineOfSightRay(playerCenter, point);
				}
			}
			for (i = 0; i < FlxG.height / (tileHeight * 0.8); i++) {
				point.y = FlxG.camera.scroll.y + (i * tileHeight * 0.8);
				// left side
				if (parent.player.x >= x) {
					point.x = FlxG.camera.scroll.x;
					lineOfSightRay(playerCenter, point);
				}
				// right side
				if (parent.player.x <= x + width) {
					point.x = FlxG.camera.scroll.x + FlxG.width;
					lineOfSightRay(playerCenter, point);
				}
			}
		}
		
		/**
		 * Individual ray from the player to one of the edge blocks of a tilemap. Processes through tiles along the path and checks if
		 * they're opaque. Stops when it runs into an opaque block.
		 * @param	start
		 * @param	end
		 */
		private function lineOfSightRay(start:FlxPoint, end:FlxPoint):void {
			if (currentDeck != null && currentDeck != this) {
				if (!currentDeck.tilesMap.ray(start, end)) {
					return;
					// Kill line of sight rays from the current deck into this one if there's an obstacle.
					// This is a lazy measure - it calculates based on whether a block is solid rather than
					// if it is opaque, so transparent walls and opaque floor blocks will not work right.
				}
			}
			var dX:Number = end.x - start.x;
			var dY:Number = end.y - start.y;
			var c:Number = Math.sqrt(dX * dX + dY * dY); // length of line segment
			var stepLength:Number = (tileWidth + tileHeight) / 3;
			var numSteps:uint = (uint)(c / stepLength) + 1;
			var startP:Point = new Point(start.x, start.y);
			var endP:Point = new Point(end.x, end.y);
			var goOn:Boolean = true;
			var i:int = 0;
			while (goOn && i < numSteps) {
				var point:Point = Point.interpolate(endP, startP, (i * stepLength) / c);
				goOn = checkTile(point.x, point.y, dX, dY);
				i++;
			}
			
			
		}
		
		/**
		 * Check an individual tile - if it exists, then if it's been processed, then if it's opaque. If it's !opague,
		 * check all the adjacent tiles for opaque.
		 * @param	X
		 * @param	Y
		 * @param   dX
		 * @param   dY
		 * @return
		 */
		private function checkTile(X:Number, Y:Number, dX:Number, dY:Number):Boolean {
			var slotX:int = (int)((X - x) / tileWidth);
			var slotY:int = (int)((Y - y) / tileHeight);
			if (slotX >= 0 && slotX < widthInTiles && slotY >= 0 && slotY < heightInTiles) { // Tile must exist
				var opaque:Boolean = tilesOpacity[slotX][slotY];
				var processed:Boolean = tilesProcessed[slotX][slotY];
				if (!opaque) { // Make adjacent opaque tiles visible, depending on the ray's angle.
					if (dX <= 0 && dY <= 0) checkAdjacent(slotX - 1, slotY - 1);
					if (dY <= 0) checkAdjacent(slotX, slotY - 1);
					if (dX > 0 && dY <= 0) checkAdjacent(slotX + 1, slotY - 1);
					if (dX <= 0) checkAdjacent(slotX - 1, slotY);
					if (dX > 0) checkAdjacent(slotX + 1, slotY);
					if (dX <= 0 && dY > 0) checkAdjacent(slotX - 1, slotY + 1);
					if (dY > 0) checkAdjacent(slotX, slotY + 1);
					if (dX > 0 && dY > 0) checkAdjacent(slotX + 1, slotY + 1);
				}
				if (processed) { // already been processed, next spot.
					if (opaque) {
						return false;
					} else {
						return true;
					}
				} else { // Not processed yet.
					tilesProcessed[slotX][slotY] = true;
					if (opaque) {
						return false;
					} else {
						tilesCurrVisible[slotX][slotY] = true;
						if (!tilesExplored[slotX][slotY]) { tilesExplored[slotX][slotY] = true; }
						return true;
					}
				}
			}
			return true;
		}
		
		/**
		 * Check a tile adjacent to a !opaque tile to see if it's opaque. If opaque, set visibleToPlayer.
		 * @param	slotX
		 * @param	slotY
		 */
		private function checkAdjacent(slotX:int, slotY:int):void {
			if (slotX >= 0 && slotX < widthInTiles && slotY >= 0 && slotY < heightInTiles) { // Tile must exist
				if (tilesOpacity[slotX][slotY] && !tilesCurrVisible[slotX][slotY]) {
					tilesCurrVisible[slotX][slotY] = true;
					if (!tilesExplored[slotX][slotY]) { tilesExplored[slotX][slotY] = true; }
				}
			}
		}
		
		private function updateMirk():void {
			for (var i:int = 0; i < widthInTiles; i++) {
				for (var j:int = 0; j < heightInTiles; j++) {
					var k:uint = tilesMirk.getTile(i, j)
					if (tilesCurrVisible[i][j]) {
						if (k > 0) {
							tilesMirk.setTile(i, j, k - 1);
						}
					} else {
						if (tilesExplored[i][j]) {
							if (k < 5) {
								tilesMirk.setTile(i, j, k + 1);
							} else if (k > 5) {
								tilesMirk.setTile(i, j, k - 1);
							}
						} else {
							if (k < 10) {
								tilesMirk.setTile(i, j, k + 1);
							}
						}
					}
				}
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