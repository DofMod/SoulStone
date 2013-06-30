package ui
{
	import d2actions.ObjectSetPosition;
	import d2api.ChatApi;
	import d2api.DataApi;
	import d2api.FightApi;
	import d2api.MapApi;
	import d2api.PlayedCharacterApi;
	import d2api.SocialApi;
	import d2api.StorageApi;
	import d2api.SystemApi;
	import d2api.UiApi;
	import d2components.ButtonContainer;
	import d2components.GraphicContainer;
	import d2components.Grid;
	import d2components.Label;
	import d2components.TextArea;
	import d2components.Texture;
	import d2data.EffectInstance;
	import d2data.EffectInstanceInteger;
	import d2data.ItemWrapper;
	import d2data.Monster;
	import d2hooks.UpdatePreFightersList;
	import d2hooks.WeaponUpdate;
	import enums.EffectIdEnum;
	import enums.ItemTypeIdEnum;
	import flash.utils.Dictionary;
	
	/**
	 * Main ui class (entry point).
	 * 
	 * @author ExiTeD, Relena
	 */
	public class SoulStoneUi
	{
		//::///////////////////////////////////////////////////////////
		//::// Variables
		//::///////////////////////////////////////////////////////////
		
		public var sysApi:SystemApi;
		public var uiApi:UiApi;
		public var playCharApi:PlayedCharacterApi;
		public var chatApi:ChatApi;
		public var fightApi:FightApi;
		public var storageApi:StorageApi;
		public var dataApi:DataApi;
		public var socialApi:SocialApi;
		public var mapApi:MapApi;
		
		public var lb_weapon:Label;
		public var lb_weapon_stats:Label;
		public var lb_info:Label;
		
		public var tx_weapon:Texture;
		public var tx_slot_weapon:Texture;
		
		public var btn_close:ButtonContainer;
		public var btn_open:ButtonContainer;
		
		public var ctr_main:GraphicContainer;
		public var ctr_stone:GraphicContainer;
		
		public var grid_stones:Grid;
		
		public var texta_monster:TextArea;
		
		private var _btnRef:Dictionary = new Dictionary(false);
		private var _monsterMaxLevel:int = 0;
		private var _isFightWithArchiOrBoss:Boolean;
		
		//::///////////////////////////////////////////////////////////
		//::// Public methods
		//::///////////////////////////////////////////////////////////
		
		public function main(params:Object):void
		{
			displayUI(false);
			
			uiApi.addComponentHook(btn_close, "onRelease");
			uiApi.addComponentHook(btn_open, "onRelease");
			//uiApi.addComponentHook(tx_slot_weapon, "onRollOver");
			
			sysApi.addHook(UpdatePreFightersList, onUpdatePreFightersList);
			sysApi.addHook(WeaponUpdate, onWeaponUpdate);
		}
		
		//::///////////////////////////////////////////////////////////
		//::// Events
		//::///////////////////////////////////////////////////////////
		
		public function onWeaponUpdate():void
		{
			//Si le joueur change d'arme lui même, on met à jour
			if (_isFightWithArchiOrBoss)
			{
				updateWeapon(_monsterMaxLevel);
			}
		}
		
		/**
		 * Hook reporting the modification of the list of fighters in pre-fight.
		 * 
		 * @param	newFighterId	The identifier of the new fighter (no value is the fighter is leaving).
		 */
		public function onUpdatePreFightersList(newFighterId:int = 0):void
		{
			_monsterMaxLevel = 0;
			_isFightWithArchiOrBoss = false;
			var matchMonsters:Array = new Array();
			
			for each (var fighterId:int in fightApi.getFighters())
			{
				var monsterGenericId:int = fightApi.getMonsterId(fighterId);
				if (monsterGenericId == -1)
				{
					continue;
				}
				
				if (fightApi.getFighterInformations(fighterId).team != "defender")
				{
					continue;
				}
				
				var monsterLevel:int = fightApi.getFighterLevel(fighterId);
				if (monsterLevel >= _monsterMaxLevel)
				{
					_monsterMaxLevel = monsterLevel;
				}
				
				var monster:Monster = dataApi.getMonsterFromId(monsterGenericId);
				
				if (monster && (monster.isMiniBoss || monster.isBoss))
				{
					matchMonsters.push({"level":monsterLevel, "name":monster.name});
					
					_isFightWithArchiOrBoss = true;
				}
			}
			
			texta_monster.text = "";
			
			if (matchMonsters.length > 0)
			{
				matchMonsters.sortOn("level", Array.NUMERIC);
				
				for each (var matchMonster:Object in matchMonsters)
				{
					texta_monster.appendText(matchMonster.name + " niv. " + matchMonster.level);
				}
				
				updateWeapon(_monsterMaxLevel);
			}
		}
		
		public function updateEntry(data:*, componentsRef:*, selected:Boolean):void
		{
			//On affecte data (issue de bestSoulStone) dans le dictionnaire où on référence les boutons de la grid
			_btnRef[componentsRef.btn_equip] = data;
			
			if (data !== null)
			{
				//sysApi.log(2, "item : " + data.wrapper.name);
				var item:ItemWrapper = data.wrapper as ItemWrapper;
				componentsRef.tx_item.uri = dataApi.getItemIconUri(item.iconId);
				//On affiche 100% si > à 100% sinon on affiche X (+Y)%
				componentsRef.lb_success.text = data.reussite + "%";
				
				uiApi.addComponentHook(componentsRef.btn_equip, "onRelease");
				uiApi.addComponentHook(componentsRef.btn_equip, "onRollOver");
				uiApi.addComponentHook(componentsRef.btn_equip, "onRollOut");
				componentsRef.btn_equip.visible = true;
				componentsRef.lb_success.visible = true;
			}
			else
			{
				componentsRef.btn_equip.visible = false;
				componentsRef.lb_success.visible = false;
			}
		}
		
		public function onRollOver(target:Object):void
		{
			switch (target)
			{
				default:
					if (_btnRef[target] !== null)
					{
						var data:* = _btnRef[target];
						var toolTip:Object = uiApi.textTooltipInfo(data.wrapper.name + " (" + data.puissance + ")");
						uiApi.showTooltip(toolTip, target, false, "standard", 7, 1, 3);
					}
			}
		}
		
		/**
		 * Mouse rollout callback.
		 * 
		 * @param	target
		 */
		public function onRollOut(target:Object):void
		{
			uiApi.hideTooltip();
		}
		
		public function onRelease(target:Object):void
		{
			switch (target)
			{
				case btn_close:
					displayUI(false);
					
					break;
				case btn_open:
					displayUI(true);
					
					break;
				default:
					if (_btnRef[target] !== null)
					{
						var data:* = _btnRef[target];
						sysApi.sendAction(new ObjectSetPosition(data.wrapper.objectUID, 1, 1));
						//sysApi.log(16, data.wrapper.name);
					}
			}
		}
		
		//::///////////////////////////////////////////////////////////
		//::// Private methods
		//::///////////////////////////////////////////////////////////
		
		/**
		 * Display or hide the UI.
		 * 
		 * @param	display	Display the UI ?
		 */
		private function displayUI(display:Boolean):void
		{
			ctr_main.visible = display;
			btn_open.visible = !display;
		}
		
		private function bestSoulStoneToUse(levelMaxMonsters:int):String
		{
			var advisedSoulStone:String = "";
			
			if (levelMaxMonsters <= 50)
			{
				advisedSoulStone = "Petite Pierre d'âme";
			}
			else if (levelMaxMonsters <= 100)
			{
				advisedSoulStone = "Moyenne Pierre d'âme";
			}
			else if (levelMaxMonsters <= 150)
			{
				advisedSoulStone = "Grande Pierre d'âme";
			}
			else if (levelMaxMonsters <= 200)
			{
				advisedSoulStone = "Enorme Pierre d'âme";
			}
			else if (levelMaxMonsters <= 250)
			{
				advisedSoulStone = "Enorme pierre d'âme parfaite";
			}
			else if (levelMaxMonsters <= 500)
			{
				advisedSoulStone = "Giga Pierre d'âme";
			}
			else if (levelMaxMonsters <= 1000)
			{
				advisedSoulStone = "Gigantesque Pierre d'âme";
			}
			else if (levelMaxMonsters <= 2000)
			{
				advisedSoulStone = "Sublime Pierre d'âme";
			}
			else
			{
				advisedSoulStone = "?";
			}
			
			return advisedSoulStone;
		}
		
		private function showGrid(levelMax:int):void
		{
			var availableSoulStones:Array = new Array();
			
			//On parcours les objets équipables de l'inventaire
			for each (var item:ItemWrapper in storageApi.getViewContent("storageEquipement"))
			{
				//Si catégorie est "pierre d'âmes" et la pierre n'est pas celle du krala
				if (item.type.id == 83 && item.id != 9718)
				{
					//On parcours l'effet des pierres pour stocker des infos dans le tableau
					for each (var effect:EffectInstanceInteger in item.effects)
					{
						//Si la puissance est suffisante
						if (effect.parameter2 >= levelMax)
						{
							//parameter0 : %Age de Chance, parameter2 :Niveau Max
							availableSoulStones.push({wrapper: item, reussite: effect.parameter0, puissance: effect.parameter2});
						}
					}
				}
			}
			
			//On trie le tableau pour pouvoir ressortir les pierres optimales
			availableSoulStones.sortOn(["reussite", "puissance"], [Array.NUMERIC, Array.NUMERIC])
			
			var bestSoulStones:Array = new Array();
			var tmpReussite:int = 0;
			//On parcours les pierres d'âme disponibles
			for (var y:int = 0; y < availableSoulStones.length; y++)
			{
				//sysApi.log(4,availableSoulStones[y].wrapper.name + " % : " + availableSoulStones[y].reussite + " lvl : " + availableSoulStones[y].puissance);
				//On stocke la réussite de la pierre en cours pour comparer
				tmpReussite = availableSoulStones[y].reussite;
				bestSoulStones.push(availableSoulStones[y]);
				
				//On parcours le tableau pour voir si d'autres pierres ont la même réussite, si oui on les supprime
				for (var z:int = 0; z < availableSoulStones.length; z++)
				{
					//Si on trouve la même réussite, on supprime la ligne et on continue avec ligne = ligne - 1
					if (availableSoulStones[z].reussite == tmpReussite && z != y)
					{
						availableSoulStones.splice(z, 1)
						z = z - 1;
					}
				}
			}
			
			grid_stones.dataProvider = bestSoulStones;
			
			//for ( var k : int = 0 ; k < bestSoulStones.length ; k++ ) {
				//sysApi.log(6,bestSoulStones[k].wrapper.name + " % : " + bestSoulStones[k].reussite + " lvl : " + bestSoulStones[k].puissance);
			//}
		}
		
		/**
		 * Display the weapon equiped. Fill the associated fields.
		 * 
		 * @param	weapon	The weapon equiped.
		 */
		private function displayWeapon(weapon:ItemWrapper):void
		{
			if (weapon != null)
			{
				lb_weapon.text = chatApi.newChatItem(weapon);
				lb_weapon_stats.text = "";
				tx_weapon.uri = weapon.iconUri;
				
				if (weapon.type.id == ItemTypeIdEnum.SOULSTONE)
				{
					for each (var effect:EffectInstance in weapon.effects)
					{
						if (effect.effectId == EffectIdEnum.SOUL_CAPTURE)
						{
							lb_weapon_stats.text = effect.description;
						}
					}
				}
			}
			else
			{
				lb_weapon.text = "Aucun CàC équipé";
				lb_weapon_stats.text = "";
				tx_weapon.uri = null;
			}
		}
		
		private function updateWeapon(levelMax:int):void
		{
			//On initialise des variables
			grid_stones.visible = true;
			tx_weapon.uri = null;
			
			var weapon:ItemWrapper = playCharApi.getWeapon();
			
			displayWeapon(weapon);
			
			if (weapon.type.id == ItemTypeIdEnum.SOULSTONE)
			{
				var soulStone:ItemWrapper = weapon;
			}
			
			var advisedSoulStone:String = bestSoulStoneToUse(levelMax);
			
			//Si on a une pierre d'âme équipée ( chargée dans getMyWeaponItem() )
			if (soulStone != null)
			{
				//On parcours les effets de la pierre pour récupérer sa puissance
				for each (var soulStoneEffect:EffectInstanceInteger in soulStone.effects)
				{
					//sysApi.log(8, "effect.description : " + soulStoneEffect.description);
					var puissanceSoulStone:Object = soulStoneEffect.parameter2
				}
				
				//Si la puissance est suffisante
				if (puissanceSoulStone >= levelMax)
				{
					//On vérifie si la puissance de la pierre (qui est suffisante) est optimale
					if (soulStone.name.search(advisedSoulStone) != -1)
					{
						lb_info.text = "<b>La pierre d'âme équipée est de puissance optimale<\b>";
						lb_info.colorText = 0x007F0E; //Vert
						grid_stones.visible = false;
					}
					else
					{
						lb_info.text = "<b>La pierre d'âme équipée est bonne sa puissance mais sa n'est pas optimale \nPierre optimale : <\b>" + advisedSoulStone;
						lb_info.colorText = 0xFF6A00; //Orange
						grid_stones.visible = false;
					}
				}
				else
				{
					lb_info.text = "<b>Pierre équipée de puissance insuffisante \nPierre optimale : <\b>" + advisedSoulStone;
					lb_info.colorText = 0xFF0000; //Rouge
					showGrid(levelMax);
				}
			}
			else
			{
				lb_info.text = "<b>Pas de pierre équipée \nPierre optimale : <\b>" + advisedSoulStone;
				lb_info.colorText = 0xFF0000; //Rouge
				showGrid(levelMax);
			}
			
			displayUI(true);
		}
	}
}
