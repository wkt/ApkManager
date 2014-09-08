//
//  ApkFile.h
//  ApkManager
//
//  Created by WeiKeting on 09/07/2014.
//  Copyright (c) 2014年 weiketing.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ApkLoadingProtocol

- (void)onStart:(id)apkfile;
- (void)onFinish:(id)apkfile;

@end


@interface ApkFile : NSObject {
    long _fileSize;
    long _versionCode;
}

@property id<ApkLoadingProtocol> apkLoading;

@property (readonly) NSString *apkFilename;

@property (readonly) NSImage* icon;
@property (readonly) NSString* displayName;
@property (readonly) NSString* packageName;
@property (readonly) NSString* versionName;

- (ApkFile*) initWithPath:(NSString *)path;
- (ApkFile*) initWithURL:(NSURL *)url;

- (long) fileSize;
- (long) versionCode;

///non block operation
- (void) loadApk;

@end
