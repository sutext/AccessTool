//
//  login.js
//  GameKuaifa
//
//  Created by supertext on 15/5/7.
//  Copyright (c) 2015年 kuaifa. All rights reserved.
//

var JSKit = JSKit || {};
JSKit.auth = JSKit.auth||{};
JSKit.auth.markForUsername = function (username){
    if (JSKit.isEmail(username))
    {
        return "0";
    }
    else if (JSKit.isMobilePhone(username))
    {
        return "1";
    }
    else
    {
        return "2";
    }
}
JSKit.auth.fastStart = function ()
{
    JSKit.alert("提示","快速登录游戏后,请尽快帮的一个Forgame帐号,以防止游戏数据丢失!","返回","快速游戏",function (index){
                    if (index == 1)
                    {
                        //TODO:do fast start logic!
                        var request = new JSKit.JSOperation();
                        request.requestURL="user/tmpuser";
                        request.onCompleted = function (jsonObject)
                        {
                            if (jsonObject.errorCode == 0){
                                JSKit.alert("提示","登陆成功","确定",null,null);
                            }
                            else
                            {
                                JSKit.alert("提示","账号或密码错误","确定",null,null);
                            }
                        };
                        JSKit.globalQueue.addOperation(request);
                    }
                });
}

JSKit.auth.bindaccount = function ()
{
    var request = new JSKit.JSOperation();
    request.requestURL="user/improvemail";
    request.mail=$("input#username").val();
    request.password=$("input#password").val();
    request.mark=JSKit.auth.markForUsername(request.username);
    request.onCompleted = function (jsonObject)
    {
        if (jsonObject.errorCode == 0){
            JSKit.alert("提示","绑定成功","确定",null,null);
        }
        else
        {
            JSKit.alert("提示","绑定失败","确定",null,null);
        }
    };
    JSKit.globalQueue.addOperation(request);
}
JSKit.auth.queryUserByid = function (uid,onCompleted) {
    var queryObject = new JSKit.JSQueryOperation();
    queryObject.queryType="userbyid";
    queryObject.uid=uid;
    queryObject.onCompleted=onCompleted;
    JSKit.globalQueue.addOperation(queryObject);
};

JSKit.auth.queryLoginUser = function (onCompleted) {
    var queryObject = new JSKit.JSQueryOperation();
    queryObject.queryType="loginUser";
    queryObject.onCompleted=onCompleted;
    JSKit.globalQueue.addOperation(queryObject);
};
JSKit.auth.queryAllUsers = function (onCompleted) {
    var queryObject = new JSKit.JSQueryOperation();
    queryObject.queryType="allUsers";
    queryObject.onCompleted=onCompleted;
    JSKit.globalQueue.addOperation(queryObject);
};
JSKit.auth.loginout = function ()
{
    var request = new JSKit.JSOperation();
    request.requestURL="user/logout";
    request.onCompleted = function (jsonObject)
    {
        JSKit.alert("提示","已退出登录","确定",null,function(index){
                        window.location.href="jskit://www.kuaifa.com/close";
                    });
    };
    JSKit.globalQueue.addOperation(request);
}


