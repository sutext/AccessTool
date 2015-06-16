//
//  ATChannelConfig.h
//  AccessTool
//
//  Created by supertext on 15/6/2.
//  Copyright (c) 2015年 forgame. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ATConfigReadCode) {
    ATConfigReadCodeSucceed,
    ATConfigReadCodeXMLNotExist,
    ATConfigReadCodeXMLFormatError,
    ATConfigReadCodeChannelNotExist,
};

@interface ATChannelConfig : NSObject
@property(nonatomic,copy,readonly)NSString *CHName;
@property(nonatomic,copy,readonly)NSString *CHVersion;
@property(nonatomic,copy,readonly)NSString *CHAppID;
@property(nonatomic,copy,readonly)NSString *CHAppKey;
@property(nonatomic,copy,readonly)NSString *CHGameKey;
@property(nonatomic,copy,readonly)NSString *CHGameChannel;
@property(nonatomic,copy,readonly)NSString *CHPrivateKey;
@property(nonatomic,copy,readonly)NSString *CHServerNumber;
@property(nonatomic,copy,readonly)NSString *CPAutoLogin;
@property(nonatomic,copy,readonly)NSString *CPForceUpdate;
@property(nonatomic,copy,readonly)NSString *CPShowPopover;
@property(nonatomic,copy,readonly)NSString *CPPopoverPosiation;
@property(nonatomic,copy,readonly)NSString *CPScreenOrientation;

@property(nonatomic,copy,readonly)NSString *DEV_ISDebugModel;
@property(nonatomic,copy,readonly)NSString *DATA_Product;
@property(nonatomic,copy,readonly)NSString *PAY_MerchantId;
@property(nonatomic,copy,readonly)NSString *PAY_NotifiyURL;
@property(nonatomic,copy,readonly)NSString *PAY_SellerPrivateInfo;
@property(nonatomic,copy,readonly)NSString *AppScheme_Prefix;
@property(nonatomic,copy,readonly)NSString *AlipayScheme_Prefix;
@property(nonatomic,copy,readonly)NSString *BundleID;
@property(nonatomic,copy,readonly)NSString *BundleVersion;
@property(nonatomic,copy,readonly)NSString *BundleDisplayName;
@property(nonatomic,copy,readonly)NSString *ICON_NEED_SETTING;
@property(nonatomic,copy,readonly)NSString *ICON_location;
@property(nonatomic,copy,readonly)NSString *LAUNCH_NEED_SETTING;
@property(nonatomic,copy,readonly)NSString *LAUNCH_location;
+ (instancetype)configWithName:(NSString *)cpname inConfigFile:(NSString *)xmlfile code:(inout ATConfigReadCode *)codeptr;
@end
