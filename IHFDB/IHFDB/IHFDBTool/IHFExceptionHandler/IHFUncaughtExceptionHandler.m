//
//  IHFUncaughtExceptionHandler.m
//  IHFErrorHandler
//
//  Created by chenjiasong on 16/8/26.
//  Copyright © 2016年 Cjson. All rights reserved.
//

#import "IHFUncaughtExceptionHandler.h"
#include <libkern/OSAtomic.h>
#include <execinfo.h>
#import "IHFException.h"
#import "IHFDB.h"
#import "IHFAlertController.h"
#import "AppDelegate.h"
NSString *applicationDocumentsDirectory() {
    
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

void UncaughtExceptionHandler(NSException *exception) {
    
    NSArray *arr = [exception callStackSymbols];
    NSString *reason = [exception reason];
    NSString *name = [exception name];
    
    NSString *url = [NSString stringWithFormat:@"=============异常崩溃报告=============\nname:\n%@\nreason:\n%@\ncallStackSymbols:\n%@",
                     
                     name,reason,[arr componentsJoinedByString:@"\n"]];
    
    NSString *path = [applicationDocumentsDirectory() stringByAppendingPathComponent:@"IHFUncaughtException.txt"];
    
    NSLog(@" error path = %@",path);
    [url writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    // Not only can write to file , can write to sqlite , or send email to user!
}


@implementation IHFUncaughtExceptionHandler

NSString * const UncaughtExceptionHandlerSignalExceptionName = @"UncaughtExceptionHandlerSignalExceptionName";
NSString * const UncaughtExceptionHandlerSignalKey = @"UncaughtExceptionHandlerSignalKey";
NSString * const UncaughtExceptionHandlerAddressesKey = @"UncaughtExceptionHandlerAddressesKey";

volatile int32_t UncaughtExceptionCount = 0;
const int32_t UncaughtExceptionMaximum = 10;

const NSInteger UncaughtExceptionHandlerSkipAddressCount = 4;
const NSInteger UncaughtExceptionHandlerReportAddressCount = 5;

+ (NSArray *)backtrace{

    void* callstack[128];
    int frames = backtrace(callstack, 128);
    char **strs = backtrace_symbols(callstack, frames);
    
    int i;
    NSMutableArray *backtrace = [NSMutableArray arrayWithCapacity:frames];
    for (
         i = UncaughtExceptionHandlerSkipAddressCount;
         i < UncaughtExceptionHandlerSkipAddressCount +
         UncaughtExceptionHandlerReportAddressCount;
         i++)
    {
        [backtrace addObject:[NSString stringWithUTF8String:strs[i]]];
    }
    free(strs);
    
    return backtrace;
}

- (UIView *)currentWindowView{
    return [[UIApplication sharedApplication].windows lastObject];
}

- (UIViewController *)getCurrentVC{

    UIViewController *result = nil;

    UIWindow * window = [[UIApplication sharedApplication] keyWindow];

    if (window.windowLevel != UIWindowLevelNormal){
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows){
            if (tmpWin.windowLevel == UIWindowLevelNormal){
                window = tmpWin;
                break;
            }
        }
    }

    UIView *frontView = [[window subviews] objectAtIndex:0];
    
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
//
    return result;
}

#pragma mark - hander and deal
- (void)handleException:(IHFException *)exception{
    
    [self validateAndSaveCriticalApplicationData];
    
    [self saveException:exception];
        
    [self showAlertControllerWithException:exception];
    
    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
    CFArrayRef allModes = CFRunLoopCopyAllModes(runLoop);
    
    while (!_dismissed){
        for (NSString *mode in (__bridge NSArray *)allModes){
            CFRunLoopRunInMode((CFStringRef)mode, 0.001, false);
        }
    }
    
    CFRelease(allModes);
    
    NSSetUncaughtExceptionHandler(NULL);
    signal(SIGABRT, SIG_DFL);
    signal(SIGILL, SIG_DFL);
    signal(SIGSEGV, SIG_DFL);
    signal(SIGFPE, SIG_DFL);
    signal(SIGBUS, SIG_DFL);
    signal(SIGPIPE, SIG_DFL);
    
    NSException *childEx = exception.exception;
    
    if ([[exception name] isEqual:UncaughtExceptionHandlerSignalExceptionName]){
        kill(getpid(), [[[childEx userInfo] objectForKey:UncaughtExceptionHandlerSignalKey] intValue]);
    }
    else{
        [childEx raise];
    }
}

#pragma mark - handle
- (void)validateAndSaveCriticalApplicationData{
    
    NSMutableString *mailUrl = [NSMutableString string];
    [mailUrl appendString:@"837334355@qq.com"];
    [mailUrl appendString:@"?subject=程序异常崩溃"];
    [mailUrl appendFormat:@"&body=%@", @"越界了"];
    // 打开地址
//    NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:NSUTF8StringEncoding];
//    NSString *mailPath = [mailUrl stringByAddingPercentEncodingWithAllowedCharacters:controlCharacterSet];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mailUrl]];
}

- (void)saveException:(IHFException *)exception{

    [IHFException createTable];
    [exception save];
}

#pragma mark - send mail
- (void)sendEmailAction{
    
    // 邮件服务器
    MFMailComposeViewController *mailCompose = [[MFMailComposeViewController alloc] init];
    
    // 设置邮件代理
    [mailCompose setMailComposeDelegate:self];
    // 设置邮件主题
    [mailCompose setSubject:@"我是邮件主题"];
    // 设置收件人
    [mailCompose setToRecipients:[NSArray arrayWithObject:@"837334355@qq.com"]];
    NSString *emailContent = @"我是邮件内容";
    // 是否为HTML格式
    [mailCompose setMessageBody:emailContent isHTML:NO];
    // 如使用HTML格式，则为以下代码
    [mailCompose setMessageBody:@"<html><body><p>Hello</p><p>World！</p></body></html>" isHTML:YES];
    
    // 弹出邮件发送视图
    [[self getCurrentVC] presentViewController:mailCompose animated:YES completion:nil];
    //    NSError *error = nil;
    
    //    [self mailComposeController:mailCompose didFinishWithResult:MFMailComposeResultSent error:error];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    
    [controller dismissViewControllerAnimated:YES completion:^{
        
    }];
}


- (void)showAlertControllerWithException:(IHFException *)exception{
//    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
//    [self getCurrentVC];
//    NSLog(@"%@",delegate.window);
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"11" message:@"11" delegate:self cancelButtonTitle:@"no" otherButtonTitles:nil, nil];
//    [alert show];
//    UIAlertController *alertController = [[UIAlertController alloc] init];
//    
//    __weak typeof(self) weakSelf = self;
//    UIAlertAction *quitAction = [UIAlertAction actionWithTitle:@"退出并发送异常报告" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
//        weakSelf.dismissed = NO;
//    }];
//    
//    UIAlertAction *continueAction = [UIAlertAction actionWithTitle:@"继续" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
//    }];
//    
//    [alertController addAction:quitAction];
//    [alertController addAction:continueAction];
    
    
//    UIView *view = [[UIView alloc] init];
//    view.backgroundColor = [UIColor redColor];
//    view.frame = [[UIScreen mainScreen] bounds];
//
//    [[self currentWindowView] addSubview:view];
    
//    [self getCurrentVC];

//    NSLog(@"111");
//    [self updateUI:exception];

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // 处理耗时操作的代码块...
        //通知主线程刷新
        NSLog(@"crash!!!!!");
        dispatch_async(dispatch_get_main_queue(), ^{
            //回调或者说是通知主线程刷新，
            [self updateUI:exception];

        });
    });
    
