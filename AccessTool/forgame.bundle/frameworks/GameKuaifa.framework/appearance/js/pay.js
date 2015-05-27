//
//  pay.js
//  GameKuaifa
//
//  Created by supertext on 15/5/14.
//  Copyright (c) 2015年 kuaifa. All rights reserved.
//

var JSKit = JSKit || {};
JSKit.pay = JSKit.pay||{};
//支付方式封装类
JSKit.JSPaymentItem = JSKit.JSObject.extend
({
    init : function(itemData,payid) {
        this._super();
        this.payid=payid;
        this.channelid=itemData.id;
        this.icon=itemData.on_swith_icon;
        this.title=$.base64.decode(itemData.desc,true);
 
    },
    createDomobject:function(){
        var input =$('<input id="'+this.payid+this.channelid+'" class="pay-radio" type="radio" name="pay-radio">');
        var self = this;
        input.click(function(e){
            JSKit.JSPaymentItem.selectedItem=self;
            if(!self.orderInfo)
            {
                self.addOrder();
            }
            else
            {
                self.showAmountlist();
            }
        });
        var li = $('<li class="pay-item"><label class="pay-radio-text" for="'+this.payid+this.channelid+'"><img class="pay-radio-icon" src="'+this.icon+'"><span>'+this.title+'</span></label></li>');
         li.prepend(input);
        return li;
    },
    showAmountlist:function(){
        if ((this.orderInfo.mold==1)){
            $("input.pay-input").show();
        }
        else
        {
            $("input.pay-input").hide();
        }
        var amountlist=this.orderInfo.amountlist;
        var select = $("select.pay-select");
        var str = '';
        for (var i=0;i<amountlist.length;i++){
            var amount = amountlist[i];
            str =str+ '<option value="'+amount.amount+'">'+amount.amount+'元</option>';
        }
        select.html(str);
    },
    addOrder:function(){
        var request = new JSKit.JSOperation();
        request.requestURL="order/add";
        request.payid=this.payid;
        request.channelid=this.channelid;
        var self = this;
        request.onCompleted = function(jsonObject){
            if (jsonObject.errorCode==0)
            {
                self.orderInfo=jsonObject.data;
                self.showAmountlist();
            }
        }
        JSKit.globalQueue.addOperation(request);
    },
});
//获取支付方式列表
JSKit.pay.paywayList =function (){
    var request = new JSKit.JSOperation();
    request.requestURL="order/payment";
    request.onCompleted = function (jsonObject)
    {
        if (jsonObject.errorCode == 0){
            var tableView = $("ul#tableView");
            var list = jsonObject.data.list;
            for(var i=0;i<list.length;i++){
                var sub =list[i].sub;
                if (sub){
                    for(var j=0;j<sub.length;j++){
                        var item = new JSKit.JSPaymentItem(sub[j],list[i].id);
                        tableView.append(item.createDomobject());
                    }
                }
            }
        }
        else
        {
            JSKit.alert("提示","获取失败","确定",null,null);
        }
    };
    JSKit.globalQueue.addOperation(request);
}
//提交订单，点击立即支付调用此页面
JSKit.pay.submitOrder = function (callback){
    if(!JSKit.JSPaymentItem.selectedItem){
        JSKit.alert("提示","请选择支付方式","确定",null,null);
        return;
    }
    var request = new JSKit.JSOperation();
    request.requestURL="order/submit";
    var orderInfo = JSKit.JSPaymentItem.selectedItem.orderInfo;
    request.gameid=orderInfo.gameid;
    request.payid=orderInfo.payid;
    request.channelid=orderInfo.channelid;
    request.amount=$("select.pay-select").val();
    request.mobile="";
    request.captcha=orderInfo.captchaurl;
    request.mail="";
    request.serverid="";
    request.timestamp=""+Math.round(new Date().getTime()/1000);
    if(orderInfo.mold==1){
        request.cardno=$("input#cardno").val();
        request.cardkey=$("input#cardkey").val();
        if(!(request.cardno.length>0&&request.cardkey.length>0)){
            JSKit.alert("提示","请输入卡号和卡密","确定",null,null);
            return;
        }
    }
    request.country="";
    request.gameextend="0";
    request.gameuserid="0";
    request.game_product_name="";
    request.onCompleted = function(jsonObject){
        if(jsonObject.errorCode==0){
            var url = jsonObject.data.url;
            var type="weburl";
            if(!url){
                url = jsonObject.data.aliclient;
                type="aliclient";
            }
            if(!url){
                url = jsonObject.data.tn+"&"+jsonObject.data.mode;
                type="upay";
            }
            if(!url){
                url="";
                type="none";
            }
            JSKit.openurl(url,type);
        }
    };
    JSKit.globalQueue.addOperation(request);
}
