//
//  Document.h
//  ApkManager
//
//  Created by WeiKeting on 09/06/2014.
//  Copyright (c) 2014年 weiketing.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ApkFile.h"
#import "DocumentWindowController.h"

@interface Document : NSDocument
{
   DocumentWindowController  *mDocumentWindowController;
}

@property (weak) IBOutlet NSTextField *textFilename;
@property (readonly) ApkFile *apkFile;

@end