//    [self performSelectorInBackground:@selector(updateUI:) withObject:nil];
//    [[self currentWindowView] bringSubviewToFront:view];
//     [self performSelectorOnMainThread:@selector(updateUI:) withObject:nil waitUntilDone:NO];
//    [self performSelectorOnMainThread:@selector(getCurrentVC) withObject:nil waitUntilDone:YES];
//    dispatch_async(dispatch_get_main_queue(), ^{
    
//        [self getCurrentVC];
    
//        IHFAlertAction *quitAction = [IHFAlertAction actionForStyleOfDefaultWithTitle:@"退出并发送异常报告" handler:^(UIAlertAction *action) {
//            _dismissed = YES;
//        }];
//        
//        IHFAlertAction *contineAction = [IHFAlertAction actionForStyleOfDefaultWithTitle:@"继续" handler:^(UIAlertAction *action) {
//        }];
//        
//        [IHFAlertController alertWithTitle:@"抱歉,出现异常错误！" message:@"你可以选择继续,但是有可能会出现一些未知错误" alertActions:@[quitAction,contineAction] inViewController:[self getCurrentVC]];
//    });
}

- (void)updateUI:(IHFException *)exception{
    
        IHFAlertAction *quitAction = [IHFAlertAction actionForStyleOfDefaultWithTitle:@"退出并发送异常报告" handler:^(UIAlertAction *action) {
            _dismissed = YES;
        }];

        IHFAlertAction *contineAction = [IHFAlertAction actionForStyleOfDefaultWithTitle:@"继续" handler:^(UIAlertAction *action) {
//            NSException *childEx = exception.exception;
//            kill(getpid(), [[[childEx userInfo] objectForKey:UncaughtExceptionHandlerSignalKey] intValue]);
            
//            NSSetUncaughtExceptionHandler(&HandleException);
//            signal(SIGABRT, SignalHandler);
//            signal(SIGILL, SignalHandler);
//            signal(SIGSEGV, SignalHandler);
//            signal(SIGFPE, SignalHandler);
//            signal(SIGBUS, SignalHandler);
//            signal(SIGPIPE, SignalHandler);

        }];

        [IHFAlertController alertWithTitle:@"抱歉,出现异常错误！" message:@"你可以选择继续,但是有可能会出现一些未知错误" alertActions:@[quitAction,contineAction] ];

}

