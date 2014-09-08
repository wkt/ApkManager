//
//  Document.m
//  ApkManager
//
//  Created by WeiKeting on 09/06/2014.
//  Copyright (c) 2014年 weiketing.com. All rights reserved.
//

#import "Document.h"
#import "ApkFile.h"
#import "DocumentWindowController.h"

@implementation Document

- (id)init
{
    self = [super init];
    if (self) {
        // Add your subclass-specific initialization here.
    }
    NSLog(@"init:%p\n",self);
    return self;
}


- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
    NSLog(@"%s aController:%@\n",__FUNCTION__,aController);
    [self updateUI];

}

+ (BOOL)autosavesInPlace
{
    return NO;
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to write your document to data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning nil.
    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
    NSException *exception = [NSException exceptionWithName:@"UnimplementedMethod" reason:[NSString stringWithFormat:@"%@ is unimplemented", NSStringFromSelector(_cmd)] userInfo:nil];
    @throw exception;
    return nil;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to read your document from the given data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning NO.
    // You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead.
    // If you override either of these, you should also override -isEntireFileLoaded to return NO if the contents are lazily loaded.
//    NSException *exception = [NSException exceptionWithName:@"UnimplementedMethod" reason:[NSString stringWithFormat:@"%@ is unimplemented", NSStringFromSelector(_cmd)] userInfo:nil];
//    @throw exception;
    NSLog(@"readFromData:%p",self);
    return YES;
}

- (void)makeWindowControllers {
    NSArray *myControllers = [self windowControllers];
    if(!mDocumentWindowController){
        mDocumentWindowController = [[DocumentWindowController alloc] init];
        [_apkFile setApkLoading:mDocumentWindowController];
        [_apkFile loadApk];
    }
    // If this document displaced a transient document, it will already have been assigned a window controller. If that is not the case, create one.
    if ([myControllers count] == 0) {
        [self addWindowController: mDocumentWindowController];
    }
}


- (BOOL)readFromFileWrapper:(NSFileWrapper *)fileWrapper ofType:(NSString *)typeName error:(NSError **)outError
{
    NSLog(@"readFromFileWrapper:%p",self);
    NSLog(@"fileURL:%@",[self fileURL]);
    return [super readFromFileWrapper:fileWrapper ofType:typeName error:outError];
}

- (void)setFileURL:(NSURL *)absoluteURL
{
    
    NSLog(@"\n\n%s mDocumentWindowController:%@\n\n\n",__FUNCTION__,mDocumentWindowController);
    [super setFileURL:absoluteURL];

    [_apkFile setApkLoading:Nil];
    _apkFile = [[ApkFile alloc] initWithURL:absoluteURL];
    
    if(mDocumentWindowController){
        [_apkFile setApkLoading:mDocumentWindowController];
        [_apkFile loadApk];
    }
}

- (void)updateUI
{
    [mDocumentWindowController updateUI];
}

@end
