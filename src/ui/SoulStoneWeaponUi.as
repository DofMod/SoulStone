package ui
{
	import d2api.DataApi;
	import d2api.PlayedCharacterApi;
	import d2api.StorageApi;
	import d2api.SystemApi;
	import d2api.UiApi;
	import d2components.ButtonContainer;
	import d2components.Slot;
	import d2enums.ComponentHookList;
	
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
			slot_weapon.data = playerApi.getWeapon();
			
			uiApi.addComponentHook(btn_close, ComponentHookList.ON_RELEASE);
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
				//var tooltip:Object = uiApi.textTooltipInfo("");
				//uiApi.showTooltip(tooltip, target, false, "standard", LocationEnum.POINT_BOTTOM, LocationEnum.POINT_TOP, 3, null, null, null, "TextInfo");
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
					uiApi.unloadUi(uiApi.me().name);
				
				//sysApi.sendAction(new ObjectSetPosition(item, CharacterInventoryPositionEnum.ACCESSORY_POSITION_WEAPON));
			}
		}
	
		//::///////////////////////////////////////////////////////////
		//::// Private methods
		//::///////////////////////////////////////////////////////////
	}
}
