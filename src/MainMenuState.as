package {
	
	import mx.core.FlexApplicationBootstrap;
	import org.flixel.*;
	
	/**
	 * Main Menu displayed at the game's opening.
	 * @author Martin Carney
	 */
	public class MainMenuState extends FlxState {
		
		[Embed(source = "../lib/placeholder-tiles.png")] public var titleImage:Class;
		
		public var titleSprite:FlxSprite;
		
		public var loadButton:FlxButton;
		
		public var newButton:FlxButton;
		
		public var creditsButton:FlxButton;
		
		public var saveGame:FlxSave;
		
		public function MainMenuState():void {
			super();
			
			//create and add title image and buttons
			titleSprite = new FlxSprite(0, 0, titleImage);
			loadButton = new FlxButton(FlxG.width / 4 - 40, 200, "Load Game", loadSavedGame);
			newButton = new FlxButton(FlxG.width / 2 - 40, 200, "New Game", startNewGame);
			creditsButton = new FlxButton(FlxG.width * 3 / 4 - 40, 200, "Credits", credits);
			
			//create a reference to the save data.
			saveGame = new FlxSave();
			saveGame.bind("StowawaySave");
			
		}
		
		public function loadSavedGame():void 
		{
			FlxG.switchState(new PlayState());
		}
		
		public function startNewGame():void 
		{
			FlxG.switchState(new PlayState(false));
		}
		
		public function credits():void 
		{
			
		}
		
		override public function create():void {
			add(titleSprite);
			add(loadButton);
			add(newButton);
			add(creditsButton);
			FlxG.mouse.show();
		}
		
	}
	
}