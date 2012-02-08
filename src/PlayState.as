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
		 * Stuff to init after the first update() cycle is triggered by this stuff.
		 */
		public var init:Boolean;
		
		public var debug1:FlxText;
		public var debug2:FlxText;
		
		/**
		 * Constructor function.
		 */
		public function PlayState():void {
			init = false;
			
			soundManager = new SoundManager(SoundManager.sndBackgroundNoise);
			add(soundManager);
			
			/*tilemap = new FlxTilemap();
			tilemap.loadMap(new testmapData(), tileGraphics, 16, 16);
			add(tilemap);*/
			
			tilemap = new TileMap(0, 0);
			tilemap.loadMap(new testmapData(), tileGraphics, 16, 16, 0, 1, 1);
			add(tilemap);
			tilemap.gameActive = true;
			//tilemap.x = 100;
			
			player = new Player(26, 26);
			add(player);
			
			debug1 = new FlxText(10, 10, 150, "debug1");
			debug1.scrollFactor.x = debug1.scrollFactor.y = 0;
			debug1.alpha = 0.3;
			add(debug1);
			debug2 = new FlxText(10, 23, 150, "debug2");
			debug2.scrollFactor.x = debug2.scrollFactor.y = 0;
			debug2.alpha = 0.3;
			add(debug2);
		}
		
		override public function update():void {
			super.update();
			debug1.text = "" + Math.round(FlxG.camera.scroll.x);
			debug2.text = "" + Math.round(FlxG.camera.scroll.y);
			if (!init) {
				FlxG.camera.follow(player);
				init = true;
				FlxG.worldBounds.x = -1000;
				FlxG.worldBounds.y = -1000;
				FlxG.worldBounds.width = 5000;
				FlxG.worldBounds.height = 5000;
			}
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