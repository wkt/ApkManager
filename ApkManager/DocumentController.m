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
    NSString *locale = [[NSLocale currentLocale] identifier];
    NSRange re = [locale rangeOfString:@"."];
    NSString *ll = Nil;
    if(re.location == NSNotFound){
        ll = [NSString stringWithFormat:@"%@.UTF-8",locale];
    }else{
        ll = [NSString stringWithFormat:@"%@.UTF-8",[locale substringToIndex:re.location]];
    }
    setenv("LANGUAGE", [ll UTF8String], 1);
    setenv("LANG", [ll UTF8String], 1);
    setenv("LC_ALL", [ll UTF8String], 1);

    NSLog(@"Locale:%@",ll);
    [super awakeFromNib];
}


- (id)makeDocumentForURL:(NSURL *)absoluteDocumentURL withContentsOfURL:(NSURL *)absoluteDocumentContentsURL ofType:(NSString *)typeName error:(NSError **)outError
{
    
    return [super makeDocumentForURL:absoluteDocumentURL withContentsOfURL:absoluteDocumentContentsURL ofType:typeName error:outError];
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

@end
