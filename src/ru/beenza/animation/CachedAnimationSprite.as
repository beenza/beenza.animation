package ru.beenza.animation {
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.PixelSnapping;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class CachedAnimationSprite extends Sprite {
		
		private var mc:MovieClip;
		private var bmp:Bitmap;
		private var frameBounds:Vector.<Rectangle>;
		private var bufferFrames:Vector.<BitmapData>;
		
		private var _currentFrame:uint;
		private var _totalFrames:uint;
		private var _flipX:Boolean;
		
		/**
		 * Create Sprite with Bitmap and Vector of cached BitmapData from source MovieClip.
		 * @param mc MovieClip for caching
		 */
		public function CachedAnimationSprite(mc:MovieClip) {
			super();
			this.mc = mc;
			init();
		}
		
		private function init():void {
			_totalFrames = mc.totalFrames;
			clearCache();
			
			// create visible part
			bmp = new Bitmap(null, PixelSnapping.AUTO, true);
			addChild(bmp);
			
			// waiting added to stage
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			// render first frame
			render();
		}
		
		private function clearCache():void {
			frameBounds = new Vector.<Rectangle>(totalFrames, true);
			bufferFrames = new Vector.<BitmapData>(totalFrames, true);
		}
		
		/**
		 * Cache specific frame.
		 * @param frame num frame in MoveClip, first frame is zero
		 */		
		private function cacheFrame(frame:uint):void {
			if (bufferFrames[frame]) return;
			
			var bounds:Rectangle;
			var bmd:BitmapData;
			const m:Matrix = new Matrix();
			
			mc.gotoAndStop(frame + 1);
			
			const toScaleX:Number = mc.scaleX;
			const toScaleY:Number = mc.scaleY;
			
			bounds = mc.getBounds(mc);
			bounds.x *= toScaleX;
			bounds.y *= toScaleY;
			bounds.width *= toScaleX;
			bounds.height *= toScaleY;
			
			const xOffset:Number = bounds.x - Math.floor(bounds.x);
			const yOffset:Number = bounds.y - Math.floor(bounds.y);
			bounds.x = Math.round( bounds.x - xOffset );
			bounds.y = Math.round( bounds.y - yOffset );
			bounds.width = Math.abs( Math.ceil( bounds.width + xOffset ) );
			bounds.height = Math.abs( Math.ceil( bounds.height + yOffset ) );
			frameBounds[frame] = bounds;
			
			// set stage quality to best for better caching
			var prevQuality:String;
			if (stage && stage.quality != StageQuality.BEST) {
				prevQuality = stage.quality;
				stage.quality = StageQuality.BEST;
			}
			
			if (stage && bounds.width > 0 && bounds.height > 0) {
				bmd = new BitmapData(bounds.width, bounds.height, true, 0);
				m.scale(toScaleX, toScaleY);
				m.translate(-bounds.x, -bounds.y);
				bmd.draw(mc, m);
			}
			bufferFrames[frame] = bmd;
			
			// return back stage quality
			if (prevQuality && stage) {
				stage.quality = prevQuality;
			}
		}
		
		/**
		 * Render current frame.
		 */
		private function render():void {
			if (!bufferFrames) return;
			
			if (!bufferFrames[currentFrame]) {
				cacheFrame(currentFrame);
			}
			
			const bounds:Rectangle = frameBounds[currentFrame];
			bmp.bitmapData = bufferFrames[currentFrame];
			bmp.x = bounds.x;
			bmp.y = bounds.y;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Public Functions
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Go to next frame.
		 */
		public function nextFrame():void {
			currentFrame = (currentFrame + 1) % totalFrames;
		}
		
		/**
		 * Scale MovieClip
		 * @param x scaleX
		 * @param y scaleY
		 */
		public function scale(sx:Number, sy:Number):void {
			if (Math.abs(sx) == mc.scaleX && Math.abs(sy) == mc.scaleY) return;
			clearCache();
			mc.scaleX = Math.abs(sx);
			mc.scaleY = Math.abs(sy);
		}
		
		public function destroy():void {
			if (hasEventListener(Event.ADDED_TO_STAGE)) {
				removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			}
			mc = null;
			if (bmp && contains(bmp)) {
				removeChild(bmp);
				bmp.bitmapData = null;
				bmp = null
			}
			frameBounds = null;
			for each (var bmd:BitmapData in bufferFrames) {
				if (bmd) bmd.dispose();
			}
			bufferFrames = null;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Getters / Setters
		//
		//--------------------------------------------------------------------------
		
		public function get currentFrame():uint { return _currentFrame };
		public function set currentFrame(value:uint):void {
			if (currentFrame == value || value > totalFrames - 1) return;
			_currentFrame = value;
			render();
		}
		
		public function get totalFrames():uint { return _totalFrames };
		
		public function get flipX():Boolean { return _flipX };
		public function set flipX(value:Boolean):void {
			_flipX = value;
			scaleX = Math.abs(scaleX) * (value ? -1 : 1);
		}
		
	}
	
}