//
//  DocumentWindowController.h
//  ApkManager
//
//  Created by WeiKeting on 09/07/2014.
//  Copyright (c) 2014年 weiketing.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ApkFile.h"
#import "AdbDevice.h"
#import "ApkIconImageView.h"

@interface DocumentWindowController : NSWindowController <ApkLoadingProtocol,ApkDraggedProtocol>
{
    ApkFile *apkFile;
    NSString *currentDeviceId;
    NSArray *_devicesArray;
}

@property (readonly) NSInteger currentDeviceIndex;

@property (weak) IBOutlet NSButton *refreshButton;
@property (weak) IBOutlet ApkIconImageView *apkIcon;
@property (weak) IBOutlet NSTextField *apkDisplayName;
@property (weak) IBOutlet NSButton *installButton;
@property (weak) IBOutlet NSPopUpButton *deviceBox;
@property (strong) IBOutlet NSWindow *sheetWindow;
@property (weak) IBOutlet NSButton *sheetOK;
@property (weak) IBOutlet NSTextField *sheetLabel;
@property (weak) IBOutlet NSProgressIndicator *sheetProgress;

- (IBAction)onHelpClick:(id)sender;
- (IBAction)cancelClick:(id)sender;
- (IBAction)refreshClick:(id)sender;
- (IBAction)installClick:(id)sender;
- (IBAction)endSheetWindow:(id)sender;

- (void)updateUI;
- (void)updateDeviceBox;

@end
