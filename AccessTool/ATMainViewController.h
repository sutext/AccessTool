//
//  ViewController.h
//  AccessTool
//
//  Created by supertext on 15/5/26.
//  Copyright (c) 2015年 forgame. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ATMainViewController : NSViewController
@property(nonatomic,strong)IBOutlet NSTextField         *pathView;
@property(nonatomic,strong)IBOutlet NSTextField         *infoLabel;
@property(nonatomic,strong)IBOutlet NSButton            *chooseButton;
@property(nonatomic,strong)IBOutlet NSButton            *startButton;
@property(nonatomic,strong)IBOutlet NSButton            *selectAll;
@property(nonatomic,strong)IBOutlet NSView              *channelView;
@end

