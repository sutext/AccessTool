//
//  ACOrderObject.h
//  AccessCore
//
//  Created by supertext on 15/5/7.
//  Copyright (c) 2015年 forgame. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface ACOrderObject : NSObject
@property (nonatomic)        double      amount;             //支付金额
@property (nonatomic)        NSInteger   productId;          //商品ID
@property (nonatomic)        NSInteger   productCount;       //商品数量
@property (nonatomic,copy)   NSString   *orderNumber;        //外部订单号
@property (nonatomic,copy)   NSString   *productName;        //商品名称
@property (nonatomic,copy)   NSString   *notifyUrl;          //自定义回调地址,如果未设置这个参数 将使用配置channel.xml中的配置
@property (nonatomic,copy)   NSString   *paydesc;            //商户私有信息
@property (nonatomic,copy)   NSString   *roleid;             //角色ID
@property (nonatomic,copy)   NSString   *zoneid;             //游戏分区ID
@property (nonatomic,copy)   NSString   *gameextend;         //游戏扩展参数
@property (nonatomic,copy)   NSString   *productDisplayTitle;//支付显示 名称
@end

typedef NS_ENUM(NSInteger, ACPaymentType) {
    ACPaymentTypeAlipay,
    ACPaymentTypeUnionpay,
};

typedef NS_ENUM(NSInteger, ACPaymentCode) {
    ACPaymentCodeSucceed,
    ACPaymentCodeCancel,
    ACPaymentCodeRefuse,
};

@interface ACPaymentResult : NSObject
@property(nonatomic,readonly)ACPaymentType payType;
@property(nonatomic,readonly)ACPaymentCode code;
@property(nonatomic,strong,readonly)ACOrderObject *orderInfo;
@end