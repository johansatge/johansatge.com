﻿package js{	import flash.display.MovieClip;	import flash.display.BitmapData;	import flash.events.Event;	import flash.display.Bitmap;	import flash.filters.DropShadowFilter;	import flash.events.MouseEvent;	import com.greensock.TweenLite;	import com.greensock.easing.Back;	import com.greensock.easing.Cubic;		public class MainMenu extends MovieClip	{				private var labelTitle:String;		private var labelSubtitle:String;		private var genericDust:BitmapData;		private var mainCircle:MovieClip;		private var mainCircleRadius:int;		private var mainCircleShadow:DropShadowFilter;		private var menuItems:Array;		private var menuItemsContainer:MovieClip;		private var submenuItemsContainer:MovieClip;		private var backgroundLines:MovieClip;		private var backgroundBitmap:Bitmap;		private var rotationMargin:int;		private var initialRotation:int;		private var rotationAmplitude:int;		private var circleSpeed:Number;		private var itemsSpeed:Number;		private var itemsDelay:Number;		private var itemsMargin:int;		private var itemsPadding:int;		private var rotationSpeed:Number;		private var submenuItems:Array;		private var displayedSubmenu:Submenu;				/**		 * Inits the main menu		 * @param	Array	menuItems			the menu items		 * @param	Array	submenuItems		the submenus (associative array)		 * @param	Bitmap	genericDust			the dust		 * @param	Bitmap	backgroundLines		the lines		 * @param	XMLList	parameters			the menu parameters		 */		public function MainMenu(menuItems:Array , submenuItems:Array , genericDust:BitmapData , backgroundBitmap:BitmapData , parameters:XMLList)		{			this.visible = false;			this.genericDust = genericDust;			this.displayedSubmenu = null;			this.mainCircleShadow = new DropShadowFilter(0 , 0 , 0x000000 , Number(parameters.@shadow_alpha.toString()) , int(parameters.@shadow_radius.toString()) , int(parameters.@shadow_radius.toString()));			this.menuItems = menuItems;			this.submenuItems = submenuItems;			this.labelTitle = parameters.title.toString();			this.labelSubtitle = parameters.subtitle.toString();			this.rotationMargin = int(parameters.@rotation_step.toString());			this.initialRotation = int(parameters.@initial_rotation.toString());			this.rotationAmplitude = int(parameters.@rotation_amplitude.toString());			this.circleSpeed = Number(parameters.@speed.toString());			this.mainCircleRadius = int(parameters.@radius.toString());			this.itemsSpeed = Number(parameters.items.@speed.toString());			this.itemsDelay = Number(parameters.items.@delay.toString());			this.itemsMargin = Number(parameters.items.@margin.toString());			this.itemsPadding = Number(parameters.items.@padding.toString());			this.rotationSpeed = Number(parameters.@rotation_speed.toString());			this.backgroundBitmap = new Bitmap(backgroundBitmap);			if (stage)				this.addedToStage(null);			else				this.addEventListener(Event.ADDED_TO_STAGE , this.addedToStage);		}				/**		 * Fired when added to stage		 * @param	Event	evt		the event		 * @return	void		 */		private function addedToStage(evt:Event = null):void		{			if (evt != null)				evt.target.removeEventListener(Event.ADDED_TO_STAGE , this.addedToStage);			// Initial state			this.visible = false;			// Background			this.backgroundLines = new MovieClip();			this.backgroundLines.addChild(this.backgroundBitmap);			this.addChild(this.backgroundLines);			this.backgroundBitmap.x = int(-this.backgroundBitmap.width / 2);			this.backgroundBitmap.y = int(-this.backgroundBitmap.height / 2);			// Main circle			this.mainCircle = new MovieClip();			this.mainCircle.filters = [this.mainCircleShadow];			this.addChild(this.mainCircle);			this.mainCircle.addChild(this.mainMenuLabels);			this.drawMainCircle(this.mainCircleRadius);			this.mainCircle.cacheAsBitmap = true;			// Labels			this.mainMenuLabels.mainTitle.htmlText = this.labelTitle;			this.mainMenuLabels.mainSubtitle.htmlText = this.labelSubtitle;			// Menu items			this.menuItemsContainer = new MovieClip();			this.addChild(this.menuItemsContainer);			var theRotation:int = 0;			for each(var item:MainMenuItem in this.menuItems)			{				this.menuItemsContainer.addChild(item);				item.registerParentMenu(this);				item.setOriginalRotation(theRotation);				theRotation += this.rotationMargin;			}			this.menuItemsContainer.rotation = this.initialRotation;			// Submenu items			this.submenuItemsContainer = new MovieClip();			this.addChild(this.submenuItemsContainer);			for(var index:String in this.submenuItems)				this.submenuItemsContainer.addChild(this.submenuItems [index]);			stage.addEventListener(MouseEvent.MOUSE_MOVE , moveMenu);		}				/**		 * Displays the menu		 * @param	Function	callback	function called when the animation is done		 * @return	void		 */		public function displayMenu(callback:Function = null):void		{			// Prepares			this.mainCircle.scaleX = 0;			this.mainCircle.scaleY = 0;			this.backgroundLines.scaleX = 0;			this.backgroundLines.scaleY = 0;			this.visible = true;			// Main circle			TweenLite.to(this.mainCircle , this.circleSpeed , {scaleX:1 , scaleY:1 , ease:Back.easeOut});			// Lines			TweenLite.to(this.backgroundLines , this.circleSpeed , {scaleX:1 , scaleY:1});			// Menu items			var menuDelay:Number = this.circleSpeed;			var afterDelay:Number;			for(var index:int = 0; index < this.menuItemsContainer.numChildren; index++)			{				var item:MainMenuItem = MainMenuItem(this.menuItemsContainer.getChildAt(index));				item.displayItem(menuDelay);				afterDelay = item.getDelayAfter();				menuDelay += afterDelay;			}			TweenLite.delayedCall(menuDelay + afterDelay , enableMenu);			if (callback != null)				TweenLite.delayedCall(menuDelay , callback);			stage.addEventListener(MouseEvent.MOUSE_MOVE , moveMenu);		}				/**		 * Enables navigation		 * @return	void		 */		private function enableMenu():void		{			for(var index:int = 0; index < this.menuItemsContainer.numChildren; index++)			{				var item:MainMenuItem = MainMenuItem(this.menuItemsContainer.getChildAt(index));				item.enableItem();			}		}				/**		 * Moves the main menu		 * @param	MouseEvent	evt		the mouse event		 * @return	void		 */		private function moveMenu(evt:MouseEvent):void		{			var theRotation:Number = this.convertRange(0 , stage.stageHeight , evt.stageY , this.initialRotation + this.rotationAmplitude , this.initialRotation);			theRotation = Math.floor(theRotation * 1000) / 1000;			TweenLite.to(this.menuItemsContainer , this.rotationSpeed , {rotation:theRotation , ease:Cubic.easeOut});		}				/**		 * Hides the main menu		 * @param	Function	callback	function called when the animation is done		 * @return	void		 */		public function hideElement(callback:Function = null):void		{			// Menu items			var menuDelay:Number = 0;			for(var index:int = 0; index < this.menuItemsContainer.numChildren; index++)			{				var item:MainMenuItem = MainMenuItem(this.menuItemsContainer.getChildAt(index));				item.hideItem(menuDelay);				menuDelay += item.getDelayAfter();			}			// Main circle			TweenLite.to(this.mainCircle , this.circleSpeed , {scaleX:0 , scaleY:0 , delay:menuDelay});			// Lines			TweenLite.to(this.backgroundLines , this.circleSpeed , {scaleX:0 , scaleY:0 , delay:menuDelay});			// Submenu			if (this.displayedSubmenu != null)				this.displayedSubmenu.hideSubmenu();			// Events and callback						stage.removeEventListener(MouseEvent.MOUSE_MOVE , moveMenu);			if (callback != null)				TweenLite.delayedCall(this.circleSpeed + menuDelay , callback);		}				/**		 * Draws the main circle		 * @param	Number	radius	the radius		 * @return	void		 */		private function drawMainCircle(radius:Number):void		{			this.mainCircle.graphics.clear();			this.mainCircle.graphics.beginBitmapFill(this.genericDust);			this.mainCircle.graphics.drawCircle(0 , 0 , radius);			this.mainCircle.graphics.endFill();					}				/**		 * Displays or hides a submenu		 * @param	String	submenuID		the submenu identifier		 * @return	void		 */		public function switchSubmenu(submenuID:String):void		{			var submenu:Submenu = this.submenuItems [submenuID] as Submenu;			if (submenu.isDisplayed())			{				submenu.hideSubmenu();				this.displayedSubmenu = null;			}			else			{				submenu.displaySubmenu();				this.displayedSubmenu = submenu;			}		}				/**		 * Resizes		 * @param	int		contextWidth	the width		 * @param	int		contextHeight	the height		 * @param	Number	speed			the speed		 * @return	void		 */		public function resizeMenu(contextWidth:int , contextHeight:int , speed:Number):void		{			var centerX:int = int(contextWidth / 2);			var centerY:int = int(contextHeight / 2);			TweenLite.to(this.mainCircle , speed , {x:centerX , y:centerY , ease:Back.easeOut});			TweenLite.to(this.menuItemsContainer , speed , {x:centerX , y:centerY , ease:Back.easeOut});			TweenLite.to(this.backgroundLines , speed , {x:centerX , y:centerY , ease:Back.easeOut});			for (var index:int = 0; index < this.submenuItemsContainer.numChildren; index++)			{				var theMenu:Submenu = this.submenuItemsContainer.getChildAt(index) as Submenu;				var theX:int = int((contextWidth - theMenu.getWidth()) / 2);				var theY:int = int((contextHeight / 2) + (contextHeight / 4) + (this.mainCircleRadius / 2));				TweenLite.to(theMenu , speed , {x:theX , y:theY , ease:Back.easeOut});			}		}		/**		 * Ranges calculation: Takes a range and a value in it, and translates the value using a second range		 * @param	Number	range1Min		 * @param	Number	range1Max		 * @param	Number 	range1Value		 * @param	Number	range2Min		 * @param	Number	range2Max		 * @return	Number		 */		private function convertRange(range1Min:Number , range1Max:Number , range1Value:Number , range2Min:Number , range2Max:Number):Number		{			return ((range1Value - range1Min) / ((range1Max - range1Min) / (range2Max - range2Min))) + range2Min;		}			}}