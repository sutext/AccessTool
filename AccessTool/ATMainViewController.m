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
    NSInteger direction =2;
    
    // 角标路径
    NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.bundle/icons/icon_%zi.png",channelName,direction]];
    
    // 角标
    NSImage *image = [[NSImage alloc] initByReferencingFile:path];
  
    // 原始icon
    NSImage *inputImage = [NSImage imageNamed:@"icon.jpg"];
    
    // 合成icon路径
    NSString *outPath = [NSHomeDirectory() stringByAppendingPathComponent:@"temp/icon.png"];
    
    // 合成的icon
    NSImage *resultImage =[self iconImage:inputImage channelImage:image];
    
    // 将NSImage转为NSData
    NSData *data = [resultImage TIFFRepresentation];
    
    // 将合成的icon写入文件
    [data writeToFile:outPath atomically:YES];
}
-(void)startPackage
{

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
/**
 *  将两张图片合成一张
 *  iconImage: 主图片
 *  channelImage: 角标
 */
- (NSImage *)iconImage:(NSImage *)iconImage channelImage:(NSImage *)channelImage{

    // 创建一张新图片，大小为主图大小
    NSImage *newImage = [[NSImage alloc] initWithSize:iconImage.size];
    
    [newImage lockFocus];
    
    CGContextRef imageContext = [[NSGraphicsContext currentContext] graphicsPort];
    
    CGContextDrawImage(imageContext, NSMakeRect(0, 0, iconImage.size.width, iconImage.size.height), [self nsImageToCGImageRef:iconImage]);
    
    CGContextDrawImage(imageContext, NSMakeRect(0, 0, iconImage.size.width, iconImage.size.height), [self nsImageToCGImageRef:channelImage]);
    
    [newImage unlockFocus];
    
    return newImage;
}

// 将NSImage转为CGImageRef
- (CGImageRef)nsImageToCGImageRef:(NSImage*)image;

{
    NSData * imageData = [image TIFFRepresentation];
    
    CGImageRef imageRef;
    
    if(imageData)
        
    {
        CGImageSourceRef imageSource = CGImageSourceCreateWithData((CFDataRef)imageData,  NULL);
        
        imageRef = CGImageSourceCreateImageAtIndex(imageSource, 0, NULL);
    }
    
    return imageRef;
}
@end
