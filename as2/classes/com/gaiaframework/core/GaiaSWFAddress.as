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

import com.gaiaframework.events.GaiaSWFAddressEvent;
import com.gaiaframework.utils.ObservableClass;
import com.gaiaframework.assets.PageAsset;
import com.gaiaframework.events.GaiaEvent;
import com.gaiaframework.debug.GaiaDebug;
import com.gaiaframework.core.BranchTools;
import com.gaiaframework.core.SiteModel;
import com.asual.swfaddress.*;
import mx.utils.Delegate;

// This class uses SWFAddress 2.2 written by Rostislav Hristov
// More info: http://www.asual.com/SWFAddress/

class com.gaiaframework.core.GaiaSWFAddress extends ObservableClass
{
	private static var _deeplink:String = "";	
	private var _value:String = "/";	
	private var isInternal:Boolean = false;
	public static var isSinglePage:Boolean = false;
	
	private static var rootBranch:String;
	
	private var lastValidBranch:String;
	private var lastFullBranch:String;
	
	private static var _instance:GaiaSWFAddress;
	
	private function GaiaSWFAddress() 
	{
		super();
	}
	public static function birth(s:String):Void
	{
		rootBranch = s;
		if (_instance == null) _instance = new GaiaSWFAddress();
	}
	public static function get instance():GaiaSWFAddress
	{
		return _instance;
	}
	public static function get deeplink():String
	{
		return _deeplink;
	}	
	public function init():Void 
	{
		SWFAddress.addEventListener(SWFAddressEvent.CHANGE, Delegate.create(this, onChange));
		SWFAddress.setHistory(false);
		var v:String = SWFAddress.getValue();
		if (v == "/") v = insertStrictSlashes();
		if (v != "/") SWFAddress.setValue(v);
	}
	public function onGoto(event:GaiaEvent):Void
	{
		if (!event.external && lastFullBranch != event.fullBranch)
		{
			isInternal = true;
			var strictString:String;
			if (SiteModel.routing)
			{
				_deeplink = event.fullBranch.substring(event.validBranch.length, event.fullBranch.length);
				strictString = insertStrictSlashes((!isSinglePage ? BranchTools.getPage(event.validBranch).route : "") + _deeplink);
			}
			else
			{
				strictString = insertStrictSlashes(event.fullBranch.split("/").slice(1).join("/"));
			}
			if (SiteModel.title.length > 0 && lastValidBranch != event.validBranch) SWFAddress.setTitle(SiteModel.title.split("%PAGE%").join(BranchTools.getPage(event.validBranch).title));
			lastValidBranch = event.validBranch;
			lastFullBranch = event.fullBranch;
			SWFAddress.setValue(strictString);
			isInternal = false;
		}
	}
	public function onChange(event:SWFAddressEvent):Void 
	{
		_value = stripStrictSlashes(event.value);
		dispatchDeeplink();
		if (!isInternal)
		{
			if (_value.length > 1) 
			{
				if (SiteModel.routing)
				{
					var validRoute:String = validate(_value);
					if (validRoute.length > 0) dispatchGoto(SiteModel.routes[validRoute] + _deeplink);
					else if (isSinglePage) dispatchGoto(SiteModel.indexID + _deeplink);
				}
				else 
				{
					var validBranch:String = validate(_value);
					dispatchGoto(validBranch);
				}
			} 
			else 
			{
				if (rootBranch.length > 0)
				{
					dispatchGoto(rootBranch);
				}
				else
				{
					dispatchGoto(SiteModel.indexID);
				}
			}
		}
	}
	private function dispatchGoto(branch:String):Void
	{
		dispatchEvent(new GaiaSWFAddressEvent(GaiaSWFAddressEvent.GOTO, this, _deeplink, branch));
	}
	private function dispatchDeeplink():Void 
	{
		_deeplink = "";
		var validated:String = validate(_value);
		var validBranch:String = SiteModel.routes[validated] || "";
		if (validated.length > 0 || isSinglePage) _deeplink = _value.substring(validated.length, _value.length);
		if (isSinglePage && _deeplink.length > 0) _deeplink = "/" + _deeplink;
		if (_deeplink.length > 0) GaiaDebug.log("deeplink", _deeplink);
		dispatchEvent(new GaiaSWFAddressEvent(GaiaSWFAddressEvent.DEEPLINK, this, _deeplink, validBranch));
	}
	private function validate(str:String):String
	{
		var val:String = stripStrictSlashes(str);
		if (SiteModel.routing)
		{
			return BranchTools.getValidRoute(val);
		}
		else
		{
			return BranchTools.getFullBranch(val).split("/").slice(1).join("/");
		}
	}
	private function stripStrictSlashes(str:String):String
	{
		if (str == undefined || str.length == 0) return "";
		if (str.charAt(0) == "/") str = str.substr(1);
		if (str.charAt(str.length - 1) == "/") str = str.substr(0, str.length - 1);
		return str;
	}
	private function insertStrictSlashes(str:String):String
	{
		if (str == undefined || str.length == 0) return "/";
		if (str.charAt(0) != "/") str = "/" + str;
		return str;
	}
}