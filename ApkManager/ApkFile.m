//
//  ApkFile.m
//  ApkManager
//
//  Created by WeiKeting on 09/07/2014.
//  Copyright (c) 2014年 weiketing.com. All rights reserved.
//

#import "ApkFile.h"
#import <glib.h>
#include <sys/stat.h>

@implementation ApkFile

- (ApkFile*) initWithPath:(NSString *)path
{
    self = [super init];
    _apkFilename = path;
    _testApk = INT_MAX;
    return self;
}

- (ApkFile*) initWithURL:(NSURL *)url
{
    self = [super init];
    _apkFilename = [url path];
    _testApk = INT_MAX;
    return self;
}

+ (NSString *) sizeToString:(long)size
{
    NSString * ret = NULL;
    if(size <1024){//KB
        ret = [NSString stringWithFormat:@("%ld Byte"),size];
    }else if(size < 1024*1024){//MB
        ret = [NSString stringWithFormat:@("%0.2lf KB"),size/1024.0];
    }else if(size < 1024*1024*1024){//GB
        ret = [NSString stringWithFormat:@("%0.2lf MB"),size/1024.0/1024];
    }else if(size < 1024*1024*1024*1024L){
        ret = [NSString stringWithFormat:@("%0.2lf GB"),size/1024.0/1024/1024];
    }else{
        ret = [NSString stringWithFormat:@("%0.2lf TB"),size/1024.0/1024/1024/1024];
    }
    return ret;
}


- (long) fileSize
{
    if(_fileSize <= 0){
        struct stat st;
        lstat([_apkFilename UTF8String],&st);
        _fileSize = st.st_size;
    }
    return _fileSize;
}


- (long) versionCode;
{
    return _versionCode;
}

- (void) loadApkReal
{
    static const gchar* InfoGroup = "ApkInfo";
    gchar *tmp_keyfile = g_strdup_printf("%s%s.%u_%u.ini",
                                         g_get_tmp_dir(),
                                         G_DIR_SEPARATOR_S,
                                         getuid(),
                                         g_random_int());
    //NSLog(@"tmp_keyfile:%s",tmp_keyfile);
    int st = 0;
    gchar *cmd = g_strdup_printf("'%s' '%s' '%s'",
                                 "get_apk_info.sh",
                                 [_apkFilename UTF8String],
                                 tmp_keyfile);
	if(g_spawn_command_line_sync(cmd,NULL,NULL,&st,NULL) && st == 0){
        GKeyFile *keyfile = g_key_file_new();
        if(g_key_file_load_from_file(keyfile,tmp_keyfile,0,NULL)){
            gchar *package_name = g_key_file_get_string(keyfile,InfoGroup,"name",NULL);
            gchar *version_name = g_key_file_get_string(keyfile,InfoGroup,"versionName",NULL);
            gchar *app_name = g_key_file_get_locale_string(keyfile,InfoGroup,"application-label",NULL,NULL);
            gchar *icon_name =  g_key_file_get_string(keyfile,InfoGroup,"application-icon",NULL);
            
            _packageName = [NSString stringWithUTF8String:package_name];
            _versionName = [NSString stringWithUTF8String:version_name];
            _displayName = [NSString stringWithFormat:@("%@"),@(app_name)];

            _versionCode = g_key_file_get_uint64 (keyfile,InfoGroup,"versionCode",NULL);

            g_free(package_name);
            g_free(version_name);
            g_free(app_name);
            
            
            gchar *unzip_dir = g_strdup_printf("%s%s.%u",
                                               g_get_tmp_dir(),
                                               G_DIR_SEPARATOR_S,
                                               getuid()
                                               );
            g_mkdir_with_parents(unzip_dir,0700);
            gchar *unzip_cmd = g_strdup_printf("unzip -o '%s' %s -d %s",
                                               [_apkFilename UTF8String],
                                               icon_name,
                                               unzip_dir);
			gchar *err = NULL;
			gchar *out = NULL;
            g_spawn_command_line_sync(unzip_cmd,&out,&err,&st,NULL);
			g_free(err);
			g_free(out);
            
			gchar *icon_file = g_strdup_printf("%s%s%s",unzip_dir,G_DIR_SEPARATOR_S,icon_name);
            
            _icon = [[NSImage alloc] initWithContentsOfFile:@(icon_file)];
            
            g_free(icon_file);
            g_free(icon_name);
            g_free(unzip_dir);
            g_free(unzip_cmd);
            
        }
        g_key_file_free(keyfile);
        keyfile = Nil;
    }
    
    g_free(cmd);
    unlink(tmp_keyfile);
    g_free(tmp_keyfile);
    
}

- (void) loadApk
{
    if(_apkLoading)[_apkLoading onStart:self];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self loadApkReal];//run in non UI thread
        dispatch_async(dispatch_get_main_queue(), ^{
            if(_apkLoading)[_apkLoading onFinish:self];//run in UI thread
        });
        [self print];
    });
    
}

- (NSString*)fullVersion
{
    return [NSString stringWithFormat:@("%@(%ld)"),self.versionName,self.versionCode];
}

- (BOOL) testApk
{
    if(_testApk == INT_MAX){
        gchar *cmd = g_strdup_printf("aapt d  permissions '%s'",
                                     [_apkFilename UTF8String]);
        gint st = -1;
        gchar *t1 = NULL;
        gchar *t2 = NULL;
        BOOL ret = g_spawn_command_line_sync(cmd,&t1,&t2,&st,NULL);
        ret = ret && st == 0;
        g_free(cmd);
        g_free(t1);
        g_free(t2);
        if(ret)_testApk = 0;
    }
    return _testApk == 0;
}

- (void) print
{
    NSLog(@"\npath:%@\n"
          "displayName:%@\n"
          "packageName:%@\n"
          "versionName:%@\n"
          "versionCode:%ld\n"
          "fileSize:%ld\n\n",
          _apkFilename,
          _displayName,
          _packageName,
          _versionName,
          _versionCode,
          [self fileSize]);
}

@end
