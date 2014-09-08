//
//  AdbDevice.h
//  ApkManager
//
//  Created by WeiKeting on 09/07/2014.
//  Copyright (c) 2014年 weiketing.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AdbDevice : NSObject

@property (readonly) NSString *displayName;
@property (readonly) NSString *brand;
@property (readonly) NSString *model;
@property (readonly) NSString *osVersion;
@property (readonly) NSString *deviceId;


-(int) installApk:(NSString*)apkFilename message:(NSString **)msg;
-(NSString*) toString;


+(NSArray*) getDevices;
+(void) killServer;
+(void) startServer;

@end