@end

void HandleException(NSException *exception){
    int32_t exceptionCount = OSAtomicIncrement32(&UncaughtExceptionCount);
    
    if (exceptionCount > UncaughtExceptionMaximum){
        return;
    }
    
    NSArray *callStack = [IHFUncaughtExceptionHandler backtrace];
    NSMutableDictionary *userInfo =
    [NSMutableDictionary dictionaryWithDictionary:[exception userInfo]];
    [userInfo
     setObject:callStack
     forKey:UncaughtExceptionHandlerAddressesKey];
    
    IHFException *ex = [[IHFException alloc] init];
    ex.name = [exception name];
    ex.reason = [exception reason];
    ex.userInfo = [NSString stringWithFormat:@"%@",exception.userInfo];
    ex.callStackSymbols = [NSString stringWithFormat:@"%@",exception.callStackSymbols];
    ex.exception =  [NSException
                     exceptionWithName:[exception name]
                     reason:[exception reason]
                     userInfo:userInfo];
    
    [[[IHFUncaughtExceptionHandler alloc] init]
     performSelectorOnMainThread:@selector(handleException:)
     withObject:
     ex
     waitUntilDone:YES];
    
}
void SignalHandler(int signal){
    
    int32_t exceptionCount = OSAtomicIncrement32(&UncaughtExceptionCount);
    if (exceptionCount > UncaughtExceptionMaximum)
    {
        return;
    }
    
    NSMutableDictionary *userInfo =
    [NSMutableDictionary
     dictionaryWithObject:[NSNumber numberWithInt:signal]
     forKey:UncaughtExceptionHandlerSignalKey];
    
    NSArray *callStack = [IHFUncaughtExceptionHandler backtrace];
    [userInfo
     setObject:callStack
     forKey:UncaughtExceptionHandlerAddressesKey];
    
    [[[IHFUncaughtExceptionHandler alloc] init]
     performSelectorOnMainThread:@selector(handleException:)
     withObject:
     [NSException
      exceptionWithName:UncaughtExceptionHandlerSignalExceptionName
      reason:
      [NSString stringWithFormat:
       NSLocalizedString(@"Signal %d was raised.", nil),
       signal]
      userInfo:
      [NSDictionary
       dictionaryWithObject:[NSNumber numberWithInt:signal]
       forKey:UncaughtExceptionHandlerSignalKey]]
     waitUntilDone:YES];
}

void InstallUncaughtExceptionHandler(){
    NSSetUncaughtExceptionHandler(&HandleException);
    signal(SIGABRT, SignalHandler);
    signal(SIGILL, SignalHandler);
    signal(SIGSEGV, SignalHandler);
    signal(SIGFPE, SignalHandler);
    signal(SIGBUS, SignalHandler);
    signal(SIGPIPE, SignalHandler);
}

void UninstallUncaughtExceptionHandler(){
    NSSetUncaughtExceptionHandler(NULL);
    signal(SIGABRT, SIG_DFL);
    signal(SIGILL, SIG_DFL);
    signal(SIGSEGV, SIG_DFL);
    signal(SIGFPE, SIG_DFL);
    signal(SIGBUS, SIG_DFL);
    signal(SIGPIPE, SIG_DFL);
}
