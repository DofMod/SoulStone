package
{
	import d2api.DataApi;
	import d2api.FightApi;
	import d2api.SystemApi;
	import d2api.UiApi;
	import d2enums.FightTypeEnum;
	import d2hooks.GameFightEnd;
	import d2hooks.GameFightJoin;
	import d2hooks.GameFightStart;
	import flash.display.Sprite;
	import hooks.ModuleSoulstoneDisplayMonster;
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
		public var fightApi:FightApi;
		
		// Some globals
		private var _pendingMonsters:Array = new Array();
		
		//::///////////////////////////////////////////////////////////
		//::// Public methods
		//::///////////////////////////////////////////////////////////
		
		public function main():void
		{
			sysApi.createHook("ModuleSoulstoneDisplayMonster");
			
			sysApi.addHook(GameFightJoin, onGameFightJoin);
			sysApi.addHook(ModuleSoulstoneDisplayMonster, onModuleSoulstoneDisplayMonster);
		}
		
		//::///////////////////////////////////////////////////////////
		//::// Events
		//::///////////////////////////////////////////////////////////
		
		/**
		 * Hook reporting a request to display a monster in the UI.
		 * 
		 * @param	monsterUID	UID of the monster to display.
		 */
		private function onModuleSoulstoneDisplayMonster(monsterUID:int):void
		{
			if (sysApi.isFightContext() == false)
			{
				sysApi.log(4, "Can not open UI outside of fight context.");
				
				return;
			}
			
			if (fightApi.preFightIsActive() == false)
			{
				sysApi.log(4, "Can not open UI when fight is sarted.");
				
				return;
			}
			
			if (fightApi.getFightType() != FightTypeEnum.FIGHT_TYPE_PvM)
			{
				sysApi.log(4, "Can not open UI if it's not de PvM fight");
				
				return;
			}
			
			if (fightApi.isSpectator())
			{
				sysApi.log(4, "Can not open UI if character is a spectator");
				
				return;
			}
			
			var soulstoneUI:Object = uiApi.getUi(UI_INSTANCE_NAME);
			if (soulstoneUI)
			{
				var soulstoneUIScript:SoulStoneUi = soulstoneUI.uiClass;
				
				soulstoneUIScript.displayMonster(monsterUID);
			}
			else
			{
				_pendingMonsters.push(monsterUID);
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
				if (!uiApi.getUi(UI_INSTANCE_NAME))
				{
					sysApi.addHook(GameFightStart, onGameFightStart);
					sysApi.addHook(GameFightEnd, onGameFightEnd);
					
					var soulstoneUIScript:SoulStoneUi = uiApi.loadUi(UI_NAME, UI_INSTANCE_NAME).uiClass;
				
					while (_pendingMonsters.length)
					{
						soulstoneUIScript.displayMonster(_pendingMonsters.shift());
					}
				}
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
