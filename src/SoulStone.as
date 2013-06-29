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
	
	public class SoulStone extends Sprite
	{
		//::///////////////////////////////////////////////////////////
		//::// Variables
		//::///////////////////////////////////////////////////////////
		
		import ui.SoulStoneUi;
		protected var soulStoneUi:SoulStoneUi;
		
		private static const UI_NAME:String = "soulstone";
		private static const UI_INSTANCE_NAME:String = "soulstone";
		
		public var uiApi:UiApi;
		public var sysApi:SystemApi;
		public var dataApi:DataApi;
		
		public static var allBoss:Dictionary = new Dictionary();
		public static var allMonsters:Object;
		public static var dicoMonsters:Dictionary = new Dictionary();
		
		//::///////////////////////////////////////////////////////////
		//::// Méthodes publiques
		//::///////////////////////////////////////////////////////////
		
		public function main():void
		{
			allBoss[2975] = "Boostache";
			allBoss[605] = "Péki Péki";
			allBoss[257] = "Chêne Mou";
			allBoss[2877] = "Ben le Ripate";
			allBoss[2848] = "Mansot Royal";
			allBoss[2992] = "Professeur Xa";
			allBoss[2970] = "Fuji Givrefoux";
			allBoss[1184] = "Blop Coco Royal";
			allBoss[1185] = "Blop Griotte Royal";
			allBoss[1186] = "Blop Indigo Royal";
			allBoss[1187] = "Blop Reinette Royal";
			allBoss[3142] = "Grozilla";
			allBoss[3143] = "Grasmera";
			allBoss[2821] = "Coffre de Dédé";
			allBoss[252] = "Coffre des Forgerons";
			allBoss[1071] = "Silf le Rasboul Majeur";
			allBoss[121] = "Minotoror";
			allBoss[854] = "Crocabulia";
			allBoss[780] = "Skeunk";
			allBoss[382] = "Tofu Royal";
			allBoss[289] = "Maître Corbac";
			allBoss[423] = "Kralamoure Géant";
			allBoss[612] = "Maître Pandore";
			allBoss[940] = "Rat Blanc";
			allBoss[568] = "Tanukouï San";
			allBoss[874] = "Demi Papa Nowel";
			allBoss[1179] = "Sapik";
			allBoss[232] = "Meulou";
			allBoss[872] = "Papa Nowel";
			allBoss[2995] = "Kwakwa";
			allBoss[1194] = "Père Fwetar";
			allBoss[2942] = "N";
			allBoss[2772] = "Jorbak";
			allBoss[2887] = "Cromignons";
			allBoss[831] = "Mominotor";
			allBoss[2922] = "Cromignons";
			allBoss[832] = "Déminoboule";
			allBoss[1087] = "Tynril Ahuri";
			allBoss[1072] = "Tynril Consterné";
			allBoss[1085] = "Tynril Déconcerté";
			allBoss[182] = "Wabbit Gm";
			allBoss[2802] = "Manitou Zoth";
			allBoss[2793] = "Krtek";
			allBoss[107] = "Dark Vlad";
			allBoss[1196] = "Demi père Fwetar";
			allBoss[2786] = "Vampire Dupyr";
			allBoss[499] = "Minotoboule de Nowel";
			allBoss[226] = "Moon";
			allBoss[230] = "Le Chouque";
			allBoss[2924] = "Obsidiantre";
			allBoss[1001] = "Milimilou";
			allBoss[799] = "Tournesol Affamé";
			allBoss[928] = "Mob l'Eponge";
			allBoss[147] = "Bouftou Royal";
			allBoss[2960] = "Kanniboul Ebil";
			allBoss[173] = "Abraknyde Ancestral";
			allBoss[1188] = "Blop Multicolore Royal";
			allBoss[180] = "Wa Wabbit";
			allBoss[457] = "Shin Larve";
			allBoss[797] = "Scarabosse Doré";
			allBoss[669] = "Craqueleur Légendaire";
			allBoss[1027] = "Corailleur Magistral";
			allBoss[792] = "Bworkette";
			allBoss[113] = "Dragon Cochon";
			allBoss[800] = "Batofu";
			allBoss[58] = "Gelée Royale Bleue";
			allBoss[430] = "Gelée Royale Citron";
			allBoss[86] = "Gelée Royale Fraise";
			allBoss[85] = "Gelée Royale Menthe";
			allBoss[1051] = "Gourlo le Terrible";
			allBoss[670] = "Koulosse";
			allBoss[2854] = "Royalmouth";
			allBoss[3100] = "Nelween";
			allBoss[939] = "Rat Noir";
			allBoss[1086] = "Tynril Perfide";
			allBoss[943] = "Sphincter Cell";
			allBoss[2968] = "Korriandre";
			allBoss[2986] = "Kolosso";
			allBoss[2967] = "Tengu Givrefoux";
			allBoss[2864] = "Glourséleste";
			allBoss[1045] = "Kimbo";
			allBoss[827] = "Minotot";
			allBoss[478] = "Bworker";
			allBoss[1159] = "Ougah";
			
			allMonsters = dataApi.getMonsters();
			
			for each (var monster:Monster in allMonsters)
			{
				dicoMonsters[monster.name] = monster;
			}
			
			sysApi.addHook(GameFightJoin, onGameFightJoin);
		}
		
		//::///////////////////////////////////////////////////////////
		//::// Evenements
		//::///////////////////////////////////////////////////////////
		
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
					uiApi.loadUi(UI_NAME, UI_INSTANCE_NAME);
					
					sysApi.addHook(GameFightStart, onGameFightStart);
					sysApi.addHook(GameFightEnd, onGameFightEnd);
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
