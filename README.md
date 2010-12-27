AS3CacheAnimation Library
=========================

AS3CacheAnimation is a flash library, for cache animation in MovieClip.
Source code is available at http://github.com/beenza/as3cacheanimation

Usage
=====
	private var cachedMovieClip:CachedAnimationSprite;
	...
	var mc:MovieClip = new MyPerson();
	var mapFrames:Vector.<uint> = Vector.<uint>([0, 1, 2, 3, 4]);
	cachedMovieClip = new CachedAnimationSprite(mc, mapFrames);
	...
	private function onEnterFrame(event:Event) {
		cachedMovieClip.nextMapFrame();
	}

Compiling
=========
1. get FlexSDK 4.1 or higher http://opensource.adobe.com/wiki/display/flexsdk/Download+Flex+4
2. change FLEX_HOME in build.properties
3. ant main

Licensing
=========

AS3CacheAnimation is distributed under MIT License. The MIT License is included in this source tree in the file LICENSE.