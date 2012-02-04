package {
	
	import org.flixel.*;
	
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
		
		public var startingIndex:uint;
		public var drawIndex:uint;
		public var solidIndex:uint;
		
		
		public function TileMap(X:Number = 0, Y:Number = 0):void {
			super();
			x = X;
			y = Y;
			
		}
		
		public function loadMap(MapData:String, TileGraphic:Class, TileWidth:uint = 0, TileHeight:uint = 0, StartingIndex:uint = 0, DrawIndex:uint = 1, SolidIndex:uint = 1):TileMap {
			// First set input variables.
			startingIndex = StartingIndex;
			drawIndex = DrawIndex;
			solidIndex = SolidIndex;
			graphic = TileGraphic;
			
			// Declare the iterators.
			var i:int = 0;
			var j:int = 0;
			
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
		
	}
	
}