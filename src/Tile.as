package {
	
	import org.flixel.*;
	import org.flixel.system.FlxTile;
	
	/**
	 * 
	 * @author Martin Carney
	 */
	public class Tile extends FlxSprite {
		
		/**
		 * Which TileMap this Tile is part of
		 */
		public var parent:TileMap;
		
		/**
		 * X position in the parent's 2D array of Tiles.
		 */
		public var mapX:uint;
		
		/**
		 * Y position in the parent's 2D array of Tiles.
		 */
		public var mapY:uint;
		
		/**
		 * Which tile graphic to use, what the tile's type is.
		 */
		public var value:uint;
		
		/**
		 * Whether the Player has seen this tile before or not. Explored tiles are displayed darkly when not currently visible.
		 */
		public var explored:Boolean;
		
		/**
		 * Whether the Player has line-of-sight to this tile. If this is true, the tile is displayed normally.
		 */
		public var visibleToPlayer:Boolean;
		
		/**
		 * Whether the tile blocks line-of-sight. Walls, pillars, and various other things block vision for both the Player and Pirates.
		 */
		public var opaque:Boolean;
		
		/**
		 * Creates a Tile object.
		 */
		public function Tile(_parent:TileMap, _mapX:uint, _mapY:uint, _value:uint):void {
			parent = _parent;
			mapX = _mapX;
			mapY = _mapY;
			
			super(parent.x + (parent.tileWidth * mapX), parent.y + (parent.tileHeight * mapY));
			
			loadGraphic(parent.graphic, true, false, parent.tileWidth, parent.tileHeight);
			immovable = true;
			moves = false;
			
			setType(_value);
		}
		
		/**
		 * Change a Tile's type and updates variables as needed.
		 * @param	index
		 */
		public function setType(index:uint):void {
			value = index;
			if (parent.data[mapX][mapY] != value) {
				parent.data[mapX][mapY] = value;
			}
			
			solid = value >= parent.solidIndex;
			visible = value >= parent.drawIndex;
			opaque = value >= parent.transparentIndex;
			if (opaque) { color = 0xffff8888; }
			
			frame = value;
		}
		
		/**
		 * Determines if the Tile is crossed by a line defined by y = slope * x + yInt. Checks if it crosses the left and the right side of the rectangle.
		 * @param	slope Slope of the line to check
		 * @param	yInt Value of y when x = 0 for this line
		 * @return Return whether the line crosses the Tile's rectangle.
		 */
		public function crossesLine(slope:Number, yInt:Number):Boolean {
			if (x * slope + yInt >= y && x * slope + yInt <= y + height) { // Crosses left side
				return true;
			}
			if ((x + width) * slope + yInt >= y && (x + width) * slope + yInt <= y + height) { // Crosses right side
				return true;
			}
			
			return false; // Crosses neither left nor right side.
		}
		
	}
	
}