//
//  JSKit.js
//  GameKuaifa
//
//  Created by supertext on 15/4/30.
//  Copyright (c) 2015年 kuaifa. All rights reserved.
//


var JSKit = JSKit || {};
JSKit.VERSION = "1.0";
//--------------base ------------------------------
JSKit.JSObject = function() {
	if (this.init) {
		this.init.apply(this, arguments);
	};
};
JSKit.JSObject.isKindOfClass = function(superClass) {
	if (superClass===this)
	{
		return true;
	}
	else
	{
		return false;
	}
}; 
JSKit.JSObject.superClass = function() {
	return null;
};
JSKit.JSObject.prototype = new Object();
JSKit.JSObject.prototype.init = function(){};
JSKit.JSObject.prototype.Class = function(){
	return this.constructor;
};
JSKit.JSObject.extend = function() {};
( function() {
		var ClassManager = {
			id : 0,

			instanceId : 0,

			getNewClassID : function() {
				return this.id++;
			},

			getNewInstanceId : function() {
				return this.instanceId++;
			}
		};
		JSKit.classForid = function (id) {
			if (id){
				return ClassManager[id];
			}
		};
		var rootClassid=ClassManager.getNewClassID();
		JSKit.JSObject.classid= rootClassid;
		ClassManager[rootClassid] = JSKit.JSObject;
		JSKit.JSObject.extend = function(prop) {
			var _super = this.prototype;
			initializing = true;
			var prototype = Object.create(_super);
			initializing = false;
			fnTest = /xyz/.test(function() { xyz;
			}) ? /\b_super\b/ : /.*/;
			for (var name in prop) {
				prototype[name] = typeof prop[name] == "function" && typeof _super[name] == "function" && fnTest.test(prop[name]) ? (function(name, fn) {
					return function() {
						var tmp = this._super;
						this._super = _super[name];
						var ret = fn.apply(this, arguments);
						this._super = tmp;
						return ret;
					};
				})(name, prop[name]) : prop[name];
			}
			function Class() {
				var instanceid=ClassManager.getNewInstanceId();
				var instanceiddesc = {
					writable : false,
					enumerable : false,
					configurable : false,
					value : instanceid
				};
				Object.defineProperty(this, 'instanceid', desc);
				if (!initializing && this.init) {
					this.init.apply(this, arguments);
				};
			}
			var superid=this.classid;
			var superdesc = {
				writable : false,
				enumerable : false,
				configurable : false,
				value : superid
			};
			Object.defineProperty(Class,"superid",superdesc);
			Class.superClass = function() {
				if (this.superid!=undefined) {
					return ClassManager[this.superid];
				}
				else
				{
					return null;
				}
			};
			var classId = ClassManager.getNewClassID();
			var desc = {
				writable : false,
				enumerable : false,
				configurable : false,
				value : classId
			};
			Object.defineProperty(Class,"classid",desc);
			Class.prototype = prototype;
			Class.prototype.constructor = Class;
			Class.extend = arguments.callee;
			Class.isKindOfClass = function(superClass) {
				if(this.classid<superClass.classid){
					return false;
				}
				if (this.classid===superClass.classid) {
					return true;
				}
				if(this.classid===0){
					return false;
				}
				if (this.superid===superClass.classid) {
					return true;
				}
				return this.superClass().isKindOfClass(superClass);
			};
			ClassManager[classId] = Class;
			return Class;
		};
	}());
//-------------request ----------------------
JSKit.JSOperation = JSKit.JSObject.extend
    ({
	init : function() {
        this._super();
	},
	onCompleted :function (jsonObject){},
    start:function(){
        window.location.href="jskit://www.kuaif.com/request";
    },
});
JSKit.JSOperationQueue = JSKit.JSObject.extend
({
	init : function() {
		this._super();
        this.runingOperation=null;
        this.operations = new Array();
	},
    addOperation:function (operation){
        this.operations.push(operation);
        if(!this.runingOperation){
            this.runingOperation = this.operations.shift();
            this.runingOperation.start();
        }
    },
    currentParams:function(){
        if(this.runingOperation)
        {
 
            return $.toJSON(this.runingOperation);
        }
        else
        {
            return "";
        }
    },
    completed:function(jsonObject){
        this.runingOperation.onCompleted(jsonObject);
        if(this.operations.length>0){
            this.runingOperation = this.operations.shift();
            this.runingOperation.start();
        }
        else
        {
            this.runingOperation=null;
        }
    }
 });
JSKit.globalQueue = new JSKit.JSOperationQueue();
//---------------query-------------------------
JSKit.JSQueryOperation = JSKit.JSOperation.extend
({
    init:function(){
        this._super();
    },
    start:function(){
        window.location.href="jskit://www.kuaif.com/query";
    },
 });

//---------- alert ---------------------
JSKit.JSAlertObject = JSKit.JSObject.extend
({
    init:function(){
        this._super();
        this.title=null;
        this.message=null;
        this.cancelTilte=null;
        this.otherTitle=null;
    },
    callback:function(index){},
});
JSKit.alert = function (title,message,cancelTilte,otherTitle,callback) {
    var alertObject = arguments.callee.alertObject;
    if (!alertObject){
        alertObject = new JSKit.JSAlertObject();
        arguments.callee.alertObject=alertObject;
        alertObject.title=title;
        alertObject.message=message;
        alertObject.cancelTilte=cancelTilte;
        alertObject.otherTitle=otherTitle;
        alertObject.callback=callback;
        window.location.href = "jskit://www.kuaifa.com/alert";
    };
};
JSKit.alert.completed = function (index){
    if(this.alertObject){
        if (this.alertObject.callback)
        {
            this.alertObject.callback(index);
        }
        this.alertObject=null;
    };
};
JSKit.alert.alertParams = function (){
    if(this.alertObject)
    {
        return $.toJSON(this.alertObject);
    }
    else
    {
        return "";
    }
};
//openurl
JSKit.openurl = function (url,type) {
    if (url){
        arguments.callee.url=url;
        arguments.callee.type=type;
        window.location.href = "jskit://www.kuaifa.com/openurl";
    };
};
//-----------uitil------------
// 正则表达式
JSKit.verifyPassword = function(password){
    var reg =/[\d|\w]{6,12}/;
    if(reg.test(password)){
        return true;
    }
    else
    {
        return false;
    }
};
JSKit.isMobilePhone = function(phone){
    var reg =/^1[3|4|5|7|8][0-9]\d{4,8}$/;
    if(reg.test(phone)){
        return true;
    }
    else
    {
        return false;
    }
};
JSKit.isEmail = function(email){
    var reg =/^(\w)+(\.\w+)*@(\w)+((\.\w+)+)$/;
    if(reg.test(email)){
        return true;
    }
    else
    {
        return false;
    }
};
JSKit.param =function(name) {
    return decodeURIComponent((new RegExp('[?|&]' + name + '=' + '([^&;]+?)(&|#|;|$)').exec(location.search)||[,""])[1].replace(/\+/g, '%20'))||null;
}
