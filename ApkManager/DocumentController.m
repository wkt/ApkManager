 //
//  DocumentController.m
//  ApkManager
//
//  Created by WeiKeting on 09/06/2014.
//  Copyright (c) 2014年 weiketing.com. All rights reserved.
//

#import "DocumentController.h"
#import "Document.h"
#include <stdlib.h>



@implementation DocumentController

- (void)awakeFromNib {
    NSBundle *main = [NSBundle mainBundle];
    const char *path = getenv("PATH");
    if(path && path[0]){
        NSString *bundleBin=[[main bundlePath]
                             stringByAppendingPathComponent:
                             @"/Contents/Resources/bin"];
        
        path = [[NSString stringWithFormat:@"%@:%s",bundleBin,path] UTF8String];
    }
    //设置命令搜索路径,方便程序调用内置的脚本和命令
    setenv("PATH", path, 1);
    
    //设置locale环境变量,脚本需要它们
    NSString *ll = [[NSLocale preferredLanguages] objectAtIndex:0];
    ll = [ll stringByReplacingOccurrencesOfString:@("-Hans") withString:@("-CN")];
    ll = [ll stringByReplacingOccurrencesOfString:@("-Hant") withString:@("-HK")];
    ll = [ll stringByReplacingOccurrencesOfString:@("-") withString:@("_")];
    system("export");
    setenv("LANGUAGE", [ll UTF8String], 1);
    setenv("LANG", [ll UTF8String], 1);
    setenv("LC_ALL", [ll UTF8String], 1);

    NSLog(@"Locale:%@",ll);
    [super awakeFromNib];
    [UsbUtils setupUSB];
    [UsbUtils addUsbMonitor:self];
    
    [self refreshDevices:Nil killServer:FALSE];
}


- (id)makeDocumentForURL:(NSURL *)absoluteDocumentURL withContentsOfURL:(NSURL *)absoluteDocumentContentsURL ofType:(NSString *)typeName error:(NSError **)outError
{
    
    Document *ret =  [super makeDocumentForURL:absoluteDocumentURL withContentsOfURL:absoluteDocumentContentsURL ofType:typeName error:outError];
    Document *doc = (Document*) [self currentDocument];
    if([doc fileURL] == NULL && ret){
        //打开了文件,留着一个空白窗口也没有什么意思
        [doc close];
    }
    return ret;
    
}

- (id)makeDocumentWithContentsOfURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError
{

    Document *ret = [super makeDocumentWithContentsOfURL:absoluteURL ofType:typeName error:outError];

    Document *doc = (Document*) [self currentDocument];
    if([doc fileURL] == NULL && ret){
        //打开了文件,留着一个空白窗口也没有什么意思
        [doc close];
    }
    return ret;
}

- (void)openDocument:(id)sender
{
    [super openDocument:sender];
}

- (void)added:(UInt32)locationID
{
    [self refreshDevices:self];
}

- (void)removed:(UInt32)locationID
{
    [self refreshDevices:self];
}

- (void)updateDevicesboxs
{
    NSArray *docs=[self documents];
    for(int i=0;i<[docs count];i++){
        [[[docs objectAtIndex:i] documentWindowController] setDevicesArray:_devicesArray];
        [[[docs objectAtIndex:i] documentWindowController] updateDeviceBox];
    }
}

- (void)refreshDevices:(id)sender killServer:(BOOL)killServer
{
    NSArray *docs=[self documents];
    for(int i=0;i<[docs count];i++){
        [[[docs objectAtIndex:i] documentWindowController] setLoadingDevices];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //run in non UI thread
        if(killServer){
            [AdbDevice killServer];
            //usleep(500);
            [AdbDevice startServer];
            usleep(500);
        }
        self.devicesArray = [AdbDevice getDevices];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateDevicesboxs];//run in UI thread
        });
    });
}

- (void)refreshDevices:(id)sender
{
    [self refreshDevices:sender killServer:(self.devicesArray == NULL || [self.devicesArray count]<1)];
}

@end
