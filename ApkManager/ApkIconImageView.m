//
//  ApkIconImageView.m
//  ApkManager
//
//  Created by WeiKeting on 09/08/2014.
//  Copyright (c) 2014年 weiketing.com. All rights reserved.
//

#import "ApkIconImageView.h"

@implementation ApkIconImageView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NSMutableArray *types = [[NSMutableArray alloc] initWithCapacity:1];
        [types addObject:NSURLPboardType];
        [self registerForDraggedTypes:types];

    }

    return self;
}


- (NSDragOperation)draggingEntered:(id < NSDraggingInfo >)sender
{
    
    NSDragOperation ret = NSDragOperationNone;
    NSPasteboard *pboard = [sender draggingPasteboard];
    
    if ( [[pboard types] containsObject:NSURLPboardType] ) {
        NSURL *fileURL = [NSURL URLFromPasteboard:pboard];
        if([[[fileURL path] lowercaseString] hasSuffix:@".apk"])
            ret =NSDragOperationCopy;
    }
    
    return ret;
}

- (void)draggingExited:(id <NSDraggingInfo>)sender
{
    /*------------------------------------------------------
     method called whenever a drag exits our drop zone
     --------------------------------------------------------*/
    [self setNeedsDisplay: YES];
}

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender
{
    /*------------------------------------------------------
     method to determine if we can accept the drop
     --------------------------------------------------------*/
    
    return YES;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
    /*------------------------------------------------------
     method that should handle the drop data
     --------------------------------------------------------*/
    NSPasteboard *pboard = [sender draggingPasteboard];
    
    if ( [[pboard types] containsObject:NSURLPboardType] ) {
        NSURL *fileURL = [NSURL URLFromPasteboard:pboard];
        [_apkDraggedDelegate onApkDragged:fileURL];
    }
    return YES;
}


@end
