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
		public var transparent:Boolean;
		
		/**
		 * Creates a Tile object.
		 */
		public function Tile(_parent:TileMap, _mapX:uint, _mapY:uint, _value:uint):void {
			parent = _parent;
			mapX = _mapX;
			mapY = _mapY;
			value = _value;
			
			super(parent.x + (parent.tileWidth * mapX), parent.y + (parent.tileHeight * mapY));
			
			//Set up basic FlxSprite variables
			immovable = true;
			moves = false;
			solid = value >= parent.solidIndex;
			visible = value >= parent.drawIndex;
			
			loadGraphic(parent.graphic, true, false, parent.tileWidth, parent.tileHeight);
			frame = value;
			
		}
		
	}
	
}