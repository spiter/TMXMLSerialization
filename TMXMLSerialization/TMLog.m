//
//  XLog.m
//  TestMXLog
//
//  Created by WenDong Zhang on 5/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TMLog.h"

//static int isXLogEnable = -1;   // -1: not set, 0: disable, 1: enable

void _XLog_print(NSString *tag, NSString *colorStr, const char *fileName, const char *funcName, unsigned line, NSString *log)
{
    const char *tagStr = [tag UTF8String];
    // show filename without path
    char *file = (char *)malloc(sizeof(char) * strlen(fileName));
    _XLog_getFileName(fileName, file);
    
    if (_XLog_isEnable()) {
        printf("%s", [colorStr UTF8String]);    // log color
        printf("%s[%s]", [XLOG_ESC_CH UTF8String], tagStr); // start tag
    }
    
    printf("%s ", [[[NSDate date] description] UTF8String]);   // time
    printf("%s %s:l%u) ", file, funcName, line);    // fileName
    printf("%s", [log UTF8String]);    // log 
    
    if (_XLog_isEnable()) {
        printf("%s[/%s]", [XLOG_ESC_CH UTF8String], tagStr);    // end tag
        printf("%s", [XLOG_COLOR_RESET UTF8String]);    // reset color
    }
    printf("\n");
    
    free(file);
}

BOOL _XLog_isEnable()
{
    return YES;
//    if (isXLogEnable == -1) {   // init
//        char *xlogEnv = getenv("XLOG_FLAG");
//        if (xlogEnv && !strcmp(xlogEnv, "YES")) {
//            isXLogEnable = 1;
//        } else {
//            isXLogEnable = 0;
//        }
//    }
//
//    if (isXLogEnable == 0) {
//        return NO;
//    }
//    return YES;
}

void _XLog_getFileName(const char *path, char *name)
{
    int l = strlen(path);
    while (l-- >= 0 && path[l] != '/') {}
    strcpy(name, path + (l >= 0 ? l + 1 : 0));
}
