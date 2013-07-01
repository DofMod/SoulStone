package
{
	import d2api.DataApi;
	import d2api.SystemApi;
	import d2api.UiApi;
	import d2data.Monster;
	import d2enums.FightTypeEnum;
	import d2hooks.GameFightEnd;
	import d2hooks.GameFightJoin;
	import d2hooks.GameFightStart;
	import flash.display.Sprite;
	import flash.utils.Dictionary;
	import hooks.ModuleSoulstoneOpen;
	import ui.SoulStoneUi;
	
	/**
	 * Main module class (entry point).
	 * 
	 * @author ExiTeD, Relena
	 */
	public class SoulStone extends Sprite
	{
		//::///////////////////////////////////////////////////////////
		//::// Variables
		//::///////////////////////////////////////////////////////////
		
		// UI include
		private const includes:Array = [SoulStoneUi];
		
		// Some constants
		private static const UI_NAME:String = "soulstone";
		private static const UI_INSTANCE_NAME:String = "soulstone";
		
		// APIs
		public var uiApi:UiApi;
		public var sysApi:SystemApi;
		public var dataApi:DataApi;
		
		//::///////////////////////////////////////////////////////////
		//::// Public methods
		//::///////////////////////////////////////////////////////////
		
		public function main():void
		{
			sysApi.createHook("ModuleSoulstoneOpen");
			
			sysApi.addHook(GameFightJoin, onGameFightJoin);
			sysApi.addHook(ModuleSoulstoneOpen, onModuleSoulstoneOpen);
		}
		
		//::///////////////////////////////////////////////////////////
		//::// Events
		//::///////////////////////////////////////////////////////////
		
		/**
		 * Hook reporting a request to open the module's UI.
		 * 
		 * @param	minimized	Load the UI in minimized mode ?
		 */
		private function onModuleSoulstoneOpen(minimized:Boolean = false):void
		{
			if (!uiApi.getUi(UI_INSTANCE_NAME))
			{
				uiApi.loadUi(UI_NAME, UI_INSTANCE_NAME);
				
				sysApi.addHook(GameFightStart, onGameFightStart);
				sysApi.addHook(GameFightEnd, onGameFightEnd);
			}
		}
		
		/**
		 * Hook reporting the entrance of the player in the fight.
		 * 
		 * @param canBeCancelled	The player can cancel the fight ?
		 * @param canSayReady	The player activate the ready state ?
		 * @param isSpectator	The player is a specator ?
		 * @param timeMaxBeforeFightStart	The miximum time before the start of the fight (in millisecond, 0 if there is no time, -1 if unlimited)
		 * @param fightType	Identifier of the fight type (d2enums.FightTypeEnum)
		 */
		private function onGameFightJoin(canBeCancelled:Boolean, canSayReady:Boolean, isSpectator:Boolean, timeMaxBeforeFightStart:int, fightType:uint):void
		{
			if (fightType == FightTypeEnum.FIGHT_TYPE_PvM && !isSpectator)
			{
				sysApi.dispatchHook(ModuleSoulstoneOpen, true);
			}
		}
		
		/**
		 * Hook reporting the real start of the fight.
		 */
		private function onGameFightStart():void
		{
			if (uiApi.getUi(UI_INSTANCE_NAME))
			{
				uiApi.unloadUi(UI_INSTANCE_NAME);
			}
			
			sysApi.removeHook(GameFightStart);
		}
		
		/**
		 * Hook reporting the end of the fight.
		 * 
		 * @param result : UiPropertiesFightResult, result of the fight.
		 */
		private function onGameFightEnd(result:Object):void
		{
			if (uiApi.getUi(UI_INSTANCE_NAME))
			{
				uiApi.unloadUi(UI_INSTANCE_NAME);
			}
			
			sysApi.removeHook(GameFightEnd);
		}
	}
}
