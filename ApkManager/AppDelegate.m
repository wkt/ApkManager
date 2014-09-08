//
//  AppDelegate.m
//  ApkManager
//
//  Created by WeiKeting on 09/06/2014.
//  Copyright (c) 2014年 weiketing.com. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSLog(@"%s\n",__FUNCTION__);
}

- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename
{

    NSLog(@"%s:%@\n",__FUNCTION__,filename);
    return NO;

}

- (void)application:(NSApplication *)sender openFiles:(NSArray *)filenames
{
    //open recent
    NSLog(@"%s:%@\n",__FUNCTION__,filenames);
    
}

@end
