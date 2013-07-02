package ui
{
	import d2actions.ObjectSetPosition;
	import d2api.DataApi;
	import d2api.PlayedCharacterApi;
	import d2api.StorageApi;
	import d2api.SystemApi;
	import d2api.UiApi;
	import d2components.ButtonContainer;
	import d2components.Slot;
	import d2data.ItemWrapper;
	import d2enums.CharacterInventoryPositionEnum;
	import d2enums.ComponentHookList;
	import d2enums.LocationEnum;
	
	/**
	 * Equip weapon ui class.
	 *
	 * @author ExiTeD, Relena
	 */
	public class SoulStoneWeaponUi
	{
		//::///////////////////////////////////////////////////////////
		//::// Variables
		//::///////////////////////////////////////////////////////////
		
		// APIs
		public var sysApi:SystemApi;
		public var uiApi:UiApi;
		public var playerApi:PlayedCharacterApi;
		public var storageApi:StorageApi;
		public var dataApi:DataApi;
		
		// Components
		public var slot_weapon:Slot;
		
		public var btn_close:ButtonContainer;
		
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
			var weapon:ItemWrapper = params.weapon;
			
			slot_weapon.data = weapon;
			
			uiApi.addComponentHook(btn_close, ComponentHookList.ON_RELEASE);
			uiApi.addComponentHook(slot_weapon, ComponentHookList.ON_RELEASE);
		}
		
		//::///////////////////////////////////////////////////////////
		//::// Events
		//::///////////////////////////////////////////////////////////
		
		/**
		 * Mouse rooover callback.
		 *
		 * @param	target
		 */
		public function onRollOver(target:Object):void
		{
			switch (target)
			{
				case slot_weapon:
					var tooltip:Object = uiApi.textTooltipInfo(slot_weapon.data ? slot_weapon.data.name : "Vous n'avez jamais eu d'arme depuis votre connexion.");
					uiApi.showTooltip(tooltip, target, false, "standard", LocationEnum.POINT_BOTTOM, LocationEnum.POINT_TOP, 3, null, null, null, "TextInfo");
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
					closeUi();
					
					break;
				case slot_weapon:
					if (slot_weapon.data)
					{
						sysApi.sendAction(new ObjectSetPosition(slot_weapon.data.objectUID, CharacterInventoryPositionEnum.ACCESSORY_POSITION_WEAPON));
					}
					
					break;
			}
		}
	
		//::///////////////////////////////////////////////////////////
		//::// Private methods
		//::///////////////////////////////////////////////////////////
		
		/**
		 * Close the UI.
		 */
		private function closeUi():void
		{
			uiApi.unloadUi(uiApi.me().name);			
		}
	}
}
