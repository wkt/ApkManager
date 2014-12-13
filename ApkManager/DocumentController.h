//
//  DocumentController.h
//  ApkManager
//
//  Created by WeiKeting on 09/06/2014.
//  Copyright (c) 2014年 weiketing.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "UsbUtils.h"
@interface DocumentController : NSDocumentController <AMUsbMonitor>

@property (strong)  NSArray *devicesArray;

- (void)refreshDevices:(id)sender;

@end
