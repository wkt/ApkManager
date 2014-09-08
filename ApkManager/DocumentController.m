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
    //NSLog(@"%s\n",__FUNCTION__);
    NSBundle *main = [NSBundle mainBundle];
    const char *path = getenv("PATH");
    if(path && path[0]){
        NSString *bundleBin=[[main bundlePath]
                             stringByAppendingPathComponent:
                             @"/Contents/Resources/bin"];
        
        path = [[NSString stringWithFormat:@"%@:%s",bundleBin,path] UTF8String];
    }
    NSLog(@"path:%s\n",path);
    setenv("PATH", path, 1);
    [super awakeFromNib];
}


- (id)makeDocumentForURL:(NSURL *)absoluteDocumentURL withContentsOfURL:(NSURL *)absoluteDocumentContentsURL ofType:(NSString *)typeName error:(NSError **)outError
{
    
//    NSLog(@"%s:absoluteDocumentURL:%@,absoluteDocumentContentsURL:%@,typeName:%@,outError:%@\n",
//          __FUNCTION__,
//          absoluteDocumentURL,
//          absoluteDocumentContentsURL,
//          typeName,
//          *outError
//          );
    
    return [super makeDocumentForURL:absoluteDocumentURL withContentsOfURL:absoluteDocumentContentsURL ofType:typeName error:outError];
}

- (id)makeDocumentWithContentsOfURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError
{
//    NSLog(@"%s absoluteURL:%@,typeName:%@,outError:%@\n",
//          __FUNCTION__,
//          absoluteURL,
//          typeName,
//          *outError
//          );
    Document *doc = (Document*) [self currentDocument];
    if([doc fileURL] == NULL){
        [doc close];
        //[doc setFileURL:absoluteURL];
        //return doc;
    }
    return [super makeDocumentWithContentsOfURL:absoluteURL ofType:typeName error:outError];
}

- (void)openDocument:(id)sender
{
    NSLog(@"%s,sender:%@\n",__FUNCTION__,sender);
    [super openDocument:sender];
}

@end
