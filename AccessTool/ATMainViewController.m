//
//  ViewController.m
//  AccessTool
//
//  Created by supertext on 15/5/26.
//  Copyright (c) 2015年 forgame. All rights reserved.
//

#import "ATMainViewController.h"
#import <CoreGraphics/CoreGraphics.h>
@implementation ATMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.chooseButton.target=self;
    self.chooseButton.action=@selector(chooseFile);
    self.startButton.target=self;
    self.startButton.action=@selector(startPackage);
    NSLog(@"%@",[[NSBundle mainBundle] resourcePath]);
    NSString *channelName = @"forgame";
    NSInteger direction =1;
    NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.bundle/icon/icon_%zi",channelName,direction]];
    NSImage *image = [[NSImage alloc] initByReferencingFile:path];
    NSString *outPath = [NSHomeDirectory() stringByAppendingPathComponent:@"temp"];
    
    NSString *cmd  = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"script.bundle/run.py"];
    [self runSystemCommand:cmd];
    NSGraphicsContext *context = [NSGraphicsContext graphicsContextWithBitmapImageRep:[[NSBitmapImageRep imageRepsWithContentsOfFile:@"11"] firstObject]];
    NSImage *img;
    [image lockFocus]
//    [self OpenFileDialog];
    // Do any additional setup after loading the view.
}
-(void)hecheng
{
    NSImage *img1 = [NSImage imageNamed:@"Textmate"];
    NSImage *img2 = [NSImage imageNamed:@"potraint"];
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"animated.gif"];
    NSLog(@"%@", path);
    NSURL *destUrl = [NSURL fileURLWithPath:path];
    CGImageDestinationRef imageDest;
    NSString *uti = @"com.compuserve.gif";
    NSData *img1Data = [img1 TIFFRepresentation];
    NSData *img2Data = [img2 TIFFRepresentation];
    NSDictionary *frameProperties = [NSDictionary dictionaryWithObject:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:2] forKey:(NSString *)kCGImagePropertyGIFDelayTime]
                                                                forKey:(NSString *)kCGImagePropertyGIFDictionary];
    NSDictionary *gifProperties = [NSDictionary dictionaryWithObject:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0] forKey:(NSString *)kCGImagePropertyGIFLoopCount]
                                                              forKey:(NSString *)kCGImagePropertyGIFDictionary];
    CGImageSourceRef imageSourceRef1 = CGImageSourceCreateWithData((CFDataRef)img1Data, (CFDictionaryRef)frameProperties);
    CGImageSourceRef imageSourceRef2 = CGImageSourceCreateWithData((CFDataRef)img2Data, (CFDictionaryRef)frameProperties);
    CGImageRef imgRef1 = CGImageSourceCreateImageAtIndex(imageSourceRef1, 0, NULL);
    CGImageRef imgRef2 = CGImageSourceCreateImageAtIndex(imageSourceRef2, 0, NULL);
    imageDest = CGImageDestinationCreateWithURL((CFURLRef)destUrl, (CFStringRef)uti, 2, NULL);
    CGImageDestinationAddImage(imageDest, imgRef1, (CFDictionaryRef)frameProperties);
    CGImageDestinationAddImage(imageDest, imgRef2, (CFDictionaryRef)frameProperties);
    CGImageDestinationFinalize(imageDest);
}
-(void) runSystemCommand:(NSString *)cmd
{
    NSLog(@"cmd:%@",cmd);
    [[NSTask launchedTaskWithLaunchPath:@"/usr/bin/python"
                              arguments:@[cmd]]
     waitUntilExit];
}
- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}
- (void)chooseFile
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
-(void)startPackage
{

}
@end
