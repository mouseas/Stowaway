package {
	
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import org.flixel.*;
	import org.flixel.system.FlxTile;
	
	/**
	 * Main class. Holds whatever is being displayed and updated.
	 * @author Martin Carney
	 */
	public class PlayState extends FlxState {
		
		public var soundManager:SoundManager;
		
		[Embed(source = "../lib/tilemaps/testmap.csv", mimeType = "application/octet-stream")] public var testmapData:Class;
		[Embed(source = "../lib/placeholder-tiles.png")] public var tileGraphics:Class;
		
		public var tilemap:TileMap;
		
		public var player:Player;
		
		/**
		 * Constructor function.
		 */
		public function PlayState():void {
			player = new Player(26, 26);
			add(player);
			
			soundManager = new SoundManager(SoundManager.sndBackgroundNoise);
			add(soundManager);
			
			/*tilemap = new FlxTilemap();
			tilemap.loadMap(new testmapData(), tileGraphics, 16, 16);
			add(tilemap);*/
			
			tilemap = new TileMap();
			tilemap.loadMap(new testmapData(), tileGraphics, 16, 16);
			add(tilemap);
		}
		
		override public function update():void {
			super.update();
			FlxG.collide(player, tilemap);
			
			//Deal with visibility
			/*var tiles:Array = tilemap.tileObjects;
			for (var i:int = 0; i < tiles.length; i++) {
				var tile:FlxTile = tiles[i];
				if (tilemap.ray(player.getMidpoint(), tile.getMidpoint())) {
					tile.visible = false;
					trace(i);
				} else {
					tile.visible = true;
				}
			}*/
		}
		
	}
	
}