//
//  ApkIconImageView.h
//  ApkManager
//
//  Created by WeiKeting on 09/08/2014.
//  Copyright (c) 2014年 weiketing.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol ApkDraggedProtocol

- (void)onApkDragged:(NSURL*)fileURL;

@end

@interface ApkIconImageView : NSImageView <NSDraggingDestination>

@property id<ApkDraggedProtocol> apkDraggedDelegate;

@end
