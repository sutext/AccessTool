//
//  ACUserObject.h
//  AccessCore
//
//  Created by supertext on 15/5/7.
//  Copyright (c) 2015年 forgame. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ACUserObject : NSObject
@property(nonatomic,copy)NSString *userid;             //id
@property(nonatomic,copy)NSString *username;           //名称
@property(nonatomic,copy)NSString *nikcname;           //昵称
@property(nonatomic,copy)NSString *uuid;               //
@property(nonatomic,copy)NSString *avatar;             //头像
@property(nonatomic,copy)NSString *level;              //级别
@property(nonatomic,copy)NSString *gender;             //性别
@end
