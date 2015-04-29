﻿package js{		import flash.display.MovieClip;	import flash.events.Event;	import flash.display.Bitmap;	import flash.events.MouseEvent;	import flash.filters.DropShadowFilter;	import flash.filters.BlurFilter;	import com.greensock.TweenLite;	import com.greensock.easing.Back;		public class AboutPage extends MovieClip	{		private var theShadow:DropShadowFilter;		private var theBlur:BlurFilter;		private var theBlurAmount:int;		private var closeCallback:Function;		private var XMLParameters:XMLList;		private var theWidth:int;		private var sectionSpeed:Number;			/**		 * Constructor.		 * @param	XMLList		parameters			the page parameters (XML node)		 * @param	Function	closeCallback	the callback when closing the element		 */		public function AboutPage(parameters:XMLList , closeCallback:Function)		{			// Setups vars			this.closeCallback = closeCallback;			this.theShadow = new DropShadowFilter(0 , 0 , 0x000000 , Number(parameters.@shadow_alpha.toString()) , int(parameters.@shadow_radius.toString()) , int(parameters.@shadow_radius.toString()));			this.sectionSpeed = Number(parameters.@section_speed.toString());			this.XMLParameters = parameters;			// Stage			if (stage)				this.addedToStage(null);			else				this.addEventListener(Event.ADDED_TO_STAGE , this.addedToStage);		}		/**		 * Fired when added to stage		 * @param	Event	evt		the event		 * @return	void		 */		private function addedToStage(evt:Event = null):void		{			if (evt != null)				evt.target.removeEventListener(Event.ADDED_TO_STAGE , this.addedToStage);			var sectionX:int = 0;			var sectionMargin:int = int(this.XMLParameters.@margin.toString());			for each(var sectionParameters:XML in this.XMLParameters.section)			{				var radius:int = int(sectionParameters.@radius.toString());				var section:AboutSection = new AboutSection(sectionParameters , radius , closeFromSection);				this.addChild(section);				section.x = sectionX + radius;				sectionX += (radius * 2) + sectionMargin;			}			this.theWidth = (this.numChildren * (radius * 2)) + ((this.numChildren - 1) * sectionMargin)					}				/**		 * Displays the page		 * @param	Function	callback	an optional callback		 * @return	void		 */		public function displayElement(callback:Function = null):void		{			// Tweens sections			this.visible = true;			var theDelay:Number = 0;			for(var index:int = 0; index < this.numChildren; index++)			{				var section:AboutSection = AboutSection(this.getChildAt(index));				section.displaySection(this.sectionSpeed , theDelay);				theDelay += this.sectionSpeed / 2;			}			if (callback != null)				TweenLite.delayedCall(theDelay , callback);		}				/**		 * Hides the page		 * @param	Function	callback	an optional callback		 * @return	void		 */		public function hideElement(callback:Function = null):void		{			var theDelay:Number = 0;			for(var index:int = 0; index < this.numChildren; index++)			{				var section:AboutSection = AboutSection(this.getChildAt(index));				section.hideSection(this.sectionSpeed , theDelay);				theDelay += this.sectionSpeed / 2;			}			if (callback != null)				TweenLite.delayedCall(theDelay , elementHidden , [callback]);		}				/**		 * Called when the page is hidden		 * @param	Function	callback	the callback		 * @return	void		 */		private function elementHidden(callback:Function):void		{			this.visible = false;			if (callback != null)				callback();		}				/**		 * Hides the page when clicking the "return" button from a section		 * @return	void		 */		public function closeFromSection():void		{			this.hideElement(this.closeCallback);		}				/**		 * Resizes the page		 * @param	int		contextWidth	the width		 * @param	int		contextHeight	the height		 * @param	Number	speed			the speed		 * @return	void		 */		public function resizeElement(contextWidth:int , contextHeight:int , speed:Number):void		{			var theX:Number = int((contextWidth - this.theWidth) / 2) + .5; // Ugly hack to prevent blurry text			var theY:Number = int(contextHeight / 2) + .5;			TweenLite.to(this , speed , {x:theX , y:theY});		}	}}