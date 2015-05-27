//
//  ViewController.m
//  AccessTool
//
//  Created by supertext on 15/5/26.
//  Copyright (c) 2015年 forgame. All rights reserved.
//

#import "ATMainViewController.h"

@implementation ATMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.chooseButton.target=self;
    self.chooseButton.action=@selector(chooseFile);
    NSLog(@"%@",[[NSBundle mainBundle] resourcePath]);
    NSString *channelName = @"forgame";
    NSInteger direction =1;
    NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.bundle/icon/icon_%zi",channelName,direction]];
    NSImage *image = [[NSImage alloc] initByReferencingFile:path];
    NSString *outPath = [NSHomeDirectory() stringByAppendingPathComponent:@"temp"];
    
//    [self OpenFileDialog];
    // Do any additional setup after loading the view.
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}
- (IBAction)chooseFile
{
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    [openDlg setCanChooseFiles:YES];
    [openDlg beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger result) {
        if (result == NSModalResponseOK) {
            NSDictionary *fileAttr= [[NSFileManager defaultManager] attributesOfItemAtPath:openDlg.URL.path error:nil];
            self.pathView.stringValue=fileAttr.fileGroupOwnerAccountName;
            
        }
    }];
}
@end
