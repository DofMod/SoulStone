package ui
{
	import d2actions.ChatTextOutput;
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
	import d2components.Slot;
	import d2components.TextArea;
	import d2data.EffectInstance;
	import d2data.ItemWrapper;
	import d2data.Monster;
	import d2enums.CharacterInventoryPositionEnum;
	import d2enums.ChatChannelsMultiEnum;
	import d2enums.ComponentHookList;
	import d2enums.LocationEnum;
	import d2hooks.UpdatePreFightersList;
	import d2hooks.WeaponUpdate;
	import enums.EffectIdEnum;
	import enums.ItemIdEnum;
	import enums.ItemTypeIdEnum;
	import flash.utils.Dictionary;
	
	/**
	 * Main ui class.
	 * 
	 * @author ExiTeD, Relena
	 */
	public class SoulStoneUi
	{
		//::///////////////////////////////////////////////////////////
		//::// Variables
		//::///////////////////////////////////////////////////////////
		
		// APIs
		public var sysApi:SystemApi;
		public var uiApi:UiApi;
		public var playCharApi:PlayedCharacterApi;
		public var chatApi:ChatApi;
		public var fightApi:FightApi;
		public var storageApi:StorageApi;
		public var dataApi:DataApi;
		public var socialApi:SocialApi;
		public var mapApi:MapApi;
		
		// Components
		public var lb_weapon:Label;
		public var lb_weapon_stats:Label;
		public var lb_info:Label;
		
		public var slot_weapon:Slot;
		
		public var btn_close:ButtonContainer;
		public var btn_open:ButtonContainer;
		
		public var ctr_main:GraphicContainer;
		public var ctr_stone:GraphicContainer;
		
		public var grid_stones:Grid;
		
		public var texta_monster:TextArea;
		
		// Some globals
		private var _monsterMaxLevel:int = 0;
		private var _equipedWeapon:ItemWrapper = null;
		private var _pendingMonsters:Array = new Array();
		private var _displayedMonsters:Array = new Array();
		
		//::///////////////////////////////////////////////////////////
		//::// Public methods
		//::///////////////////////////////////////////////////////////
		
		/**
		 * Main ui function (entry point).
		 * 
		 * @param	params
		 */
		public function main(params:Object):void
		{
			_equipedWeapon = playCharApi.getWeapon();
			
			uiApi.addComponentHook(btn_close, ComponentHookList.ON_RELEASE);
			uiApi.addComponentHook(btn_open, ComponentHookList.ON_RELEASE);
			
			sysApi.addHook(UpdatePreFightersList, onUpdatePreFightersList);
			sysApi.addHook(WeaponUpdate, onWeaponUpdate);
			
			displayWeapon(_equipedWeapon);
			displayGrid(false);
			displayUI(false);
		}
		
		/**
		 * Add the monster to the interface if he is in the fighters list.
		 * 
		 * @param	monsterUID
		 */
		public function addMonsterToDisplay(monsterUID:int):void
		{
			if (_displayedMonsters.indexOf(monsterUID) != -1 || _pendingMonsters.indexOf(monsterUID) != -1)
			{
				return;
			}
			
			var monsterFound:Boolean = false;
			for each (var fighterUID:int in fightApi.getFighters())
			{
				if (fighterUID == monsterUID)
				{
					monsterFound = true;
				}
			}
			
			if (monsterFound)
			{
				_displayedMonsters.push(monsterUID);
				
				displayMonsterList(_displayedMonsters);
				displayUI(true);
			}
			else
			{
				_pendingMonsters.push(monsterUID);
			}
		}
		
		//::///////////////////////////////////////////////////////////
		//::// Events
		//::///////////////////////////////////////////////////////////
		
		/**
		 * Update weapon callback.
		 */
		public function onWeaponUpdate():void
		{
			_equipedWeapon = playCharApi.getWeapon()
			
			displayWeapon(_equipedWeapon);
			displayAdvise(_monsterMaxLevel, _equipedWeapon);
		}
		
		/**
		 * Hook reporting the update of a fighters in pre-fight.
		 * 
		 * @param	fighterId	The identifier of the fighter to update (if no value: ).
		 */
		public function onUpdatePreFightersList(fighterId:int = 0):void
		{
			var maxLevel:int = getEnnemiesMaxLevel();
			if (maxLevel != _monsterMaxLevel)
			{
				_monsterMaxLevel = maxLevel;
				
				displayAdvise(_monsterMaxLevel, _equipedWeapon);
			}
			
			if (_displayedMonsters.indexOf(fighterId) != -1)
			{
				return;
			}
			
			var index:int = _pendingMonsters.indexOf(fighterId);
			if (index != -1)
			{
				_displayedMonsters.push(_pendingMonsters[index]);
				
				_pendingMonsters.splice(index, 1);
				
				displayMonsterList(_displayedMonsters);
				displayUI(true);
				
				return
			}
			
			var monsterGenericId:int = fightApi.getMonsterId(fighterId);
			if (monsterGenericId == -1)
			{
				return;
			}
			
			if (fightApi.getFighterInformations(fighterId).team != "defender")
			{
				return;
			}
			
			var monster:Monster = dataApi.getMonsterFromId(monsterGenericId);
			if (monster && (monster.isMiniBoss || monster.isBoss))
			{
				_displayedMonsters.push(fighterId);
				
				displayMonsterList(_displayedMonsters);
				displayUI(true);
			}
		}
		
		/**
		 * Update grid line callback.
		 * 
		 * @param	data	Data associated to le line.
		 * @param	componentsRef	Line of the grid.
		 * @param	selected	Is the line selected ?
		 */
		public function updateEntry(data:*, componentsRef:*, selected:Boolean):void
		{
			if (data !== null)
			{
				componentsRef.slot_soulstone.data = data.item;
				componentsRef.lb_success.text = data.probability + "%";
				
				uiApi.addComponentHook(componentsRef.slot_soulstone, ComponentHookList.ON_RELEASE);
				uiApi.addComponentHook(componentsRef.slot_soulstone, ComponentHookList.ON_ROLL_OVER);
				uiApi.addComponentHook(componentsRef.slot_soulstone, ComponentHookList.ON_ROLL_OUT);

				componentsRef.lb_success.visible = true;
			}
			else
			{
				componentsRef.slot_soulstone.data = null;				
				componentsRef.lb_success.visible = false;
			}
		}
		
		/**
		 * Mouse rooover callback.
		 * 
		 * @param	target
		 */
		public function onRollOver(target:Object):void
		{
			switch (target)
			{
				default:
					if (target is Slot && target.data != null)
					{
						var tooltip:Object = uiApi.textTooltipInfo(target.data.name);
						uiApi.showTooltip(tooltip, target, false, "standard", LocationEnum.POINT_BOTTOM, LocationEnum.POINT_TOP, 3, null, null, null, "TextInfo");
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
		
		/**
		 * Mouse release callback.
		 * 
		 * @param	target
		 */
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
					if (target is Slot && target.data != null)
					{
						sysApi.sendAction(new ObjectSetPosition(target.data.objectUID, CharacterInventoryPositionEnum.ACCESSORY_POSITION_WEAPON));
						sysApi.sendAction(new ChatTextOutput("[SoulStone module] Pierre équipée : " + chatApi.newChatItem(target.data), ChatChannelsMultiEnum.CHANNEL_TEAM, "", [target.data]));
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
		
		/**
		 * Return the hightest level among the ennemies.
		 * 
		 * @return	The highters level among the ennemies.
		 */
		private function getEnnemiesMaxLevel():int
		{
			var fighterMaxLevel:int = 0;
			
			for each (var fighterId:int in fightApi.getFighters())
			{
				if (fightApi.getFighterInformations(fighterId).team != "defender")
				{
					continue;
				}
				
				var fighterLevel:int = fightApi.getFighterLevel(fighterId);
				if (fighterLevel > fighterMaxLevel)
				{
					fighterMaxLevel = fighterLevel;
				}
			}
			
			return fighterMaxLevel;
		}
		
		/**
		 * Update the advise fields.
		 * 
		 * @param	levelMax	Level max of the monsters.
		 * @param	weapon	Currently equiped weapon.
		 */
		private function displayAdvise(levelMax:int, weapon:ItemWrapper):void
		{
			var advisedSoulStone:String = bestSoulStoneToUse(levelMax);
			if (weapon && weapon.typeId == ItemTypeIdEnum.SOULSTONE)
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
						
						displayGrid(false);
					}
					else
					{
						lb_info.text = "<b>La pierre d'âme équipée est trop puissante\nPierre optimale : <\b>" + advisedSoulStone;
						lb_info.colorText = 0xFF6A00; // Orange
						
						displayGrid(true, levelMax);
					}
				}
				else
				{
					lb_info.text = "<b>La pierre d'âme équipée est trop faible.\nPierre optimale : <\b>" + advisedSoulStone;
					lb_info.colorText = 0xFF0000; // Red
					
					displayGrid(true, levelMax);
				}
			}
			else
			{
				lb_info.text = "<b>Pas de pierre d'âme équipée.\nPierre optimale : <\b>" + advisedSoulStone;
				lb_info.colorText = 0xFF0000; // Red
				
				displayGrid(true, levelMax);
			}
		}
		
		/**
		 * Display the weapon equiped. Fill the associated fields.
		 * 
		 * @param	weapon	The weapon equiped.
		 */
		private function displayWeapon(weapon:ItemWrapper):void
		{
			slot_weapon.data = weapon;
			
			if (weapon != null)
			{
				lb_weapon.text = chatApi.newChatItem(weapon);
				lb_weapon_stats.text = "";
				
				if (weapon.typeId == ItemTypeIdEnum.SOULSTONE)
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
			}
		}
		
		/**
		 * Get best Soulstone name prefix.
		 * 
		 * @param	levelMaxMonsters	The hight level among the monsters.
		 * 
		 * @return	The prefix of the name of the best Soulstone.
		 */
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
		 * @param	display	Display the grid ?
		 * @param	levelMax	Hight lvl among the monsters.
		 */
		private function displayGrid(display:Boolean = true, levelMax:int = 0):void
		{
			grid_stones.visible = display;
			
			if (display == false)
			{
				return;
			}
			
			var soulstones:Dictionary = new Dictionary();
			
			// Get the soulstone of each capture probability, who have minimal power, but power > monsters level max
			for each (var item:ItemWrapper in storageApi.getViewContent("storageEquipment"))
			{
				if (item.typeId == ItemTypeIdEnum.SOULSTONE && item.id != ItemIdEnum.SOULSTONE_KRALA)
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
		 * Fill the monster textarea.
		 * 
		 * @param	monsters	The monster list to display.
		 */
		private function displayMonsterList(monsters:Array):void
		{
			texta_monster.text = "";
			
			for each (var monsterId:int in monsters)
			{
				var monsterGenericId:int = fightApi.getMonsterId(monsterId);
				if (monsterGenericId == -1)
				{
					return;
				}
				
				if (fightApi.getFighterInformations(monsterId).team != "defender")
				{
					return;
				}
				
				var monsterLevel:int = fightApi.getFighterLevel(monsterId);
				var monster:Monster = dataApi.getMonsterFromId(monsterGenericId);
			
				texta_monster.appendText(monster.name + " niv. " + monsterLevel);
			}
		}
	}
}
