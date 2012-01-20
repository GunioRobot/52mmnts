﻿package com.fiftytwomoments.ui {	import com.fiftytwomoments.DisplayContents;	import com.fiftytwomoments.services.MomentsData;	import com.greensock.loading.ImageLoader;	import com.greensock.loading.LoaderMax;	import com.greensock.plugins.TransformAroundCenterPlugin;	import com.greensock.plugins.TransformAroundPointPlugin;	import com.greensock.plugins.TweenPlugin;	import com.nanaimostudio.utils.TraceUtility;	import flash.display.Sprite;	import flash.events.MouseEvent;	import flash.geom.Point;	import org.casalib.display.CasaBitmap;	import org.casalib.display.CasaMovieClip;	import org.casalib.display.CasaSprite;	import flash.text.TextField;	//import mx.core.BitmapAsset;	import com.greensock.*;	import com.greensock.easing.*;		/**	 * ...	 * @author Boon Chew	 */	public class PhotoContent extends CasaMovieClip	{		public var captionTitle:TextField;		public var captionText:TextField;				public var photoTitle:TextField;		public var photo:CasaSprite;		public var details:PhotoDetails;		public var background:Sprite;				private var bitmap:CasaBitmap;		private var _week:int;		private var _interactionDelegate:Object;		private var _useDefaultText:Boolean;		private var imageLoader:ImageLoader;		private var flipSpeed:Number = 0.3;		private var timeline:TimelineMax;		private var isShowingDetails:Boolean;				public function PhotoContent() 		{			details = new PhotoDetails();			details.name = "details";			details.graphics.beginFill(0xcecece);			details.graphics.drawRect(-320, -212, 640, 424);			details.graphics.endFill();			addChild(details);						details.rotationY = -90;			details.alpha = 0;						photo = new CasaSprite();			photo.name = "photo";			//photo.x = -320;			//photo.y = -212;			addChild(photo);						captionTitle.text = "";			captionText.text = "";						this.mouseChildren = false;			this.interactionEnabled = false;						TweenPlugin.activate([TransformAroundPointPlugin]);			timeline = new TimelineMax( { paused:true } );			timeline.append(TweenMax.to(photo, flipSpeed, { rotationY:90, visible:false }))			timeline.append(TweenMax.to(details, 0, { alpha:1, immediateRender:false }))			timeline.append(TweenMax.to(details, flipSpeed, { rotationY: 0 }))		}				public function set useDefaultText(value:Boolean):void		{			_useDefaultText = value;		}				private function onClick(e:MouseEvent):void 		{			TraceUtility.debug(this, "target: " + e.target);			//TraceUtility.debug(this, "onClick " + _interactionDelegate + " " + Boolean(_interactionDelegate is DisplayContents) + " " + _interactionDelegate.hasOwnProperty("onPhotoContentClicked"));			if (_interactionDelegate != null)			{				if (_interactionDelegate.hasOwnProperty("onPhotoContentClicked"))				{					_interactionDelegate.onPhotoContentClicked(this);				}			}		}				public function toggleDetails():void		{			if (isShowingDetails)			{				isShowingDetails = false;				timeline.tweenTo(0);			}			else			{				isShowingDetails = true;				timeline.tweenTo(timeline.duration);			}		}				public function set interactionEnabled(value:Object):void 		{			this.buttonMode = value;			this.mouseEnabled = value;						if (value)			{				this.addEventListener(MouseEvent.CLICK, onClick);			}			else			{				this.removeEventListener(MouseEvent.CLICK, onClick);			}		}				public function set interactionDelegate(value:Object):void		{			_interactionDelegate = value;		}				public function setText(value:String):void		{			photoTitle.visible = true;			photoTitle.text = value;		}				public function setPhoto(value:String, week:int = 1, caption:String = "", showCaption:Boolean = true):void		{			//bitmap = new CasaBitmap(value.bitmapData);			//bitmap.x = -bitmap.width * 0.5;			//bitmap.y = -bitmap.height * 0.5;			//photo.addChild(bitmap);			TraceUtility.debug(this, "loading  " + value + " for " + week);			var fullPath:String = "http://52mmnts.me/static/web/html/" + value;			imageLoader = new ImageLoader(fullPath, { x: -320, y: -212, width:640, height:424, container:photo, scaleMode:"proportionalInside", bgColor:0xFFFFFF } );			imageLoader.load(true);			photoTitle.visible = false;						captionTitle.text = "Moment " + String(week) + " //";						if (showCaption)			{				//TODO: Server-side driven				//if (caption == "")				//{					//caption = "It’s time to act, to learn and grow—to find yourself, and figure out where it is you want to go. Regroup, refocus, and share it with us.";				//}							captionText.text = caption;			}			else			{				captionTitle.text = "";				captionText.text = "";			}						background.visible = false;			photoTitle.visible = false;		}				public function removePhoto():void		{			photo.removeAllChildren(true);			photoTitle.visible = true;		}				public function hasPhoto():Boolean		{			return photo.numChildren > 0;		}				public function set week(value:int):void 		{			_week = value;						if (_useDefaultText)			{				photoTitle.text = "moment " + _week;			}			else			{				photoTitle.text = "";			}		}				public function get week():int 		{			return _week;		}	}}