JSKit.auth.login = function (user)
{
    if(!user){return;}
    var request = new JSKit.JSOperation();
    request.requestURL="user/login";
    request.username=user.username;
    request.password=user.password;
    request.mark=user.mark;
    request.onCompleted = function (jsonObject)
    {
        if (jsonObject.errorCode == 0){
            JSKit.alert("提示","登陆成功","确定",null,null);
        }
        else
        {
            JSKit.alert("提示","账号或密码错误","确定",null,null);
        }
    };
    JSKit.globalQueue.addOperation(request);
}
JSKit.auth.normalLogin=function(){
    var user = new JSKit.JSObject();
    user.username=$("input#username").val();
    user.password=$("input#password").val();
    user.mark=JSKit.auth.markForUsername(user.username);
    JSKit.auth.login(user);
}
JSKit.auth.autoLogin=function(user){
    if(!user){return;}
    var request = new JSKit.JSOperation();
    request.requestURL="user/relogin";
    var username = user.username;
    var mark = "2";
    if (user.account_mark==1)
    {
        username=user.mail;
        mark="0";
    }
    else if (user.account_mark==2)
    {
        username=user.mobile;
        mark="1";
    }
    request.username=$.base64.decode(username,true)
    request.mark=mark;
    request.onCompleted = function (jsonObject)
    {
        if (jsonObject.errorCode == 0)
        {
            JSKit.alert("提示","登陆成功","确定",null,null);
        }
        else
        {
            JSKit.alert("提示","账号或密码错误","确定",null,null);
        }
    };
    JSKit.globalQueue.addOperation(request);
}
JSKit.auth.checklogin = function (callback)
{
    var request = new JSKit.JSOperation();
    request.requestURL="user/checklogin";
    
    request.onCompleted=function(jsonObject){
        if(jsonObject.errorCode==0){
            var list =jsonObject.data.loginGameMailList;
            JSKit.auth.checklogin.chekedUsers=list;
            callback(list);
        }
    };
    JSKit.globalQueue.addOperation(request);
}
JSKit.auth.swapLogin = function ()
{
    var id = $("select.login-select").val();
    var user =JSKit.auth.checklogin.chekedUsers[id];
    if(user)
    {
        JSKit.auth.autoLogin(user);
    }
}

JSKit.auth.register = function ()
{
    var request = new JSKit.JSOperation();
    request.requestURL="user/register";
    request.mail=$("input#username").val();
    request.password=$("input#password").val();
    request.mark = JSKit.auth.markForUsername(request.mail);
    request.onCompleted = function (jsonObject)
    {
        if (jsonObject.errorCode==0){
            window.location.href = "account02.html?mail="+request.mail+"&password="+request.password+"&mark="+request.mark;
        }
    };
    JSKit.globalQueue.addOperation(request);
}


// 手机注册 获取验证码绑定的请求方法
JSKit.auth.phoneRegister1 = function ()
{
    var request = new JSKit.JSOperation();
    request.requestURL="user/bindregister1";
    
    request.mail=$("input#username").val();
    request.mark="1";
    request.onCompleted = function (jsonObject)
    {
        if (jsonObject.errorCode==0){
            window.location.href = "phone02.html?mail="+request.mail;
        }else if (jsonObject.errorCode==74){
            JSKit.alert("提示","手机号不对","确定",null,null);
        }else if (jsonObject.errorCode==76){
            JSKit.alert("提示","用户已存在","确定",null,null);
        }else
        {
            JSKit.alert("提示","服务器异常","确定",null,null);
        }

    };
    JSKit.globalQueue.addOperation(request);
}

// 立即注册发的请求
JSKit.auth.phoneRegister2 = function ()
{
    var request = new JSKit.JSOperation();
    request.requestURL="user/bindregister2";
    request.mail=JSKit.param("mail");
    request.mark="1";
    var password =$("input#password").val();
    if (!JSKit.verifyPassword(password)){
        JSKit.alert("提示","密码必须为6-12位数字或字母","确定",null,null);
        return;
    }
    request.password=password;
    request.platform="abc";
    var seccode = $("input#seccode").val();
    if (!seccode.length)
    {
        JSKit.alert("提示","验证码不能为空","确定",null,null);
        return;
    }
    request.seccode=seccode;
    request.onCompleted = function (jsonObject)
    {
        if (jsonObject.errorCode==0){
            window.location.href = "tips.html?title=注册成功";
        }else if (jsonObject.errorCode == 14)
        {
            JSKit.alert("提示","验证码输入不正确","确定",null,null);
        }else if (jsonObject.errorCode == 2)
        {
            JSKit.alert("提示","验证码不能为空","确定",null,null);
        }
    };
    JSKit.globalQueue.addOperation(request);
}





JSKit.auth.changepass = function ()
{
    var request = new JSKit.JSOperation();
    request.requestURL="user/changepass";
    request.newpass=$("input#newpass").val();
    request.oldpass=$("input#oldpass").val();
    request.mark = JSKit.auth.markForUsername(request.mail);
    request.onCompleted = function (jsonObject)
    {
        if (jsonObject.errorCode==0){
            window.location.href = "tips.html?title=修改密码成功";
        }
    };
    JSKit.globalQueue.addOperation(request);
}

