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
		 * Hook reporting the update of a fighters in pre-fight.
		 * 
		 * @param	newFighterId	The identifier of the fighter to update (if no value: ).
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
				var item:ItemWrapper = data.item as ItemWrapper;
				componentsRef.tx_item.uri = dataApi.getItemIconUri(item.iconId);
				//On affiche 100% si > à 100% sinon on affiche X (+Y)%
				componentsRef.lb_success.text = data.probability + "%";
				
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
		
		/**
		 * Select the best soulstones and send the to display.
		 * 
		 * @param	levelMax	Hight lvl among the monsters.
		 */
		private function showGrid(levelMax:int):void
		{
			var soulstones:Dictionary = new Dictionary();
			
			// Get the soulstone of each capture probability, who have minimal power, but power > monsters level max
			for each (var item:ItemWrapper in storageApi.getViewContent("storageEquipment"))
			{
				// 9718 : id of the Kralamour's soulstone
				if (item.type.id == ItemTypeIdEnum.SOULSTONE && item.id != 9718)
				{
					for each (var effect:EffectInstance in item.effects)
					{
						if (effect.effectId == EffectIdEnum.SOUL_CAPTURE)
						{
							// parameter0 : %chance of capture
							// parameter1 : ?
							// parameter2 : Max level of capture
							
							var probability:int = effect.parameter0 as int;
							var power:int = effect.parameter2 as int;
							
							if (power >= levelMax)
							{
								if (soulstones[probability] == undefined || soulstones[probability].power > power)
								{
									soulstones[probability] = {item: item, power: power, probability: probability};
								}
							}
						}
					}
				}
			}
			
			var soulstoneList:Array = new Array();
			for each (var soulstone:Object in soulstones)
			{
				soulstoneList.push(soulstone);
			}
			
			grid_stones.dataProvider = soulstoneList;
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
		
		/**
		 * Update weapon's fields and display grid if needed.
		 * 
		 * @param	levelMax	Level max of the monsters.
		 */
		private function updateWeapon(levelMax:int):void
		{
			grid_stones.visible = true;
			tx_weapon.uri = null;
			
			var weapon:ItemWrapper = playCharApi.getWeapon();
			var advisedSoulStone:String = bestSoulStoneToUse(levelMax);
			
			displayWeapon(weapon);
			
			if (weapon && weapon.type.id == ItemTypeIdEnum.SOULSTONE)
			{
				for each (var effect:EffectInstance in weapon.effects)
				{
					if (effect.effectId == EffectIdEnum.SOUL_CAPTURE)
					{
						var puissanceSoulStone:Object = effect.parameter2;
						
						// parameter0 : %chance of capture
						// parameter1 : ?
						// parameter2 : Max level of capture
					}
				}
				
				if (puissanceSoulStone >= levelMax)
				{
					//On vérifie si la puissance de la pierre (qui est suffisante) est optimale
					if (weapon.name.search(advisedSoulStone) != -1)
					{
						lb_info.text = "<b>La pierre d'âme équipée est de puissance optimale<\b>";
						lb_info.colorText = 0x007F0E; // Green
						
						grid_stones.visible = false;
					}
					else
					{
						lb_info.text = "<b>La pierre d'âme équipée est bonne sa puissance mais sa n'est pas optimale \nPierre optimale : <\b>" + advisedSoulStone;
						lb_info.colorText = 0xFF6A00; // Orange
						
						grid_stones.visible = false;
					}
				}
				else
				{
					lb_info.text = "<b>Pierre équipée de puissance insuffisante \nPierre optimale : <\b>" + advisedSoulStone;
					lb_info.colorText = 0xFF0000; // Red
					
					showGrid(levelMax);
				}
			}
			else
			{
				lb_info.text = "<b>Pas de pierre équipée \nPierre optimale : <\b>" + advisedSoulStone;
				lb_info.colorText = 0xFF0000; // Red
				
				showGrid(levelMax);
			}
			
			displayUI(true);
		}
	}
}
