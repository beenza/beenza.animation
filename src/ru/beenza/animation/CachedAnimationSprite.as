package ru.beenza.animation {
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.PixelSnapping;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class CachedAnimationSprite extends Sprite {
		
		private var mc:MovieClip;
		private var bmp:Bitmap;
		private var bmd:BitmapData;
		private var buffer:BitmapData;
		private var frameBounds:Vector.<Rectangle>;
		private var bufferFrames:Vector.<BitmapData>;
		
		private var mapFrames:Vector.<uint>;
		private var currentMapFrameIndex:uint;
		
		private var _currentFrame:uint;
		private var _totalFrames:uint;
		
		/**
		 * Create Sprite with Bitmap and vector of cached BitmapData from MovieClip
		 * @param mc MovieClip for caching
		 * @param mapFrames map of frames for easy to manage a sequence of frames
		 */
		public function CachedAnimationSprite(mc:MovieClip, mapFrames:Vector.<uint> = null) {
			super();
			this.mc = mc;
			this.mapFrames = mapFrames;
			init();
		}
		
		private function init():void {
			var bounds:Rectangle;
			var bmd:BitmapData;
			const m:Matrix = new Matrix();
			
			_totalFrames = mc.totalFrames;
			frameBounds = new Vector.<Rectangle>(totalFrames, true);
			bufferFrames = new Vector.<BitmapData>(totalFrames, true);
			
			// caching frames
			for (var i:uint = 0; i < totalFrames; ++i) {
				mc.gotoAndStop(i + 1);
				
				bounds = mc.getBounds(mc);
				bounds.width = Math.ceil(bounds.width);
				bounds.height = Math.ceil(bounds.height);
				frameBounds[i] = bounds;
				
				bmd = new BitmapData(bounds.width, bounds.height, true, 0);
				m.tx = -bounds.x;
				m.ty = -bounds.y;
				bmd.draw(mc, m);
				bufferFrames[i] = bmd;
			}
			
			mc = null;
			
			// create visible part
			bmp = new Bitmap(null, PixelSnapping.AUTO, true);
			addChild(bmp);
			
			// render first frame
			render();
		}
		
		/**
		 * Render current frame
		 */
		private function render():void {
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
		 * Go to real next frame
		 */
		public function nextFrame():void {
			currentFrame = (currentFrame + 1) % totalFrames;
		}
		
		/**
		 * Go to next frame of map (Looped). If map not set, then nextFrame() used.
		 */
		public function nextMapFrame():void {
			if (mapFrames) {
				currentMapFrameIndex = (currentMapFrameIndex + 1) % mapFrames.length;
				currentFrame = mapFrames[currentMapFrameIndex];
			} else {
				nextFrame();
			}
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