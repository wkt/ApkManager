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
    //NSLog(@"init:%p\n",self);
    return self;
}


- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
    //NSLog(@"%s aController:%@\n",__FUNCTION__,aController);
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
    //NSLog(@"readFromData:%p",self);
    //NSLog(@"%s:%p\n",__FUNCTION__,self);
    return _apkFile && [_apkFile testApk] ?YES:NO;
}

- (void)makeWindowControllers {
    NSArray *myControllers = [self windowControllers];
    if(!_documentWindowController){
        _documentWindowController = [[DocumentWindowController alloc] init];
        [_apkFile setApkLoading:_documentWindowController];
        [_apkFile loadApk];
        [self updateUI];
    }
    // If this document displaced a transient document, it will already have been assigned a window controller. If that is not the case, create one.
    if ([myControllers count] == 0) {
        [self addWindowController: _documentWindowController];
    }
}


- (BOOL)readFromFileWrapper:(NSFileWrapper *)fileWrapper ofType:(NSString *)typeName error:(NSError **)outError
{
    return [super readFromFileWrapper:fileWrapper ofType:typeName error:outError];
}

- (void)setFileURL:(NSURL *)absoluteURL
{
    //NSLog(@"%s:%p\n",__FUNCTION__,self);
    [super setFileURL:absoluteURL];

    [_apkFile setApkLoading:Nil];
    _apkFile = [[ApkFile alloc] initWithURL:absoluteURL];
    
    if(_documentWindowController){
        [_apkFile setApkLoading:_documentWindowController];
        [_apkFile loadApk];
    }
}

- (void)updateUI
{
    [_documentWindowController updateUI];
}

-(DocumentController *)documentController
{
    return [[self windowControllers] objectAtIndex:0];
}
@end
