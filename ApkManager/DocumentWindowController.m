//
//  DocumentWindowController.m
//  ApkManager
//
//  Created by WeiKeting on 09/07/2014.
//  Copyright (c) 2014年 weiketing.com. All rights reserved.
//

#import "DocumentWindowController.h"
#include "glib.h"

@implementation DocumentWindowController

- (id)init
{
    self = [super initWithWindowNibName:@"DocumentWindow"];
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    [_apkIcon setApkDraggedDelegate:self];
    [self setDevicesArray:[[NSDocumentController sharedDocumentController] devicesArray] ];
    [self updateDeviceBox];
}

- (IBAction)onHelpClick:(id)sender {
    //g_spawn_command_line_async("open http://xx51.net/jump/apkmanager-adb.help", NULL);
    [[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString:@"http://xx51.net/jump/apkmanager-adb.help"]];
}

- (IBAction)cancelClick:(id)sender
{
    if(![_refreshButton isEnabled])return;
    [[self document] close];
}

- (IBAction)refreshClick:(id)sender {
    //[self updateDeviceArray:YES];
    NSLog(@"%s: sender: %@ documentController:%@",__FUNCTION__,sender,_documentController);
    [[NSDocumentController sharedDocumentController] refreshDevices:sender];
}

- (IBAction)installClick:(id)sender {
    [NSApp beginSheet:_sheetWindow modalForWindow:[_installButton window] modalDelegate:Nil didEndSelector:Nil contextInfo:Nil];
    [_sheetOK setEnabled:NO];
    AdbDevice *ad = [_devicesArray objectAtIndex:_currentDeviceIndex];
    [_sheetWindow setTitle:@"Installing"];;
    [_sheetLabel setStringValue:NSLocalizedString(@"Installing ...","")];
    [_sheetOK setEnabled:NO];
    [_sheetProgress setHidden:NO];
    [_sheetProgress startAnimation:_installButton];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *msg = NULL;
        gint st =
        [ad installApk:[apkFile apkFilename] message:&msg];
        dispatch_async(dispatch_get_main_queue(), ^{
            if(st==0){
                [_sheetWindow setTitle:@"Success"];
            }else{
                [_sheetWindow setTitle:@"Failed"];
            }
            [_sheetLabel setStringValue:msg];
            [_sheetOK setEnabled:YES];
            [_sheetProgress setHidden:YES];
            [_sheetProgress stopAnimation:_installButton];

        });
    });
}

- (IBAction)endSheetWindow:(id)sender {
    [NSApp endSheet:_sheetWindow];
    [_sheetWindow orderOut:sender];
}


- (void)onFinish:(id)apkfile
{
    apkFile = apkfile;
    [self updateUI];
    [_installButton setEnabled:apkFile && _devicesArray && [_devicesArray count]>0?YES:NO];
    
    //NSLog(@"%s\n",__FUNCTION__);
}

- (void)onStart:(id)apkfile
{
    apkFile = Nil;
    [self updateUI];
    
    //NSLog(@"%s\n",__FUNCTION__);
    
}

- (void)updateUI
{
    if(apkFile == Nil){
        [_apkDisplayName setStringValue:NSLocalizedString(@"Loading ...",@"")];
        [_installButton setEnabled:NO];
    }else{
        [_apkDisplayName setStringValue:
                [NSString stringWithFormat:
                 @"%@ %@",[apkFile displayName],[apkFile fullVersion]
                 ]
         ];
        [_apkIcon setImage:[apkFile icon]];
    }
}

- (void)updateDeviceBox
{
    NSMenu *menu = [_deviceBox menu];
    [menu removeAllItems];

    [_refreshButton setEnabled:YES];
    
    NSLog(@"_devicesArray:%@",_devicesArray);
    if(_devicesArray == Nil || [_devicesArray count] ==0){
        [_installButton setEnabled:NO];
        return;
    };
    [_deviceBox setEnabled:YES];
    [_installButton setEnabled:YES];
    _currentDeviceIndex = 0;
    for(int i=0;i<[_devicesArray count];i++){
        AdbDevice *ad = [_devicesArray objectAtIndex:i];
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:[ad displayName] action:@selector(deviceBoxChanged:) keyEquivalent:@""];
        [item setTag:i];
        [menu addItem:item];
        if([[ad deviceId] isEqualToString:currentDeviceId]){
            _currentDeviceIndex = i;
        }
    }
    [_deviceBox selectItemAtIndex:_currentDeviceIndex];
    [self deviceBoxChanged:_deviceBox];
    [_installButton setEnabled:apkFile && _devicesArray && [_devicesArray count]>0?YES:NO];
}

- (void)deviceBoxChanged:(id)sender
{
    if(_devicesArray == Nil || [_devicesArray count] ==0)return;
    _currentDeviceIndex = [sender tag];
    currentDeviceId = [[_devicesArray objectAtIndex:_currentDeviceIndex] deviceId];
}


-(void)setLoadingDevices
{
    [_refreshButton setEnabled:NO];
    [_deviceBox setEnabled:NO];
    [_installButton setEnabled:NO];
}

- (void)onApkDragged:(NSURL*)fileURL
{
    [[self document] setFileURL:fileURL];
}


@end
