//
//  IHFUncaughtExceptionHandler.h
//  IHFErrorHandler
//
//  Created by chenjiasong on 16/8/26.
//  Copyright © 2016年 Cjson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessageUI/MessageUI.h"

@interface IHFUncaughtExceptionHandler : NSObject<MFMailComposeViewControllerDelegate>

//+ (void)setDefaultHandler;
//+ (NSUncaughtExceptionHandler*)getHandler;

@property (assign, nonatomic) BOOL dismissed;

@end

void InstallUncaughtExceptionHandler();
void UninstallUncaughtExceptionHandler();
