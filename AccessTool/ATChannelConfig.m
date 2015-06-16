//
//  ATChannelConfig.m
//  AccessTool
//
//  Created by supertext on 15/6/2.
//  Copyright (c) 2015年 forgame. All rights reserved.
//

#import "ATChannelConfig.h"

@interface ATChannelConfig () <NSXMLParserDelegate>

@property(nonatomic,copy,readwrite)NSString *CHName;
@property(nonatomic,copy,readwrite)NSString *CHVersion;
@property(nonatomic,copy,readwrite)NSString *CHAppID;
@property(nonatomic,copy,readwrite)NSString *CHAppKey;
@property(nonatomic,copy,readwrite)NSString *CHGameKey;
@property(nonatomic,copy,readwrite)NSString *CHGameChannel;
@property(nonatomic,copy,readwrite)NSString *CHPrivateKey;
@property(nonatomic,copy,readwrite)NSString *CHServerNumber;
@property(nonatomic,copy,readwrite)NSString *CPAutoLogin;
@property(nonatomic,copy,readwrite)NSString *CPForceUpdate;
@property(nonatomic,copy,readwrite)NSString *CPShowPopover;
@property(nonatomic,copy,readwrite)NSString *CPPopoverPosiation;
@property(nonatomic,copy,readwrite)NSString *CPScreenOrientation;

@property(nonatomic,copy,readwrite)NSString *DEV_ISDebugModel;
@property(nonatomic,copy,readwrite)NSString *DATA_Product;
@property(nonatomic,copy,readwrite)NSString *PAY_MerchantId;
@property(nonatomic,copy,readwrite)NSString *PAY_NotifiyURL;
@property(nonatomic,copy,readwrite)NSString *PAY_SellerPrivateInfo;
@property(nonatomic,copy,readwrite)NSString *AppScheme_Prefix;
@property(nonatomic,copy,readwrite)NSString *AlipayScheme_Prefix;
@property(nonatomic,copy,readwrite)NSString *BundleID;
@property(nonatomic,copy,readwrite)NSString *BundleVersion;
@property(nonatomic,copy,readwrite)NSString *BundleDisplayName;
@property(nonatomic,copy,readwrite)NSString *ICON_NEED_SETTING;
@property(nonatomic,copy,readwrite)NSString *ICON_location;
@property(nonatomic,copy,readwrite)NSString *LAUNCH_NEED_SETTING;
@property(nonatomic,copy,readwrite)NSString *LAUNCH_location;

@property(nonatomic, strong)NSMutableDictionary *configDict;
@property(nonatomic, strong)NSString *currentTagName;
@property(nonatomic)BOOL findedCPName;

@end
@implementation ATChannelConfig
+(instancetype)configWithName:(NSString *)cpname inConfigFile:(NSString *)xmlfile code:(inout ATConfigReadCode *)codeptr
{
    ATChannelConfig *config = [[self alloc] init];
    ATConfigReadCode code = [config readWithCPName:cpname inConfigFile:xmlfile];
    if (codeptr) {
        *codeptr=code;
    }
    return (*codeptr==ATConfigReadCodeSucceed)?config:nil;
}
-(ATConfigReadCode)readWithCPName:(NSString *)cpname inConfigFile:(NSString *)xmlfile
{
    if (!cpname) {
        return ATConfigReadCodeChannelNotExist;
    }
    if (!xmlfile) {
        return  ATConfigReadCodeXMLNotExist;
    }
    self.configDict=[NSMutableDictionary dictionary];
    self.CHName = cpname;
    BOOL isdir;
    if ([[NSFileManager defaultManager] fileExistsAtPath:xmlfile isDirectory:&isdir]&&!isdir) {
        NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:[NSURL fileURLWithPath:xmlfile]];
        parser.delegate = self;
        [parser parse];
        if (parser.parserError) {
            return ATConfigReadCodeXMLFormatError;
        }
        if (self.configDict.count) {
            [self.configDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                [self setValue:obj forKey:key];
            }];
            return ATConfigReadCodeSucceed;
        }
        else
        {
            return ATConfigReadCodeChannelNotExist;
        }
    }
    else
    {
        return ATConfigReadCodeXMLNotExist;
    }
   
}
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if ([elementName isEqualToString:@"channel"]&&[[attributeDict objectForKey:@"chname"] isEqualToString:self.CHName]) {
        self.findedCPName=YES;
    }
    else if (self.findedCPName) {
        self.currentTagName = elementName;
    }
}
-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:@"channel"]) {
        self.findedCPName=NO;
    }
}
-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([string isEqualToString:@""]) {
        return;
    }
    if (self.findedCPName&&self.currentTagName) {
        [self.configDict setValue:string forKey:self.currentTagName];
    }
}
@end