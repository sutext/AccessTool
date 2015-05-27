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
