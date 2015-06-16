//
//  ACAccessChannel.h
//  AccessCore
//
//  Created by supertext on 15/5/7.
//  Copyright (c) 2015年 forgame. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef __cplusplus
#define ACKit_EXTERN		extern "C" __attribute__((visibility ("default")))
#else
#define ACKit_EXTERN	        extern __attribute__((visibility ("default")))
#endif

typedef NS_ENUM(NSInteger, ACPopoverPosiation) {
    ACPopoverPosiationDefualt,//渠道默认位置
    ACPopoverPosiationLeft,
    ACPopoverPosiationRight,
    ACPopoverPosiationTopLeft,
    ACPopoverPosiationTopRight,
    ACPopoverPosiationBottomLeft,
    ACPopoverPosiationBottomRight
};

typedef NS_ENUM(NSInteger, ACOrderStatus) {
    ACOrderStatusSucceed,//成功
    ACOrderStatusUntreated,//未处理
    ACOrderStatusPayfailed,//充值失败
    ACOrderStatusNotifyfailed//通知游戏方失败
};

typedef NS_ENUM(NSInteger, ACPaymentResult) {
    ACPaymentResultSucceed,//支付成功
    ACPaymentResultCancel,//用户取消支付
    ACPaymentResultRefuse,//服务器拒绝
    ACPaymentResultNetworkError,//忘了链接错误
    ACPaymentResultBalanceNotEnough,//余额不足
    ACPaymentResultNologin,//尚未登录
    ACPaymentResultOtherError//其他表明错误
};

@class      ACUserObject;
@class      ACOrderObject;
@class      UIApplication;
@protocol   ACAccessChannel;
@protocol   ACAccessChannelDelegate;

ACKit_EXTERN id<ACAccessChannel> kACStandardChannel();//获取标准化渠道单列对象

@protocol ACAccessChannel<NSObject>//渠道统一接入标准接口，直接调用对应渠道的对应方式实现，CP统一使用这一套接口就能完成所有渠道的接入
@property(nonatomic,strong,readonly)ACUserObject                *loginedUser;        //登录的用户信息
@property(nonatomic,weak  ,readonly)id<ACAccessChannelDelegate> delegate;            //事件回调代理 由application:didFinishLaunchingWithOptions:delegate:方法设置
@property(nonatomic,copy  ,readonly)NSString                    *appkey;             //渠道的appkey
@property(nonatomic,copy  ,readonly)NSString                    *appid;              //渠道的appid
@property(nonatomic,copy  ,readonly)NSString                    *sessionid;          //渠道返回的token 或者 sessionid
@property(nonatomic,copy  ,readonly)NSString                    *platformToken;      //整合平台返回的token

#pragma mark - - initlize methods
/**
 *  @brief 应用初始化成功之后由CP调用此方法,此方法是整合平台的初始化方法
 *  @warning 此方法必须调用
 *  @note  just like this:
    - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
        //你的初始化代码
        [kACStandardChannel() application:application didFinishLaunchingWithOptions:launchOptions delegate:self];
        return YES;
    }
 *  @param application   UIApplication对象
 *  @param gamekey       整合平台申请的gamekey
 *  @param launchOptions 加载选项
 *  @param delegate      委托对象 可以为空
 */
-(void)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
           gamekey:(NSString *)gamekey
          delegate:(id<ACAccessChannelDelegate>)delegate;

/**
 *  @brief 由CP在 appDelegate 的openURL 中调用
 *  @warning 此方法必须调用
 *  @note  just like this:
 *  -(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
    {
        return [kACStandardChannel() application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
    }
 *  @param application       UIApplication对象
 *  @param url               url将要处理的openurl
 *  @param sourceApplication 来源应用名称
 *  @param annotation        附加的信息
 *  @return 是否响应该openURL 事件
 */
-(BOOL)application:(UIApplication *)application
           openURL:(NSURL *)url
 sourceApplication:(NSString *)sourceApplication
        annotation:(id)annotation;
/**
 *  @brief 由CP在application:didRegisterForRemoteNotificationsWithDeviceToken:方法中调用
 *  @warning 必须接入此方法
 *  @param application UIApplication对象
 *  @param deviceToken 设备deviceToken
 */
-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;
#pragma mark - - login and register methods
/**登录注册相关方法 CP在适当的时机调用相关接口 完成渠道用户接入*/
-(void)setAutoLoginEnbled:(BOOL)isEnble;        //自动登录,默认不自动登录，如果调用这个方法将覆盖channel.xml里面的配置
-(void)showLoginView;                           //弹出登录视图
-(void)switchAccount;                           //切换账号
-(void)showUserCenter;                          //显示用户中心
-(BOOL)isLogined;                               //判断用户是否登录
-(void)hideView;                                //隐藏当前弹出的视图
-(void)logout;                                  //注销

