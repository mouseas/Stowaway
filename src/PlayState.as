package {
	
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import org.flixel.*;
	
	/**
	 * Main class. Holds whatever is being displayed and updated.
	 * @author Martin Carney
	 */
	public class PlayState extends FlxState {
		
		public var soundManager:SoundManager;
		
		[Embed(source = "../lib/tilemaps/testmap.csv", mimeType = "application/octet-stream")] public var testmapData:Class;
		[Embed(source = "../lib/placeholder-tiles.png")] public var tileGraphics:Class;
		
		public var tilemap:FlxTilemap;
		
		public var player:Player;
		
		/**
		 * Constructor function.
		 */
		public function PlayState():void {
			player = new Player(16, 16);
			add(player);
			
			soundManager = new SoundManager(SoundManager.sndBackgroundNoise);
			add(soundManager);
			
			tilemap = new FlxTilemap();
			tilemap.loadMap(new testmapData(), tileGraphics, 16, 16);
			add(tilemap);
			
			add(new FlxText(10, 10, 100, "Hello, Sol system."));
		}
		
		override public function update():void {
			super.update();
			FlxG.collide(player, tilemap);
		}
		
	}
	
}