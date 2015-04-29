﻿package js{	import flash.display.MovieClip;	import flash.display.StageAlign;	import flash.display.StageScaleMode;	import flash.events.Event;	import flash.events.MouseEvent;	import flash.events.ProgressEvent;	import flash.events.IOErrorEvent;	import flash.net.URLLoader;	import flash.net.URLRequest;	import flash.display.Bitmap;	import js.Weft;	import js.Parallax;	import js.CircularLoader;	import js.MainMenu;	import js.ContactPage;	import js.AboutPage;	import js.ContextualMenu;	import com.greensock.TweenLite;	import com.greensock.plugins.TweenPlugin;	import com.greensock.plugins.BlurFilterPlugin;	import com.asual.swfaddress.SWFAddress;	import com.asual.swfaddress.SWFAddressEvent;		public class Main extends MovieClip	{				// Config data		private var siteURL:String;		private var picturesPath:String;		private var configPath:String;		private var config:XML;		private var resizeSpeed:Number;		// Graphics objects		private var circularLoader:CircularLoader;		private var weft:Weft;		private var parallax:Parallax;		private var mainMenu:MainMenu;		// Events		private var currentMouseX:int;		private var currentMouseY:int;		private var currentContext:Object;		// Pages		private var contactPage:ContactPage;		private var aboutPage:AboutPage;				/**		 * Builds the main object		 */		public function Main()		{			// Setups vars			this.currentMouseX = 0;			this.currentMouseY = 0;			this.resizeSpeed = 0;			this.currentContext = null;			// Waits for runtime			if (stage)				this.init();			else				this.addEventListener(Event.ADDED_TO_STAGE , init);			// Needed TweenLite plugins			TweenPlugin.activate([BlurFilterPlugin]);		}				/**		 * Inits the app		 * @return	void		 */		 private function init(evt:Event = null):void		 {			Main.debug('Stage available');			// Setups paths			this.siteURL = (stage.loaderInfo.parameters ['siteURL'] != undefined) ? stage.loaderInfo.parameters ['siteURL'] : 'http://johansatge.local';			this.picturesPath = this.siteURL + '/img/';			this.configPath = this.siteURL + '/xml/config.xml?' + Main.getRandomValue();			// Setups stage			if (evt != null)				this.removeEventListener(Event.ADDED_TO_STAGE , init);			stage.align = StageAlign.TOP_LEFT;			stage.scaleMode = StageScaleMode.NO_SCALE;			stage.frameRate = 40;			stage.addEventListener(Event.RESIZE , handleResize);			stage.addEventListener(MouseEvent.MOUSE_MOVE , saveMousePosition);			// Loads config xml file			var xmlLoader:URLLoader = new URLLoader();			xmlLoader.load(new URLRequest(this.configPath));			xmlLoader.addEventListener(Event.COMPLETE , configLoaded);			xmlLoader.addEventListener(ProgressEvent.PROGRESS , configLoading);			xmlLoader.addEventListener(IOErrorEvent.IO_ERROR , configLoadingFailed);		 }		 		/**		 * Called when loading xml config file		 * @param	ProgressEvent	evt		the progress event with the data		 * @return 	void		 */		private function configLoading(evt:ProgressEvent):void { }				/*		 * Called if the loading of the xml config file failed		 * @param	Event	evt		the loading event		 * @return	void		 */		private function configLoadingFailed(evt:Event):void		{			Main.debug('Loading xml config file failed');			evt.target.removeEventListener(Event.COMPLETE , configLoaded);			evt.target.removeEventListener(IOErrorEvent.IO_ERROR , configLoadingFailed);		}				/**		 * Called if loading of the config file succeeded		 * @param	Event	evt		the loading event		 * @return void		 */		private function configLoaded(evt:Event):void		{			try			{				this.config = new XML(evt.target.data);				Main.debug('Config file loaded');				this.setupApp();			}			catch(e:Error)			{				Main.debug('Parsing config file failed (' + e.toString() + ')');			}			evt.target.removeEventListener(Event.COMPLETE , configLoaded);			evt.target.removeEventListener(IOErrorEvent.IO_ERROR , configLoadingFailed);		}				/**		 * Setups the scene when the XML config file is ready, and loads the parallax		 * @return	void		 */		private function setupApp()		{						this.resizeSpeed = Number(this.config.@resize_speed.toString());			this.setupContextualMenu();			this.setupParallax();			this.setupWeft();			this.setupParallaxLoader();			this.setupMainMenu();			this.loadParallax();			this.setupContactPage();			this.setupAboutPage();		}				/**		 * Setups the contextual menu		 * @return	void		 */		private function setupContextualMenu()		{			var customMenu:ContextualMenu = new ContextualMenu();			customMenu.addItem(this.config.@menu.toString());			customMenu.enable(this);		}				/**		 * Setups the parallax		 * @return	void		 */		private function setupParallax():void		{			// Inits the parallax background			var parallaxPictures = new Array();			for each(var picture:XML in this.config.parallax.item)			{				var parallaxPictureConfig = new Object();				parallaxPictureConfig.filename = this.picturesPath + picture.@filename.toString();				parallaxPictureConfig.amplitude = int(picture.@amplitude.toString());				parallaxPictures.push(parallaxPictureConfig);			}			this.parallax = new Parallax(parallaxPictures , Main.toBoolean(this.config.parallax.@smooth.toString()) , Number(this.config.parallax.@inertia.toString()));			this.addChild(this.parallax);		}				/**		 * Setups the weft		 * @return	void		 */		private function setupWeft():void		{			// Inits the weft and resizes			this.weft = new Weft(new BitmapWeft() , Number(this.config.weft.@alpha.toString()));			this.addChild(this.weft);			this.weft.resizeWeft(stage.stageWidth , stage.stageHeight , 0);		}				/**		 * Setups the parallax loader		 * @return	void		 */		private function setupParallaxLoader():void		{			// Inits the loader and resizes			var bitmapDust:Bitmap = new Bitmap(new BitmapIntroDust());			bitmapDust.smoothing = true;			this.circularLoader = new CircularLoader(Number(this.config.loader.@radius.toString()) , bitmapDust , uint(this.config.loader.@background.toString()) , int(this.config.loader.@blur.toString()));			this.addChild(this.circularLoader);			this.circularLoader.resizeLoader(stage.stageWidth , stage.stageHeight , 0);		}		/**		 * Setups the main menu		 * @return	void		 */		private function setupMainMenu():void		{			// Builds the menu items			var menuItems:Array = new Array();			var submenuItems:Array = new Array();			var itemIndex:int = 0;			for each(var menuItem:XML in this.config.main_menu.items.item)			{				var callback:Function;				// Creates a submenu if needed				if (menuItem.link.length() > 0)				{					callback = this.switchSubmenu;					var submenuName:String = menuItem.@callback.toString();					submenuItems [submenuName] = new Submenu(menuItem , new Bitmap(new GenericBlackDust()));				}				else					callback = this.navigationController;				var theItem:MainMenuItem = new MainMenuItem(itemIndex , menuItem , callback , int(this.config.main_menu.@radius.toString()) , new Bitmap(new GenericBlackDust()) , new Bitmap(new GenericWhiteDust()));				menuItems.push(theItem);				itemIndex ++;			}			// Builds the menu			this.mainMenu = new MainMenu(menuItems , submenuItems , new GenericBlackDust() , new BitmapLines() , this.config.main_menu);			this.addChild(this.mainMenu);			this.mainMenu.resizeMenu(stage.stageWidth , stage.stageHeight , 0);		}		/**		 * Setups the contact page		 * @return	void		 */		private function setupContactPage()		{			this.contactPage = new ContactPage(this.config.pages.page.(@id == 'contact') , this.navigationController , this.siteURL);			this.addChild(this.contactPage);			this.contactPage.resizeElement(stage.stageWidth , stage.stageHeight , 0);		}		/**		 * Setups the about page		 * @return	void		 */		private function setupAboutPage()		{			this.aboutPage = new AboutPage(this.config.pages.page.(@id == 'about') , this.navigationController);			this.addChild(this.aboutPage);			this.aboutPage.resizeElement(stage.stageWidth , stage.stageHeight , 0);		}		/**		 * Loads the parallax object		 * @return	void		 */		private function loadParallax():void		{			this.parallax.addEventListener(Parallax.BITMAPS_ERROR , parallaxError);			this.parallax.addEventListener(Parallax.BITMAPS_LOADING , parallaxLoading);			this.parallax.addEventListener(Parallax.OBJECT_READY , parallaxLoaded);			this.circularLoader.displayLoader(this.parallax.loadPictures , Number(this.config.loader.@display_speed.toString()) , Number(this.config.loader.@display_delay.toString()));		}				/**		 * Parallax error		 * @param	Event	evt		the event		 * @return	void		 **/		private function parallaxError(evt:Event):void { Main.debug('An error occurred when loading the parallax object'); }		/**		 * Parallax loading		 * @param	ParallaxLoader	evt		the event with the loaded percentage		 * @return	void		 **/		private function parallaxLoading(evt:ParallaxLoaderEvent):void		{			this.circularLoader.updateLoader(evt.getLoadedPercentage());		}		/**		 * Parallax loaded: prepares the scene and hides the loader		 * @param	Event	evt		the event		 * @return	void		 **/		private function parallaxLoaded(evt:Event):void		{			stage.addEventListener(MouseEvent.MOUSE_MOVE , moveParallax);			this.parallax.resizeLayers(stage.stageWidth , stage.stageHeight , this.resizeSpeed);			this.parallax.moveLayers(this.currentMouseX , this.currentMouseY , stage.stageWidth , stage.stageHeight , 0);			this.weft.displayWeft();			this.circularLoader.displayBackground(enableNavigation , Number(this.config.loader.@hide_speed_menu.toString()) , loaderMasked , Number(this.config.loader.@hide_speed.toString()));		}				/**		 * Enables the navigation		 * @return	void		 */		public function enableNavigation():void		{			SWFAddress.addEventListener(SWFAddressEvent.CHANGE , navigate);		}				/**		 * The loader is masked: removes it and display the right object (main menu or content page)		 * @return	void		 */		public function loaderMasked():void		{			this.removeChild(this.circularLoader);			this.circularLoader = null;		}				/**		 * Navigation controller called to manually enter a destination from the children objects		 * @param	String	controller	the controller		 * @return	void		 */		public function navigationController(controller:String = '/'):void		{			Main.debug('Navigation controller called with parameter: "' + controller + '"');			SWFAddress.setValue(controller);		}				/**		 * Navigates: masks the current context and displays the new one depending on the given URL (uses values like the following: #/contact)		 * @param	SWFAddressEvent		evt		the event		 * @return	void		 */		public function navigate(evt:SWFAddressEvent):void		{			var path:String = SWFAddress.getValue();			Main.debug('Navigation detected from SWFAddress with value: "' + path + '"');			var displayCallback:Function;			var newContext:Object;			// Contact page			if (path == '/contact')			{				displayCallback = this.contactPage.displayElement;				newContext = this.contactPage;			}			// About page			else if (path == '/about')			{				displayCallback = this.aboutPage.displayElement;				newContext = this.aboutPage;			}			// Menu or page not found			else			{				displayCallback = this.mainMenu.displayMenu;				newContext = this.mainMenu;			}						// Hides the current object and displays the new one when the animation is done			if (currentContext != null)				currentContext.hideElement(displayCallback);			else				displayCallback();			// Saves the current context			this.currentContext = newContext;		}				/**		 * Tells the main menu to display/hide a submenu (identified by its name - defined in the XML config file)		 * @param	String	submenu	the submenu		 * @return	void		 */		public function switchSubmenu(submenu:String):void		{			this.mainMenu.switchSubmenu(submenu);		}				/**		 * Calculates the new position of the parallax layers		 * @param	MouseEvent	evt		the event		 * @return 	void		 */		public function moveParallax(evt:MouseEvent):void		{			this.parallax.moveLayers(evt.stageX , evt.stageY , stage.stageWidth , stage.stageHeight);		}				/**		 * Called when resizing the stage		 * @param	event	evt		the resize event		 * @return	void		 */		public function handleResize(evt:Event = null):void		{			if (this.weft != null)				this.weft.resizeWeft(stage.stageWidth , stage.stageHeight , this.resizeSpeed);			if (this.circularLoader != null)				this.circularLoader.resizeLoader(stage.stageWidth , stage.stageHeight , this.resizeSpeed);			if (this.parallax != null)			{				this.parallax.resizeLayers(stage.stageWidth , stage.stageHeight , this.resizeSpeed);				this.parallax.moveLayers(stage.stageWidth / 2 , stage.stageHeight / 2 , stage.stageWidth , stage.stageHeight);			}			if (this.mainMenu != null)				this.mainMenu.resizeMenu(stage.stageWidth , stage.stageHeight , this.resizeSpeed);			if (this.contactPage != null)				this.contactPage.resizeElement(stage.stageWidth , stage.stageHeight , this.resizeSpeed);			if (this.aboutPage != null)				this.aboutPage.resizeElement(stage.stageWidth , stage.stageHeight , this.resizeSpeed);					}		/**		 * Saves the mouse position		 * @param	MouseEvent	evt		the event		 * @return	void		 */		private function saveMousePosition(evt:MouseEvent):void		{			this.currentMouseX = evt.stageX;			this.currentMouseY = evt.stageY;		}		/**		 * Displays debug data		 * @param	string	string	the string to be displayed		 */		public static function debug(string:String):void		{			trace(string);		}		/**		 * Converts a String to Boolean		 * @param	bool	String	the value (true OR 1 , false OR 0)		 * @return	Boolean		 */		public static function toBoolean(bool:String):Boolean		{			return (bool == 'true' || bool == '1');		}				/**		 * Returns a random value used when calling external urls		 * @return	String		 */		public static function getRandomValue():String		{			return Math.floor(Math.random() * 100000) + '';		}	}}