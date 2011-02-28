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
	import flash.utils.Dictionary;
	
	public class CachedAnimationSprite extends Sprite {
		
		private var src:MovieClip;
		private var bmp:Bitmap;
		private var frames:Vector.<FrameData>;
		private var checkDuplicate:Boolean;
		
		private var _currentFrame:uint;
		private var _totalFrames:uint;
		private var _flipX:Boolean;
		
		/**
		 * Create Sprite with Bitmap and Vector of cached BitmapData from source MovieClip.
		 * @param src MovieClip for caching
		 * @param checkDuplicate check duplicate previous frame when rendering
		 */
		public function CachedAnimationSprite(src:MovieClip, checkDuplicate:Boolean=false) {
			super();
			this.src = src;
			this.checkDuplicate = checkDuplicate;
			init();
		}
		
		private function init():void {
			_totalFrames = src.totalFrames;
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
			frames = new Vector.<FrameData>(totalFrames, true);
		}
		
		/**
		 * Cache specific frame.
		 * @param frame num frame in MoveClip, first frame is zero
		 */		
		private function cacheFrame(frame:uint):void {
			if (frames[frame]) return;
			
			src.gotoAndStop(frame + 1);
			
			// check changes
			if (checkDuplicate) {
				var i:int, mc:MovieClip, dict:Dictionary;
				if (frame > 0 && frames && frames[frame - 1] && frames[frame - 1].dictMatrixes) {
					var m1:Matrix, m2:Matrix;
					dict = frames[frame - 1].dictMatrixes;
					for (i = 0; i < src.numChildren; ++i) {
						mc = src.getChildAt(i) as MovieClip;
						if (mc in dict) {
							m1 = mc.transform.matrix;
							m2 = dict[mc];
							if (m1.a != m2.a || m1.b != m2.b || m1.c != m2.c || m1.d != m2.d || m1.tx != m2.tx || m1.ty != m2.ty) {
								break;
							}
						}
					}
					if (i == src.numChildren) {
						frames[frame] = frames[frame - 1];
						return;
					}
				}
			}
			
			const toScaleX:Number = src.scaleX;
			const toScaleY:Number = src.scaleY;
			
			const bounds:Rectangle = src.getBounds(src);
			const p:Point = new Point(bounds.x * toScaleX, bounds.y * toScaleY);
			var w:Number = bounds.width * toScaleX;
			var h:Number = bounds.height * toScaleY;
			
			const xOffset:Number = p.x - Math.floor(p.x);
			const yOffset:Number = p.y - Math.floor(p.y);
			p.x = Math.round( p.x - xOffset );
			p.y = Math.round( p.y - yOffset );
			w = Math.abs( Math.ceil( w + xOffset ) );
			h = Math.abs( Math.ceil( h + yOffset ) );
			
			// set stage quality to best for better caching
			var prevQuality:String;
			if (stage && (stage.quality != StageQuality.HIGH || stage.quality != StageQuality.BEST)) {
				prevQuality = stage.quality;
				stage.quality = StageQuality.HIGH;
			}
			
			if (stage && bounds.width > 0 && bounds.height > 0) {
				const bmd:BitmapData = new BitmapData(w, h, true, 0);
				const m:Matrix = new Matrix();
				m.scale(toScaleX, toScaleY);
				m.translate(-p.x, -p.y);
				bmd.draw(src, m);
				
				const fd:FrameData = new FrameData();
				fd.p = p;
				fd.bmd = bmd;
				
				if (checkDuplicate) {
					dict = new Dictionary();
					for (i = 0; i < src.numChildren; ++i) {
						mc = src.getChildAt(i) as MovieClip;
						if (!mc) continue;
						dict[mc] = mc.transform.matrix;
					}
					fd.dictMatrixes = dict;
				}
				
				frames[frame] = fd;
			}
			
			// return back stage quality
			if (prevQuality && stage) {
				stage.quality = prevQuality;
			}
		}
		
		/**
		 * Render current frame.
		 */
		private function render():void {
			if (!frames) return;
			
			var fd:FrameData = frames[currentFrame];
			if (!fd) {
				cacheFrame(currentFrame);
				fd = frames[currentFrame];
			} else {
				fd.dictMatrixes = null;
			}
			
			bmp.bitmapData = fd.bmd;
			bmp.x = fd.p.x;
			bmp.y = fd.p.y;
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
			if (Math.abs(sx) == src.scaleX && Math.abs(sy) == src.scaleY) return;
			clearCache();
			src.scaleX = Math.abs(sx);
			src.scaleY = Math.abs(sy);
		}
		
		public function destroy():void {
			if (hasEventListener(Event.ADDED_TO_STAGE)) {
				removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			}
			src = null;
			if (bmp && contains(bmp)) {
				removeChild(bmp);
				bmp.bitmapData = null;
				bmp = null
			}
			for each (var fd:FrameData in frames) {
				if (!fd) continue;
				fd.p = null;
				if (fd.bmd) {
					fd.bmd.dispose();
					fd.bmd = null;
				}
				fd.dictMatrixes = null;
			}
			frames = null;
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

import flash.display.BitmapData;
import flash.geom.Point;
import flash.utils.Dictionary;

class FrameData {
	
	public var p:Point;
	public var bmd:BitmapData;
	public var dictMatrixes:Dictionary;
	
}
