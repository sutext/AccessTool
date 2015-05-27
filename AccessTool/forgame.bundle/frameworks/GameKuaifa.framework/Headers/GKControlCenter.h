//
//  GKControlCenter.h
//  GameKuaifa
//
//  Created by supertext on 15/5/15.
//  Copyright (c) 2015年 kuaifa. All rights reserved.
//

#import <Foundation/Foundation.h>
@class GKNetworkRequest;
@class GKUserInfoEntity;

/**
 *  业务逻辑控制中心，控制网络请求，以及维护全局参数
 */
@interface GKControlCenter : NSObject
+(instancetype)defaultCenter;
-(void)setupParams:(NSDictionary *)params;
-(void)showLoginView;
-(void)showPayview;
-(void)showUserCenter;
-(void)hideView;

@property (nonatomic,strong,readonly) GKUserInfoEntity *loginUser;//当前登录用户对象，如果为nil表示未登录
@property (nonatomic,strong,readonly) NSString *gamekey;
@property (nonatomic,strong,readonly) NSString *channel;
@property (nonatomic,strong,readonly) NSString *source;
@property (nonatomic,strong,readonly) NSString *devicetocken;
@end
