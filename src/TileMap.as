package {
	
	import org.flixel.*;
	import flash.geom.Point;
	
	/**
	 * Tilemap for segments and floors of the Pirates' ship.
	 * @author Martin Carney
	 */
	public class TileMap extends FlxGroup {
		
		/**
		 * 2D Array holding the tile values.
		 */
		public var data:Array;
		
		/**
		 * The tilemap graphic for each tile to use.
		 */
		public var graphic:Class;
		
		/**
		 * Height in pixels of each tile.
		 */
		public var tileHeight:uint;
		
		/**
		 * Width in pixels of each tile.
		 */
		public var tileWidth:uint;
		
		/**
		 * 2D Array holding the individual tiles with their x and y placements in the map.
		 */
		public var tileInstances:Array;
		
		protected var _x:Number;
		public function get x():Number { return _x; }
		public function set x(Xin:Number):void {
			_x = Xin;
			if (tileInstances != null) {
				for (var i:int = 0; i < tileInstances.length; i++) {
					for (var j:int = 0; j < tileInstances[i].length; j++) {
						var tile:Tile = tileInstances[i][j];
						tile.x = _x + (i * tileWidth);
					}
				}
			}
		}
		
		protected var _y:Number;
		public function get y():Number { return _y; }
		public function set y(Yin:Number):void {
			_y = Yin;
			if (tileInstances != null) {
				for (var i:int = 0; i < tileInstances.length; i++) {
					for (var j:int = 0; j < tileInstances[i].length; j++) {
						var tile:Tile = tileInstances[i][j];
						tile.y = _y + (j * tileHeight);
					}
				}
			}
		}
		
		/**
		 * Where the tiles start being opaque. Default is 1, and usually you'll want to leave it that way.
		 */
		public var transparentIndex:uint;
		
		/**
		 * Where tiles start being drawn. Default is 1, and usually you'll want to leave it that way.
		 */
		public var drawIndex:uint;
		
		/**
		 * Where tiles start being solid. Default is 1, but if you want floor tiles, you'll want to change this.
		 */
		public var solidIndex:uint;
		
		/**
		 * Whether this TileMap is active on the current PlayState. If true, update() will handle visibility for the Tiles.
		 */
		public var gameActive:Boolean;
		
		/**
		 * Constructor. Just initializes the class and sets its position. You'll need to use loadMap().
		 * @param	X x position to place the TileMap at.
		 * @param	Y y position to place the TileMap at.
		 */
		public function TileMap(X:Number = 0, Y:Number = 0):void {
			super();
			x = X;
			y = Y;
			gameActive = false;
		}
		
		/**
		 * Fills in the TileMap, generates all the tiles, 
		 * @param	MapData CSV string containing the map's data.
		 * @param	TileGraphic Tilemap sprite sheet graphic.
		 * @param	TileWidth How many pixels wide each tile is.
		 * @param	TileHeight How many pixels tall each tile is.
		 * @param	DrawIndex Index at which tiles are visible. 1 by default.
		 * @param	SolidIndex Index at which tiles are solid. 1 by default. Change to do floor tiles.
		 * @param   TransparentIndex Index at which tiles start blocking line-of-sight vision. 1 by default.
		 * @return  This
		 */
		public function loadMap(MapData:String, TileGraphic:Class, TileWidth:uint = 0, TileHeight:uint = 0, DrawIndex:uint = 1, SolidIndex:uint = 1, TransparentIndex:uint = 1):TileMap {
			// Declare the iterators.
			var i:int = 0;
			var j:int = 0;
			
			// Clear out any existing Tiles before starting.
			while (members.length > 0) {
				remove(members[0], true);
			}
			if (data != null) { data = null; }
			if (tileInstances != null) { tileInstances = null; }
			
			// First set input variables.
			transparentIndex = TransparentIndex;
			drawIndex = DrawIndex;
			solidIndex = SolidIndex;
			graphic = TileGraphic;
			
			// Prepare the data array.
			var predata:Array = MapData.split("\n");
			for (i = 0; i < predata.length; i++) {
				predata[i] = predata[i].split(",");
				for (j = 0; j < predata[i].length; j++) {
					predata[i][j] = (uint)(predata[i][j]);
				}
			}
			// This part flips the x and y of the data array: predata[y][x] becomes data[x][y].
			data = new Array();
			for (i = 0; i < predata[0].length; i++) {
				data.push(new Array());
				for (j = 0; j < predata.length; j++) {
					data[i].push(predata[j][i]);
				}
			}
			predata = null;
			
			// Set the tile width and height.
			if (TileWidth < 1) {
				trace("Can't handle automatic width yet.");
			} else { tileWidth = TileWidth; }
			if (TileHeight < 1) {
				trace("Can't handle automatic height yet.");
			} else { tileHeight = TileHeight; }
			
			// Create the tile objects, and add them to both the tileInstance array and the members array.
			tileInstances = new Array();
			for (i = 0; i < data.length; i++) {
				tileInstances.push(new Array());
				for (j = 0; j < data[i].length; j++) {
					var tile:Tile = new Tile(this, i, j, data[i][j])
					tileInstances[i].push(tile);
					add(tile);
				}
			}
			
			return this;
		}
		
		override public function update():void {
			super.update();
			
			if (gameActive && tileInstances != null) { // Handle tile visibility.
				updateVisibility();
			}
			
		}
		
		/**
		 * Part of the tilemap's update cycle. Marks blocks within the player's line of sight as visibleToPlayer.
		 */
		public function updateVisibility():void {
			var playerCenter:FlxPoint = (FlxG.state as PlayState).player.getMidpoint();
			
			// First set all tiles to !processed and !visible.
			for (var i:int = 0; i < tileInstances.length; i++) {
				for (var j:int = 0; j < tileInstances[i].length; j++) {
					(tileInstances[i][j] as Tile).processed = false;
					(tileInstances[i][j] as Tile).visibleToPlayer = false;
				}
			}
			
			// Then run rays from the player to each tile along the outside edge of the TileMap.
			for (i = 0; i < tileInstances[0].length; i++) { // left side
				visibilityRay(playerCenter, tileInstances[0][i].getMidpoint());
			}
			var index:uint = tileInstances.length - 1;
			for (i = 0; i < tileInstances[index].length; i++) { // right side
				visibilityRay(playerCenter, tileInstances[index][i].getMidpoint());
			}
			index = tileInstances[0].length - 1;
			for (i = 1; i < tileInstances.length - 1; i++) {
				visibilityRay(playerCenter, tileInstances[i][0].getMidpoint()); // top side
				visibilityRay(playerCenter, tileInstances[i][index].getMidpoint()); // bottom side
			}
		}
		
		/**
		 * Individual ray from the player to one of the edge blocks of a tilemap. Processes through tiles along the path and checks if
		 * they're opaque. Stops when it runs into an opaque block.
		 * @param	start
		 * @param	end
		 */
		private function visibilityRay(start:FlxPoint, end:FlxPoint):void {
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
		 * @return
		 */
		private function checkTile(X:Number, Y:Number, dX:Number, dY:Number):Boolean {
			var slotX:int = (int)((X - x) / tileWidth);
			var slotY:int = (int)((Y - y) / tileHeight);
			if (slotX >= 0 && slotX < tileInstances.length && slotY >= 0 && slotY < tileInstances[slotX].length) {
				var tile:Tile = tileInstances[slotX][slotY];
				if (!tile.opaque) {
					if (dX <= 0 && dY <= 0) checkAdjacent(slotX - 1, slotY - 1);
					if (dY <= 0) checkAdjacent(slotX, slotY - 1);
					if (dX > 0 && dY <= 0) checkAdjacent(slotX + 1, slotY - 1);
					if (dX <= 0) checkAdjacent(slotX - 1, slotY);
					if (dX > 0) checkAdjacent(slotX + 1, slotY);
					if (dX <= 0 && dY > 0) checkAdjacent(slotX - 1, slotY + 1);
					if (dY > 0) checkAdjacent(slotX, slotY + 1);
					if (dX > 0 && dY > 0) checkAdjacent(slotX + 1, slotY + 1);
				}
				if (tile.processed) { // already been processed, next spot.
					if (tile.opaque) {
						return false;
					} else {
						return true;
					}
				} else { // Not processed yet.
					tile.processed = true;
					if (tile.opaque) {
						return false;
					} else {
						tile.visibleToPlayer = true;
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
			if (slotX >= 0 && slotX < tileInstances.length && slotY >= 0 && slotY < tileInstances[slotX].length) {
				var tile:Tile = tileInstances[slotX][slotY];
				if (tile.opaque && !tile.visibleToPlayer) {
					tile.visibleToPlayer = true;
				}
			}
		}
		
		/**
		 * Checks all the tiles that the line segment between Start and End cross. If all of them are 
		 * @param	Start Starting point.
		 * @param	End Ending point.
		 * @param   checkFor Which boolean variable to check. Use "opaque" or "solid".
		 * @return Returns two arrays. result[0] are those that were true, and result[1] are those that were false;
		 * result[2] is the first match of true, and result[3] is the first match of false.
		 */
		/*public function ray(Start:FlxPoint, End:FlxPoint, checkFor:String = "opaque"):Array {
			if (Start.x == End.x) {
				trace("Slope invalid; line is vertical!")
			} else {
				var result:Boolean;
				var slope:Number = (End.y - Start.y) / (End.x - Start.x);
				var yInt:Number = Start.y - (slope * Start.x); 
				
				var left:Number = Math.min(Start.x, End.x);
				var right:Number = Math.max(Start.x, End.x);
				var top:Number = Math.min(Start.y, End.y);
				var bottom:Number = Math.max(Start.y, End.y);
				
				var leftIndex:int = (int) ((left - x) / tileWidth);
				var rightIndex:int = (int) ((right - x) / tileWidth + 1);
				var topIndex:int = (int) ((top - y) / tileHeight);
				var bottomIndex:int = (int) ((bottom - y) / tileHeight + 1);
				
				var matched:Boolean = true;
				
				for (var i:int = leftIndex; i < rightIndex; i++) {
					for (var j:int = topIndex; j < bottomIndex; j++) {
						if (i >= 0 && i < tileInstances.length && j >= 0 && j < tileInstances[i], length) {
							var tile:Tile = tileInstances[i][j] as Tile;
							if (tile.crossesLine(slope, yInt)) {
								if (!tile[checkFor]) {
									if (callback != null) {
										callback(tile);
									}
									matched = false;
								}
							}
						}
					}
				}
				return matched;
			}
			return true;
		}*/
		
		public static function blackenTile(tile:Tile):void {
			tile.visible = false;
			/*if (tile.explored) {
				tile.color = 0xff333333;
			} else {
				tile.color = 0xff000000;
			}*/
		}
		
		
		
	}
	
}