JSKit.auth.bindmobile = function (step)
{
    var request = new JSKit.JSOperation();
    request.requestURL="user/bindmobile";
    request.mobile=$("input#username").val();
    request.timestamp=""+Math.round(new Date().getTime()/1000);
    request.step=step;
    request.mark=JSKit.param('mark');
    request.mail=JSKit.param('mail');
    request.password=JSKit.param('password');
    if (step == "2") {
        request.seccode=$("input#seccode").val();
    }
    request.onCompleted = function (jsonObject)
    {
        switch(parseInt(jsonObject.errorCode)) {
            case 0: {
                if (step==1) {
                    JSKit.alert("提示", "发送验证码成功", "确定", null, null);
                    
                } else {
                    window.location.href = "tips.html?title=账号注册成功";
                }
                break;
            }
            case 1:
                JSKit.alert("提示", "操作失败", "确定", null, null);
                break;
            case 2: {
                JSKit.alert("提示", "手机号不能为空哦", "确定", null, null);
                break;
            }
            case 14: {
                JSKit.alert("提示", "验证码输入不正确", "确定", null, null);
                break;
            }
            case 74: {
                JSKit.alert("提示", "手机号格式不正确", "确定", null, null);
                break;
            }
            case 76: {
                JSKit.alert("提示", "该手机号已被绑定", "确定", null, null);
                break;
            }
            default:
                JSKit.alert("提示", "操作失败", "确定", null, null);
                break;
        }

    };
    JSKit.globalQueue.addOperation(request);

}


JSKit.auth.checkaccount = function (){
    var request = new JSKit.JSOperation();
    request.requestURL="user/checkaccount";
    request.mail=$("input#username").val();
    request.mark = JSKit.auth.markForUsername(request.mail);
    request.onCompleted = function (jsonObject)
    {
        if (jsonObject.errorCode==0){
            JSKit.alert("提示","改账号尚未注册","知道了",null,null);
        }
        else
        {
            if (request.mark=="2"){
                JSKit.alert("提示","改账号尚未绑定密保手段情联系客服修改密码","知道了",null,null);
            }
            else
            {
               window.location.href = "forget02.html?mail="+request.mail+"&mark="+request.mark;
                
            }
            
        }
    };
    JSKit.globalQueue.addOperation(request);
};
JSKit.auth.resetpass1 = function (){
    var request = new JSKit.JSOperation();
    request.requestURL="user/resetpass1";
    request.mark = JSKit.param('mark');
    request.mail = JSKit.param('mail');
    request.onCompleted = function (jsonObject)
    {
        if (jsonObject.errorCode==0){
            window.location.href = "forget03.html?mail="+request.mail+"&mark="+request.mark;
        }
        else if (jsonObject.errorCode==16)
        {
            JSKit.alert("提示","发送验证码失败请联系客服","好",null,null);
        }
        else
        {
            JSKit.alert("提示","找回密码遇到了问题请联系客服","好",null,null);
        }
    };
    JSKit.globalQueue.addOperation(request);
};

JSKit.auth.resetpass2 = function (){
    var request = new JSKit.JSOperation();
    request.requestURL="user/resetpass2";
    request.mark = JSKit.param('mark');
    request.mail = JSKit.param('mail');
    request.seccode=$("input#seccode").val();
    request.onCompleted = function (jsonObject)
    {
        if (jsonObject.errorCode==0){
            window.location.href = "forget04.html?mail="+request.mail+"&mark="+request.mark;
        }
        else
        {
            JSKit.alert("提示","验证码输入错误,请重新输入","好",null,null);
        }
    };
    JSKit.globalQueue.addOperation(request);
};
JSKit.auth.resetpass3 = function (){
    var request = new JSKit.JSOperation();
    request.requestURL="user/resetpass3";
    request.mark = JSKit.param('mark');
    request.mail = JSKit.param('mail');
    request.password=$("input#password").val();
    request.onCompleted = function (jsonObject)
    {
        if (jsonObject.errorCode==0){
            //成功
            window.location.href = "tips.html?title=重置密码成功";
        }
    };
    JSKit.globalQueue.addOperation(request);
};




