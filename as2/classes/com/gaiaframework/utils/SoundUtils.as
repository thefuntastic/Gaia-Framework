﻿/*****************************************************************************************************
* Gaia Framework for Adobe Flash ©2007-2009
* Written by: Steven Sacks
* email: stevensacks@gmail.com
* blog: http://www.stevensacks.net/
* forum: http://www.gaiaflashframework.com/forum/
* wiki: http://www.gaiaflashframework.com/wiki/
* 
* By using the Gaia Framework, you agree to keep the above contact information in the source code.
* 
* Gaia Framework for Adobe Flash is ©2007-2009 Steven Sacks and is released under the MIT License:
* http://www.opensource.org/licenses/mit-license.php 
*****************************************************************************************************/

import gs.easing.Linear;
import gs.TweenLite;

class com.gaiaframework.utils.SoundUtils
{
	public static function fadeTo(target:Object, volume:Number, duration:Number, onComplete:Function):Void
	{
		TweenLite.to(target, duration, {volume:volume, ease:Linear.easeNone, onComplete:onComplete, overwrite:false});
	}
	public static function panTo(target:Object, pan:Number, duration:Number, onComplete:Function):Void
	{
		TweenLite.to(target, duration, {pan:pan, ease:Linear.easeNone, onComplete:onComplete, overwrite:false});
	}
}