package {
	
	import org.flixel.*;
	import org.flixel.system.FlxTile;
	
	/**
	 * 
	 * @author Martin Carney
	 */
	public class Tile extends FlxTile {
		
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
		 * @param	_Tilemap
		 * @param	_Index
		 * @param	_Width
		 * @param	_Height
		 * @param	_Visible
		 * @param	_AllowCollisions
		 */
		public function Tile(_Tilemap:FlxTilemap, _Index:uint, _Width:Number, _Height:Number, _Visible:Boolean, _AllowCollisions:uint):void {
			super(_Tilemap, _Index, _Width, _Height, _Visible, _AllowCollisions);
		}
		
	}
	
}