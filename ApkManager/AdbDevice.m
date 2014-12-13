//
//  AdbDevice.m
//  ApkManager
//
//  Created by WeiKeting on 09/07/2014.
//  Copyright (c) 2014年 weiketing.com. All rights reserved.
//

#import "AdbDevice.h"
#include <glib.h>

@implementation AdbDevice

+(NSArray*) getDevices
{
    NSMutableArray *ret = NULL;
    gchar *out = NULL;
	gint st = -1;
	if(g_spawn_command_line_sync ("get_devices.sh",&out,NULL,&st,NULL) && st == 0){
		GKeyFile *key = g_key_file_new();
		g_key_file_load_from_data (key,out,-1,0,NULL);
		gsize len = 0;
		gchar **vv = g_key_file_get_groups(key,&len);
        //NSLog(@"out:%s",out);
		if(vv !=NULL ){
            int i=0;
            ret = [[NSMutableArray alloc] initWithCapacity:len];
			for(i=0;i<len;i++){
				gchar *serial = g_strdup(vv[i]);
				gchar *os_version = g_key_file_get_string(key,vv[i],"ro.build.version.release",NULL);
				gchar *model = g_key_file_get_string(key,vv[i],"ro.product.model",NULL);
                if( model == Nil || model[0] == 0){
                    g_free(model);
                    model =g_key_file_get_string(key,vv[i],"ro.product.name",NULL);
                }
				gchar *brand = g_key_file_get_string(key,vv[i],"ro.product.brand",NULL);

				AdbDevice *ad = [[AdbDevice alloc]
                                 init:@(serial) model:@(model) brand:@(brand) osVersion:@(os_version)];
                [ret addObject:ad];
                g_free(serial);
                g_free(os_version);
                g_free(model);
                g_free(brand);
			}
			g_strfreev (vv);
		}
		g_key_file_free (key);
	}
    
	g_free (out);
    //NSLog(@"ret:%@",ret);
    return ret;
}

+(void) killServer
{
    g_spawn_command_line_sync("adb kill-server",NULL,NULL,NULL,NULL);
}

+(void) startServer
{
    g_spawn_command_line_sync("adb start-server",NULL,NULL,NULL,NULL);
}


-(id)init:(NSString*)deviceId model:(NSString*)model brand:(NSString*)brand osVersion:(NSString*)osVersion
{
    self = [super init];
    _deviceId = deviceId;
    _model = model;
    _brand = brand;
    _osVersion = osVersion;
    _displayName = [NSString stringWithFormat:@"%@ %@ - Android %@",_brand,_model,_osVersion];;
    //NSLog(@"deviceId:%@,model:%@,brand:%@,osVersion:%@\n",deviceId,model,brand,osVersion);
    return self;
}


-(NSString*) toString
{
    return [NSString stringWithFormat:@"deviceId:%@,model:%@,brand:%@,osVersion:%@",_deviceId,_model,_brand,_osVersion];
}

-(int) installApk:(NSString*)apkFilename message:(NSString **)outMsg
{
    gint ret = -1;
	gchar *out = NULL;
	gchar *err = NULL;
	gchar *cmd = g_strdup_printf("adb  -s %s install -r %s",
	                             [_deviceId UTF8String],
	                             [apkFilename UTF8String]
	                             );
	g_spawn_command_line_sync (cmd,&out,&err,&ret,NULL);
	///g_printerr("%s",out);
	if(ret == 0 ){
		ret = -2;
		gchar **vv = g_strsplit_set(out,"\r\n",-1);
		int i=0;
		gchar *tmp_msg = NULL;
		if(vv){
			gchar *pt = NULL;
			for(i=0;vv[i];i++){
				if(vv[i]&&vv[i][0]){
					pt = vv[i];
				}
			}
			if(pt)tmp_msg = g_strdup(pt);
			g_strfreev (vv);
		}
		if(g_str_has_suffix (tmp_msg,"Success")){
			ret = 0;
		}
		if(outMsg && tmp_msg)*outMsg = [NSString stringWithUTF8String:tmp_msg];
		g_free(tmp_msg);
	}
	if(outMsg&&*outMsg == NULL && err)*outMsg = [NSString stringWithUTF8String:err];
	free(err);
	g_free(out);
	g_free(cmd);
	return ret;

}


@end
