//
//  ACOrderObject.h
//  AccessCore
//
//  Created by supertext on 15/5/7.
//  Copyright (c) 2015年 forgame. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ACOrderObject : NSObject
@property (nonatomic,copy)NSString   *amount;             //支付金额,必填项
@property (nonatomic,copy)NSString   *productid;          //商品ID
@property (nonatomic,copy)NSString   *productCount;       //商品数量
@property (nonatomic,copy)NSString   *orderNumber;        //外部订单号，由CP自由填写
@property (nonatomic,copy)NSString   *productName;        //商品名称
@property (nonatomic,copy)NSString   *notifyUrl;          //自定义回调地址,如果未设置这个参数 将使用配置channel.xml中的配置
@property (nonatomic,copy)NSString   *paydesc;            //商户私有信息
@property (nonatomic,copy)NSString   *roleid;             //角色ID
@property (nonatomic,copy)NSString   *gameextend;         //游戏扩展参数
@property (nonatomic,copy)NSString   *productDisplayTitle;//支付显示名称

@property (nonatomic,copy,readonly)NSString   *orderid;   //统一平台生成的订单号
@end
