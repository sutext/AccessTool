//
//  ViewController.m
//  AccessTool
//
//  Created by supertext on 15/5/26.
//  Copyright (c) 2015年 forgame. All rights reserved.
//

#import "ATMainViewController.h"
#import "ZipArchive.h"
#import "ATChannelConfig.h"
#import <CoreGraphics/CoreGraphics.h>
@interface ATMainViewController()
@property(nonatomic,strong)NSString *ipaPath;
@end
@implementation ATMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.chooseButton.target=self;
    self.chooseButton.action=@selector(chooseFile);
    self.startButton.target=self;
    self.startButton.action=@selector(startPackage);
}
- (void)chooseFile
{
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    [openDlg setCanChooseFiles:YES];
    [openDlg beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger result) {
        if (result == NSModalResponseOK) {
            self.ipaPath=openDlg.URL.path;
            self.pathView.stringValue = [[NSFileManager defaultManager] displayNameAtPath:self.ipaPath];
        }
    }];
}
-(void)startPackage
{
    NSString *originDir = [NSHomeDirectory() stringByAppendingString:@"/Downloads/kuaifaPakages/origin"];
    [[NSFileManager defaultManager] removeItemAtPath:[NSHomeDirectory() stringByAppendingString:@"/Downloads/kuaifaPakages"] error:nil];
    if ([self unzipFile:self.ipaPath toDirectory:originDir]) {
        NSString *payloadPath = [originDir stringByAppendingString:@"/Payload"];
        NSLog(@"%@",[[NSFileManager defaultManager] subpathsAtPath:payloadPath]);
        NSString *appName = [[[NSFileManager defaultManager] subpathsAtPath:payloadPath] firstObject];
        NSLog(@"%@",appName);
        [self.channelView.subviews enumerateObjectsUsingBlock:^(NSButton *channel, NSUInteger idx, BOOL *stop) {
            if (channel.state) {
                ATConfigReadCode code;
                ATChannelConfig *config = [ATChannelConfig configWithName:channel.title inConfigFile:[originDir stringByAppendingFormat:@"/Payload/%@/channel.xml",appName] code:&code];
                if (code==ATConfigReadCodeSucceed) {
                     [self packgeForNmae:channel.title config:config appName:appName];
                }
                [self packgeForNmae:channel.title config:config appName:appName];
            }
        }];
    }
}
-(void)packgeForNmae:(NSString *)channelName config:(ATChannelConfig *)config appName:(NSString *)appName;
{
    NSLog(@"渠道:%@开始出包...",channelName);
    NSString *origindir = [NSHomeDirectory() stringByAppendingString:@"/Downloads/kuaifaPakages/origin"];
    NSString *channeldir = [[NSHomeDirectory() stringByAppendingString:@"/Downloads/kuaifaPakages/"] stringByAppendingString:channelName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    if ([fileManager copyItemAtPath:origindir toPath:channeldir error:&error]&&!error) {
        [self replaceIconAtPath:[channeldir stringByAppendingFormat:@"/Payload/%@",appName] logoPosiation:config.LAUNCH_location];
        
        NSString *fromPath =[[[[NSBundle mainBundle] bundlePath] stringByAppendingFormat:@"/%@.bundle",channelName] stringByAppendingString:@"framework"];
        [fileManager removeItemAtPath:[channeldir stringByAppendingString:@"/Payload/Frameworks/AccessCore.framework"] error:nil];
        NSString *bundlePath =[[[NSBundle mainBundle] bundlePath] stringByAppendingFormat:@"/%@.bundle",channelName];
        [fileManager copyItemAtPath:[bundlePath stringByAppendingString:@"/framework/AccessCore.framework"] toPath:[channeldir stringByAppendingString:@"/Payload/Frameworks/AccessCore.framework"] error:nil];
        
        [self zipDirectory:channeldir toipaPath:[channeldir stringByAppendingString:@".ipa"] forChannelName:channelName];
    }
    NSLog(@"渠道:%@出包完成...",channelName);
}
-(BOOL)unzipFile:(NSString *)filePath toDirectory:(NSString *)dir
{
    NSError *error;
    if ([[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:&error]) {
        ZipArchive *archive = [[ZipArchive alloc] init];
        if ([archive UnzipOpenFile:self.ipaPath]) {
            if ([archive UnzipFileTo:dir overWrite:YES]) {
                return YES;
            }
        }
    }
    return NO;
}
-(BOOL)zipDirectory:(NSString *)dir toipaPath:(NSString *)ipaPath forChannelName:(NSString *)channelname;
{
    ZipArchive *archive = [[ZipArchive alloc] init];
    if ([archive CreateZipFile2:ipaPath]) {
        NSFileManager *manager =[NSFileManager defaultManager];
        NSDirectoryEnumerator *enumerator = [manager enumeratorAtPath:dir];
        NSString * itemPath;
        while ((itemPath = enumerator.nextObject)) {
            BOOL isdir;
            NSString *fromPath = [dir stringByAppendingPathComponent:itemPath];
            if ([manager fileExistsAtPath:fromPath isDirectory:&isdir]&&!isdir) {
                [archive addFileToZip:fromPath newname:itemPath];
            }
        }
        return  [archive CloseZipFile2];
    }
    return NO;
}
-(BOOL)replaceIconAtPath:(NSString *)iconPath logoPosiation:(NSString *)posiation
{
    return NO;
}
-(BOOL)modifyPlistWithParams:(NSDictionary *)params
{
    return NO;
}
-(BOOL)resignCodeWithPath:(NSString *)appPath
{
    [[NSTask launchedTaskWithLaunchPath:@"/usr/bin/python" arguments:@[]]  waitUntilExit];
    return NO;
}
- (NSImage *)createImageWithIcon:(NSImage *)icon withCornerImage:(NSImage *)corner
{
    NSSize size = icon.size;
    NSImage *mergedImage = [[NSImage alloc] initWithSize:size];
    [mergedImage lockFocus];
    CGContextRef imageContext = [[NSGraphicsContext currentContext] graphicsPort];
    CGContextDrawImage(imageContext, NSMakeRect(0, 0, size.width, size.height), [self CGImageWithNSImage:icon]);
    CGContextDrawImage(imageContext, NSMakeRect(0, 0, size.width, size.height), [self CGImageWithNSImage:corner]);
    [mergedImage unlockFocus];
    return mergedImage;
}
- (CGImageRef)CGImageWithNSImage:(NSImage*)image;
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
