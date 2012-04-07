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
		
		// ####################### Graphic and map data files #####################
		
		[Embed(source = "../lib/tilemaps/testmap.csv", mimeType = "application/octet-stream")] public var testmapData:Class;
		[Embed(source = "../lib/tilemaps/testmap2.csv", mimeType = "application/octet-stream")] public var testmapData2:Class;
		[Embed(source = "../lib/placeholder-tiles.png")] public var tileGraphics:Class;
		
		// ####################### Visual Layers ########################
		
		/**
		 * Top-most layer, used for indicators like the footsteps of hidden pirates.
		 */
		public var footstepLyr:FlxGroup;
		
		/**
		 * Layer used for the Player and not much else.
		 */
		public var playerLyr:FlxGroup;
		
		/**
		 * Layer used for the vents' Mirk tilemap(s).
		 */
		public var ventExploredLyr:FlxGroup;
		
		/**
		 * Layer used for various objects in the vents.
		 */
		public var ventSpriteLayer:FlxGroup;
		
		/**
		 * Layer used for the vent tilemap(s).
		 */
		public var ventTileLyr:FlxGroup;
		
		/**
		 * Layer used for the Decks' mirk tilemaps.
		 */
		public var deckExploredLyr:FlxGroup;
		
		/**
		 * Layer used for pirates and various objects on a given deck.
		 */
		public var deckSpriteLyr:FlxGroup;
		
		/**
		 * Layer used for the Decks' tilemaps.
		 */
		public var deckTileLyr:FlxGroup;
		
		/**
		 * Not really a visible layer. Add non-visible objects such as Decks here to have them update().
		 */
		public var backgroundProcessingLyr:FlxGroup;
		
		// ###################### Collision Groups ##################################
		
		/**
		 * The player object. Technically not a group, but used the same way.
		 */
		public var player:Player;
		
		
		// ############################### Misc Variables #################################
		
		/**
		 * Stuff to init after the first update() cycle is triggered by this stuff.
		 */
		public var init:Boolean;
		
		public var debug1:FlxText;
		public var debug2:FlxText;
		
		public var testDeck:Deck;
		public var testDeck1:Deck;
		
		public var soundManager:SoundManager;
		
		public var saveGame:FlxSave;
		
		// ############################## Functions ##################################
		
		/**
		 * Constructor function.
		 */
		public function PlayState(loadGame:Boolean = true):void {
			init = false;
			
			FlxG.mouse.hide();
			
			// First thing's first, load / create the save object.
			saveGame = new FlxSave();
			saveGame.bind("StowawaySave");
			
			soundManager = new SoundManager(SoundManager.sndBackgroundNoise);
			add(soundManager);
			
			// Initialize and add all the layers
			
			deckTileLyr = new FlxGroup();
			add(deckTileLyr);
			deckSpriteLyr = new FlxGroup();
			add(deckSpriteLyr);
			deckExploredLyr = new FlxGroup();
			add(deckExploredLyr);
			ventTileLyr = new FlxGroup();
			add(ventTileLyr);
			ventSpriteLayer = new FlxGroup();
			add(ventSpriteLayer);
			ventExploredLyr = new FlxGroup();
			add(ventExploredLyr);
			playerLyr = new FlxGroup();
			add(playerLyr);
			footstepLyr = new FlxGroup();
			add(footstepLyr);
			backgroundProcessingLyr = new FlxGroup();
			add(backgroundProcessingLyr);
			
			// Create all the decks. Add them to the game.
			
			
			testDeck = new Deck(0, this);
			testDeck.loadDeck(new testmapData(), tileGraphics, null, 0, 0, 1, 1);
			if (loadGame && saveGame.data.deck0 != null) {
				for (var i:int = 0; i < testDeck.widthInTiles; i++) {
					for (var j:int = 0; j < testDeck.heightInTiles; j++) {
						testDeck.tilesExplored[i][j] = saveGame.data.deck0.tilesExplored[i][j];
					}
				}
			}
			testDeck.addToState(this);
			
			var pirate:Pirate = new Pirate(0);
			pirate.x = 203;
			pirate.y = 116;
			deckSpriteLyr.add(pirate);
			
			testDeck1 = new Deck(1, this);
			testDeck1.loadDeck(new testmapData2(), tileGraphics, null, 0, 0, 1, 1);
			testDeck1.y = 224;
			if (loadGame && saveGame.data.deck0 != null) {
				testDeck1.tilesExplored = saveGame.data.deck1.tilesExplored;
				/*for (i = 0; i < testDeck1.widthInTiles; i++) {
					for (j = 0; j < testDeck1.heightInTiles; j++) {
						testDeck1.tilesExplored[i][j] = saveGame.data.deck1.tilesExplored[i][j];
					}
				}*/
			}
			testDeck1.addToState(this);
			
			if (loadGame && saveGame.data.player != null) {
				player = new Player(saveGame.data.player.x, saveGame.data.player.y);
			} else {
				player = new Player(26, 26);
			}
			playerLyr.add(player);
			
			debug1 = new FlxText(10, 10, 150, "");
			debug1.scrollFactor.x = debug1.scrollFactor.y = 0;
			debug1.alpha = 0.5;
			debug1.color = 0xffffaaaa;
			add(debug1);
			debug2 = new FlxText(10, 23, 150, "");
			debug2.scrollFactor.x = debug2.scrollFactor.y = 0;
			debug2.alpha = 0.5;
			debug2.color = 0xffffaaaa;
			add(debug2);
		}
		
		override public function update():void {
			super.update();
			FlxG.collide(player, deckTileLyr);
			
			debug1.text = "" + Math.round(player.x);
			debug2.text = "" + Math.round(player.y);
			
			if (!init) {
				// Initalization stuff that has to wait until an update cycle.
				init = true;
				FlxG.worldBounds.x = -1000;
				FlxG.worldBounds.y = -1000;
				FlxG.worldBounds.width = 5000;
				FlxG.worldBounds.height = 5000;
				FlxG.camera.follow(player);				
			}
			
			// debug keystrokes
			if (FlxG.keys.justPressed("O")) { //save game
				saveCurrentGame();
			}
			if (FlxG.keys.justPressed("P")) { // delete saved data
				deleteSavedGame();
			}
			
		}
		
		private function saveCurrentGame():void {
			saveGame.data.player = player;
			
			saveGame.data.deck0 = testDeck;
			saveGame.data.deck1 = testDeck1;
			
			player.flicker(0.25);
		}
		
		private function deleteSavedGame():void {
			saveGame.data.player = null;
			saveGame.data.deck0 = null;
			saveGame.data.deck1 = null;
			
			player.flicker(0.25);
		}
		
		
	}
	
}