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
			frameBounds = new Vector.<Rectangle>(totalFrames, true);
			bufferFrames = new Vector.<BitmapData>(totalFrames, true);
			
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
			
			bounds = mc.getBounds(mc);
			const xOffset:Number = bounds.x - Math.floor(bounds.x);
			const yOffset:Number = bounds.y - Math.floor(bounds.y);
			bounds.x = Math.round( bounds.x - xOffset );
			bounds.y = Math.round( bounds.y - yOffset );
			bounds.width = Math.ceil( bounds.width + xOffset );
			bounds.height = Math.ceil( bounds.height + yOffset );
			frameBounds[frame] = bounds;
			
			var prevQuality:String;
			if (stage && stage.quality != StageQuality.BEST) {
				prevQuality = stage.quality;
				stage.quality = StageQuality.BEST;
			}
			
			bmd = new BitmapData(bounds.width, bounds.height, true, 0);
			m.tx = -bounds.x;
			m.ty = -bounds.y;
			bmd.draw(mc, m);
			bufferFrames[frame] = bmd;
			
			if (prevQuality && stage) {
				stage.quality = prevQuality;
			}
		}
		
		/**
		 * Render current frame.
		 */
		private function render():void {
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
		
	}
	
}