#pragma mark - - payment methods
/** 支付相关方法 **/
/**
 *  @brief 订单支付功能，如果order为空则弹出充值页面，如果该渠道不支持定额支付 则order将被忽略直接弹出充值页面
 *  @brief 如果用户没登录 回调中会收到ACPaymentResultNologin 的错误代码
 *  @param order 订单信息
 */
-(void)paymentWithOrder:(ACOrderObject *)order;
-(void)queryOrderWithid:(NSString *)orderid;//这里需要的订单号为整合平台生成的订单号，在支付结果回调后获得
#pragma mark - -  settings methods
/**设置相关方法*/
-(void)setPopoverHidden:(BOOL)hidden;           //显示或者隐藏浮窗，默认不显示，如果该渠道没有浮窗功能则此方法无效。如果调用这个方法将覆盖channel.xml里面的配置
-(void)setPopoverPosiation:(ACPopoverPosiation)posiation;//设置浮窗位置，如果该渠道没有浮窗功能则此方法无效。如果调用这个方法将覆盖channel.xml里面的配置
-(void)checkUpdate;                             //检查更新,如果没有检查更新，则此方法无效
#pragma mark - - game runtime methods
/*** 游戏运行相关方法，由CP在对应时机调用，如果对应渠道没有类似操作，下面3个方法为空实现**/
-(void)continueGame;                            //游戏由暂停到继续时调用
-(void)suspendGame;                             //游戏暂停时调用
-(void)stopGame;                                //结束游戏
@end

@protocol ACAccessChannelDelegate <NSObject>//事件回调
@optional
-(void)accessChannel:(id<ACAccessChannel>)channel didFinishLoginWithUser:(ACUserObject *)userInfo error:(NSError *)error;//登录完成后调用，如果失败error不为空
-(void)accessChannel:(id<ACAccessChannel>)channel didFinishLogoutWithError:(NSError *)error;//注销完成后调用,如果未能成功注销error 不为空
-(void)accessChannel:(id<ACAccessChannel>)channel didFinishRegistWithError:(NSError *)error;//注册完成之后调用，如果注册失败error不为空

-(void)accessChannel:(id<ACAccessChannel>)channel didFinishPaymentWithOrderid:(NSString *)orderid
              result:(ACPaymentResult)result
               error:(NSError *)error;//支付结束之后调用，如果支付失败error不为空,这里返回的订单号是整合平台生成的订单号
-(void)accessChannel:(id<ACAccessChannel>)channel didFinishQueryWithOrderid:(NSString *)orderid
              status:(ACOrderStatus)status
                desc:(NSString *)desc
               error:(NSError *)error;//订单查询完成之后回调，如果发生错误error不为空
@end

typedef NS_ENUM(NSInteger, ACChannelLeaveType) {
    ACChannelLeaveTypeUnkown,/* 离开未知平台（预留状态）*/
    ACChannelLeaveTypeLoginRegist,/* 离开注册、登录页面 */
    ACChannelLeaveTypeUserCenter, /* 包括个人中心、游戏推荐、论坛 */
    ACChannelLeaveTypePayment/* 离开充值页（包括成功、失败）*/
};
ACKit_EXTERN NSString *const kACChannelLeaveTypeKey;
ACKit_EXTERN NSString *const kACPaymentErrorDomain;
/* 系统通知:所有的通知发出的时间都是在 相应的事件的delegate调用之后*/
ACKit_EXTERN NSString *const ACAccessChannelDidFinishInitNotification;
ACKit_EXTERN NSString *const ACAccessChannelDidFinishLoginNotification;
ACKit_EXTERN NSString *const ACAccessChannelDidFinishLogoutNotification;
ACKit_EXTERN NSString *const ACAccessChannelDidFinishRegistNotification;
ACKit_EXTERN NSString *const ACAccessChannelDidFinishPaymentNotification;
ACKit_EXTERN NSString *const ACAccessChannelDidFinishQueryOrderNotification;
ACKit_EXTERN NSString *const ACAccessChannelDidLeaveChannelPageNotification;//ACChannelLeaveType leaveType = [userinfo[kACChannelLeaveTypeKey] integerValue];
ACKit_EXTERN NSString *const ACAccessChannelTempUserBecomeOfficialNotification;
