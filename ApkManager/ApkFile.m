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
    return self;
}

- (ApkFile*) initWithURL:(NSURL *)url
{
    self = [super init];
    _apkFilename = [url path];
    return self;
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
    NSLog(@"tmp_keyfile:%s",tmp_keyfile);
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
            _displayName = [NSString stringWithUTF8String:app_name];

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
    g_unlink(tmp_keyfile);
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
