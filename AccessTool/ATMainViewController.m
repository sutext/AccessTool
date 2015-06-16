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
@property(nonatomic,strong)NSString *workingPath;
@property(nonatomic,strong)NSFileHandle *handle;
@end
@implementation ATMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.chooseButton.target=self;
    self.chooseButton.action=@selector(chooseFile);
    self.startButton.target=self;
    self.startButton.action=@selector(startAction);
    self.selectAll.target = self;
    self.selectAll.action = @selector(selectAllAction);
    self.workingPath=[NSHomeDirectory() stringByAppendingString:@"/Downloads/kuaifaPakages"];
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
-(void)startAction
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self startPackage];
    });
}
-(void)selectAllAction
{
    [self.channelView.subviews enumerateObjectsUsingBlock:^(NSButton *channel, NSUInteger idx, BOOL *stop) {
        channel.state=1;
    }];
}
-(void)showAlertMessage:(NSString *)message
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = message;
        [alert addButtonWithTitle:@"确定"];
        [alert beginSheetModalForWindow:self.view.window completionHandler:nil];
    });
}

-(void)setControlEnable:(BOOL)enable
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.channelView.subviews enumerateObjectsUsingBlock:^(NSButton *channel, NSUInteger idx, BOOL *stop) {
            channel.enabled = enable;
        }];
        self.chooseButton.enabled=enable;
        self.startButton.enabled=enable;
    });
    
}
-(void)setInfoLabelText:(NSString *)text
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.infoLabel.stringValue = text;
    });
}
-(void)logEnvent:(NSString *)message
{
    if (message) {
        [self setInfoLabelText:message];
        [self.handle writeData:[message dataUsingEncoding:NSUTF8StringEncoding]];
    }
}
-(void)startPackage
{
    if (!self.ipaPath.length) {
        [self showAlertMessage:@"请选择母包!"];
        return;
    }
    if (![self.ipaPath hasSuffix:@".ipa"]) {
        [self showAlertMessage:@"请选择ipa母包"];
        return;
    }
    [self setControlEnable:NO];
    NSFileManager *filemanager = [NSFileManager defaultManager];
    [filemanager removeItemAtPath:self.workingPath error:nil];
    NSString *originDir = [self.workingPath stringByAppendingString:@"/origin"];
    [filemanager createDirectoryAtPath:originDir withIntermediateDirectories:YES attributes:nil error:nil];
    NSString *logPath =[self.workingPath stringByAppendingString:@"/pack.log"];
    [filemanager createFileAtPath:logPath contents:nil attributes:nil];
    self.handle = [NSFileHandle fileHandleForWritingAtPath:logPath];
    if ([self unzip:self.ipaPath toDir:originDir]) {
        [self logEnvent:@"校验母包文件开始...\n"];
        NSString *payloadPath = [originDir stringByAppendingString:@"/Payload"];
        NSArray *subcontent = [filemanager contentsOfDirectoryAtPath:payloadPath error:nil];
        __block NSString *appName;
        [subcontent enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
            if ([obj hasSuffix:@".app"]) {
                appName = obj;
            }
        }];
        if (appName) {
            [self logEnvent:@"母包文件校验成功...\n"];
            [filemanager removeItemAtPath:[payloadPath stringByAppendingFormat:@"/%@/_CodeSignature",appName] error:nil];
            [[NSFileManager defaultManager] removeItemAtPath:[payloadPath stringByAppendingFormat:@"/%@/archived-expanded-entitlements.xcent",appName] error:nil];
            NSString *provisionPath =[payloadPath stringByAppendingFormat:@"/%@/embedded.mobileprovision",appName];
            [filemanager removeItemAtPath:provisionPath error:nil];
            [filemanager copyItemAtPath:[[NSBundle mainBundle] pathForResource:@"kuaifa_adhoc" ofType:@"mobileprovision"] toPath:provisionPath error:nil];
            [self.channelView.subviews enumerateObjectsUsingBlock:^(NSButton *channel, NSUInteger idx, BOOL *stop) {
                if (channel.state) {
                    ATConfigReadCode code;
                    NSString *channelName = channel.title;
                    ATChannelConfig *config = [ATChannelConfig configWithName:channelName inConfigFile:[self.workingPath stringByAppendingFormat:@"/origin/Payload/%@/channel.xml",appName] code:&code];
                    NSString *configErrorMessage = nil;
                    switch (code) {
                        case ATConfigReadCodeXMLNotExist:
                            configErrorMessage =[NSString stringWithFormat:@"渠道:%@  缺少chanel.xml文件.\n",channelName];
                            break;
                        case ATConfigReadCodeXMLFormatError:
                            configErrorMessage =[NSString stringWithFormat:@"渠道:%@  chanel.xml 配置文件格式有误.\n",channelName];
                            break;
                        case ATConfigReadCodeChannelNotExist:
                            configErrorMessage =[NSString stringWithFormat:@"渠道:%@  chanel.xml中没找到渠道:%@的配置项.\n",channelName,channelName];
                            break;
                        default:
                            break;
                    }
                    [self logEnvent:configErrorMessage];
                    if (!configErrorMessage) {
                        [self packgeForNmae:channelName appName:appName config:config];
                    }
                    
                }
            }];
        }
        else
        {
            [self logEnvent:@"母包文件校验失败，停止打包...\n"];
        }
    }
    [filemanager removeItemAtPath:originDir error:nil];
    [self logEnvent:@"打包结束.\n"];
    [self.handle closeFile];
    self.handle=nil;
    [self setControlEnable:YES];
}
-(void)packgeForNmae:(NSString *)channelName appName:(NSString *)appName config:(ATChannelConfig *)config;
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:[[[NSBundle mainBundle] resourcePath] stringByAppendingFormat:@"/%@.bundle",config.CHName]]) {
        [self logEnvent:[NSString stringWithFormat:@"渠道:%@  未找到资源包%@.bundle\n",config.CHName,config.CHName]];
        return;
    }
    [self logEnvent:[NSString stringWithFormat:@"渠道:%@  开始出包.....................................................\n",channelName]];
    NSString *origindir = [self.workingPath stringByAppendingString:@"/origin"];
    NSString *channeldir = [self.workingPath stringByAppendingPathComponent:channelName];
    [[NSFileManager defaultManager] copyItemAtPath:origindir toPath:channeldir error:nil];
    [self replaceIconWithAppName:appName channeldir:channeldir config:config];
    [self replaceLanchWithAppName:appName channeldir:channeldir config:config];
    [self modifyPlistWithAppName:appName channeldir:channeldir config:config];
    [self replaceResourceWithAppName:appName channeldir:channeldir config:config];
    [self resignWithAppName:appName channeldir:channeldir config:config];
    [[NSFileManager defaultManager] removeItemAtPath:channeldir error:nil];
}
-(BOOL)unzip:(NSString *)filePath toDir:(NSString *)dir
{
    [self logEnvent:@"解压母包开始.......\n"];
    NSTask *task = [NSTask launchedTaskWithLaunchPath:@"/usr/bin/unzip" arguments:@[@"-q",self.ipaPath,@"-d",dir]] ;
    [task waitUntilExit];
    if (task.terminationStatus==0) {
        [self logEnvent:@"解压母包成功.......\n"];
        return YES;
    }
    else
    {
        [self logEnvent:@"解压母包失败停止出包.......\n"];
        return NO;
    }
}
-(BOOL)zip:(NSString *)srcPath toPath:(NSString *)toPath
{
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/usr/bin/zip"];
    [task setArguments:@[@"-q",@"-r",toPath,@"."]];
    [task setCurrentDirectoryPath:srcPath];
    [task launch];
    [task waitUntilExit];
    return task.terminationStatus==0;
}
-(void)replaceIconWithAppName:(NSString *)appname channeldir:(NSString *)channeldir config:(ATChannelConfig *)config
{
    [self logEnvent:[NSString stringWithFormat:@"渠道:%@  开始设置角标.\n",config.CHName]];
    NSString *appPath = [channeldir stringByAppendingFormat:@"/Payload/%@",appname];
    [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:appPath error:nil] enumerateObjectsUsingBlock:^(NSString *fileNmae, NSUInteger idx, BOOL *stop) {
        if ([fileNmae hasPrefix:@"AppIcon"]&&[fileNmae hasSuffix:@".png"]) {
            NSString *iconPath = [appPath stringByAppendingPathComponent:fileNmae];
            NSString *maskPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingFormat:@"/%@.bundle/icons/icon_%@.png",config.CHName,config.LAUNCH_location];
            if (![self replaceIconAtPath:iconPath maskPath:maskPath]) {
                [self logEnvent:[NSString stringWithFormat:@"渠道:%@  生成角标文件:%@失败.\n",config.CHName,fileNmae]];
            }
            else
            {
                [self logEnvent:[NSString stringWithFormat:@"渠道:%@  生成角标文件:%@成功.\n",config.CHName,fileNmae]];
            }
        }
    }];
    [self logEnvent:[NSString stringWithFormat:@"渠道:%@  设置角标结束.\n",config.CHName]];
}
-(void)replaceLanchWithAppName:(NSString *)appname channeldir:(NSString *)channeldir config:(ATChannelConfig *)config
{
    [self logEnvent:[NSString stringWithFormat:@"渠道:%@  开始设置启动图.\n",config.CHName]];
    
    [self logEnvent:[NSString stringWithFormat:@"渠道:%@  设置启动图完成.\n",config.CHName]];
}
-(void)modifyPlistWithAppName:(NSString *)appname channeldir:(NSString *)channeldir config:(ATChannelConfig *)config
{
    [self logEnvent:[NSString stringWithFormat:@"渠道:%@  开始修改info.plist文件.\n",config.CHName]];
    NSString *plistPath =[channeldir stringByAppendingFormat:@"/Payload/%@/Info.plist",appname];
    NSMutableDictionary *mdic = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
    if (config.BundleID&&config.BundleID.length) {
        [mdic setValue:config.BundleID forKey:@"CFBundleIdentifier"];
    }
    else
    {
        [self logEnvent:[NSString stringWithFormat:@"渠道:%@  的BundleID配置项为空,保持原有配置.\n",config.CHName]];
    }
    if (config.BundleDisplayName&&config.BundleDisplayName.length) {
        [mdic setValue:config.BundleDisplayName forKey:@"CFBundleDisplayName"];
    }
    else
    {
        [self logEnvent:[NSString stringWithFormat:@"渠道:%@  的BundleDisplayName配置项为空,保持原有配置.\n",config.CHName]];
    }
    if (config.BundleVersion&&config.BundleVersion.length) {
        [mdic setValue:config.BundleVersion forKey:@"CFBundleVersion"];
    }
    else
    {
        [self logEnvent:[NSString stringWithFormat:@"渠道:%@  的BundleVersion配置项为空,保持原有配置.\n",config.CHName]];
    }
    NSMutableArray *urlTypes = [[mdic objectForKey:@"CFBundleURLTypes"] mutableCopy]?:[NSMutableArray array];
    if (config.AlipayScheme_Prefix&&config.AlipayScheme_Prefix.length) {
        NSString *urlname = [mdic[@"CFBundleIdentifier"] stringByAppendingString:@".alipay"];
        NSDictionary *urlType = @{@"CFBundleTypeRole":@"Editor",
                                  @"CFBundleURLName":urlname,
                                  @"CFBundleURLSchemes":@[config.AlipayScheme_Prefix]};
        [urlTypes addObject:urlType];
        [self logEnvent:[NSString stringWithFormat:@"渠道:%@  设置alipay URLScheme :%@.完成\n",config.CHName,config.AlipayScheme_Prefix]];
    }
    if (config.AppScheme_Prefix&&config.AppScheme_Prefix.length) {
        NSString *urlname = [mdic[@"CFBundleIdentifier"] stringByAppendingFormat:@".%@",config.AppScheme_Prefix];
        NSDictionary *urlType = @{@"CFBundleTypeRole":@"Editor",
                                  @"CFBundleURLName":urlname,
                                  @"CFBundleURLSchemes":@[config.AppScheme_Prefix]};
        [urlTypes addObject:urlType];
        [self logEnvent:[NSString stringWithFormat:@"渠道:%@  设置app URLScheme :%@.完成\n",config.CHName,config.AlipayScheme_Prefix]];
    }
    [mdic setValue:urlTypes forKey:@"CFBundleURLTypes"];
    [[NSFileManager defaultManager] removeItemAtPath:plistPath error:nil];
    [mdic writeToFile:plistPath atomically:YES];
    [self logEnvent:[NSString stringWithFormat:@"渠道:%@  修改info.plist文件结束.\n",config.CHName]];
}
-(void)replaceResourceWithAppName:(NSString *)appname channeldir:(NSString *)channeldir config:(ATChannelConfig *)config
{
    [self logEnvent:[NSString stringWithFormat:@"渠道:%@  开始拷贝资源文件.\n",config.CHName]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *appPath = [channeldir stringByAppendingFormat:@"/Payload/%@",appname];
    NSString *srcFrameworks =  [[[NSBundle mainBundle] resourcePath] stringByAppendingFormat:@"/%@.bundle/frameworks",config.CHName];
    NSString *targeFrameworks = [appPath stringByAppendingString:@"/Frameworks"];
    NSError *error;
    NSArray *srcItems = [fileManager contentsOfDirectoryAtPath:srcFrameworks error:nil];
    if (!error&&srcItems.count) {
        [srcItems enumerateObjectsUsingBlock:^(NSString * itemNmae, NSUInteger idx, BOOL *stop) {
            [self logEnvent:[NSString stringWithFormat:@"渠道:%@  开始拷贝文件:%@.\n",config.CHName,itemNmae]];
            if ([itemNmae hasSuffix:@".framework"]) {
                NSString *srcItemPath =[srcFrameworks stringByAppendingPathComponent:itemNmae];
                NSString *targetPath = [targeFrameworks stringByAppendingPathComponent:itemNmae];
                [fileManager removeItemAtPath:targetPath error:nil];
                [fileManager copyItemAtPath:srcItemPath toPath:targetPath error:nil];
                
                [[fileManager contentsOfDirectoryAtPath:srcItemPath error:nil] enumerateObjectsUsingBlock:^(NSString * fileName, NSUInteger idx, BOOL *stop) {
                    if ([fileName hasSuffix:@".bundle"])
                    {
                        [fileManager removeItemAtPath:[appPath stringByAppendingPathComponent:fileName] error:nil];
                        [fileManager copyItemAtPath:[srcItemPath stringByAppendingPathComponent:fileName] toPath:[appPath stringByAppendingPathComponent:fileName] error:nil];
                    }
                }];
            }
            else if ([itemNmae hasSuffix:@".bundle"])
            {
                NSString *targetBundle =[appPath stringByAppendingPathComponent:itemNmae];
                [fileManager removeItemAtPath:targetBundle error:nil];
                [fileManager copyItemAtPath:[srcFrameworks stringByAppendingPathComponent:itemNmae] toPath:targetBundle error:nil];
            }
            [self logEnvent:[NSString stringWithFormat:@"渠道:%@  拷贝文件:%@完成.\n",config.CHName,itemNmae]];
        }];
    }
    [self logEnvent:[NSString stringWithFormat:@"渠道:%@  拷贝资源文件完成.\n",config.CHName]];
}
-(void)resignWithAppName:(NSString *)appname channeldir:(NSString *)channeldir config:(ATChannelConfig *)config
{
    [self logEnvent:[NSString stringWithFormat:@"渠道:%@  app重签名开始.\n",config.CHName]];
    NSString *appPath = [channeldir stringByAppendingFormat:@"/Payload/%@",appname];
    NSString *ipaPath = [channeldir stringByAppendingString:@".ipa"];
    NSString *entitlementsPath = [[NSBundle mainBundle] pathForResource:@"entitlements" ofType:@"plist"];
    NSString *sign = @"iPhone Distribution: Le Sun (W6UXGK87A8)";
    NSString *frameworksPath = [appPath stringByAppendingString:@"/Frameworks"];
    [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:frameworksPath error:nil] enumerateObjectsUsingBlock:^(NSString * obj, NSUInteger idx, BOOL *stop) {
        if ([obj hasSuffix:@".framework"]) {
            NSString *fmmkPath = [frameworksPath stringByAppendingPathComponent:obj];
            [[NSTask launchedTaskWithLaunchPath:@"/usr/bin/codesign" arguments:@[@"-f",@"-s",sign,@"--resource-rules",[appPath stringByAppendingString:@"/ResourceRules.plist"],fmmkPath]]  waitUntilExit];
        }
    }];
    NSTask *signTask = [NSTask launchedTaskWithLaunchPath:@"/usr/bin/codesign" arguments:@[@"-f",@"-s",sign,@"--resource-rules",[appPath stringByAppendingString:@"/ResourceRules.plist"],[NSString stringWithFormat:@"--entitlements=%@",entitlementsPath],appPath]] ;
    [signTask waitUntilExit];
    if (signTask.terminationStatus==0) {
        [self logEnvent:[NSString stringWithFormat:@"渠道:%@  app重签名成功.\n",config.CHName]];
        [self logEnvent:[NSString stringWithFormat:@"渠道:%@  开始压缩生成ipa.\n",config.CHName]];
        if ([self zip:channeldir toPath:ipaPath]) {
            [self logEnvent:[NSString stringWithFormat:@"渠道:%@  出包成功.....................................................\n",config.CHName]];
        }
        else
        {
            [self logEnvent:[NSString stringWithFormat:@"渠道:%@  压缩app失败\n",config.CHName]];
        }
    }
    else
    {
        [self logEnvent:[NSString stringWithFormat:@"渠道:%@  app重签名失败.\n",config.CHName]];
    }
}
-(BOOL)replaceIconAtPath:(NSString *)iconPath maskPath:(NSString *)maskPath
{
    NSImage *icon = [[NSImage alloc] initWithContentsOfFile:iconPath];
    NSImage *mask = [[NSImage alloc] initWithContentsOfFile:maskPath];
    if (!mask) {
        [self logEnvent:@"角标文件不存在.\n"];
        return NO;
    }
    NSImage *result = [self createImageWithIcon:icon withCornerImage:mask];
    if (result) {
        [self logEnvent:@"合成角标成功.\n"];
        return  [[result TIFFRepresentation] writeToFile:iconPath atomically:YES];
    }
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
#pragma mark other zip lib
-(BOOL)resignWithAppName_xcrun:(NSString *)appname channeldir:(NSString *)channeldir
{
    NSString *appPath = [channeldir stringByAppendingFormat:@"/Payload/%@",appname];
    NSString *ipaPath = [channeldir stringByAppendingString:@".ipa"];
    NSString *provisionPath = [[NSBundle mainBundle] pathForResource:@"danzhu_adhoc" ofType:@"mobileprovision"];
    NSString *sign = @"iPhone Distribution: Le Sun (W6UXGK87A8)";
    NSTask *task =[NSTask launchedTaskWithLaunchPath:@"/usr/bin/xcrun" arguments:@[@"-sdk",@"iphoneos",@"PackageApplication",@"-v",appPath,@"-o",ipaPath,@"--sign",sign,@"--embed",provisionPath]];
    [task  waitUntilExit];
    return (task.terminationStatus==0);
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
@end
