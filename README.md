BeenzaAnimation Library
=========================

BeenzaAnimation is a flash library, for cache animation in MovieClip.
Source code is available at http://github.com/beenza/beenza.animation

Usage
=====
	private var cachedMovieClip:CachedAnimationSprite;
	...
	var mc:MovieClip = new MyPerson();
	cachedMovieClip = new CachedAnimationSprite(mc);
	...
	private function onEnterFrame(event:Event) {
		cachedMovieClip.nextFrame();
	}

Compiling
=========
1. get FlexSDK 4.1 or higher http://opensource.adobe.com/wiki/display/flexsdk/Download+Flex+4
2. change FLEX_HOME in build.properties
3. ant main

Licensing
=========

BeenzaAnimation is distributed under MIT License. The MIT License is included in this source tree in the file LICENSE.