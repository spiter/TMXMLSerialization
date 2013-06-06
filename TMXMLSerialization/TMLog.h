//
//  XLog.h
//  TestMXLog
//
//  Created by WenDong Zhang on 5/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define XLOG_ESC_CH @"\033"
#define XLOG_LEVEL_DEBUG    @"DEBUG"
#define XLOG_LEVEL_INFO     @"INFO"
#define XLOG_LEVEL_WARN     @"WARN"
#define XLOG_LEVEL_ERROR    @"ERROR"

// colors for log level, change it as your wish
#define XLOG_COLOR_RED   XLOG_ESC_CH @"#FF0000"
#define XLOG_COLOR_GREEN XLOG_ESC_CH @"#00FF00"
#define XLOG_COLOR_BROWN  XLOG_ESC_CH @"#FFFF00"
// hard code, use 00000m for reset flag
#define XLOG_COLOR_RESET XLOG_ESC_CH @"#00000m"   


#if defined (__cplusplus)
extern "C" {
#endif

    void _XLog_print(NSString *tag, NSString *colorStr, const char *fileName, const char *funcName, unsigned line, NSString *log);
    
    void _XLog_getFileName(const char *path, char *name);
    
    BOOL _XLog_isEnable();

#if defined (__cplusplus)
}
#endif

#define XLog_log(tag, color, ...) _XLog_print(tag, color, __FILE__, __FUNCTION__, __LINE__, [NSString stringWithFormat:__VA_ARGS__])

#define LogDebug(...) XLog_log(XLOG_LEVEL_DEBUG, XLOG_COLOR_GREEN, __VA_ARGS__)
#define LogInfo(...) XLog_log(XLOG_LEVEL_INFO, XLOG_COLOR_RESET, __VA_ARGS__)
#define LogWarning(...) XLog_log(XLOG_LEVEL_WARN, XLOG_COLOR_BROWN, __VA_ARGS__)
#define LogError(...) XLog_log(XLOG_LEVEL_ERROR, XLOG_COLOR_RED, __VA_ARGS__)
#define LogFatal(...) XLog_log(XLOG_LEVEL_ERROR, XLOG_COLOR_RED, __VA_ARGS__)

// VLog not impled.
#define VLog(vlevel, ...)