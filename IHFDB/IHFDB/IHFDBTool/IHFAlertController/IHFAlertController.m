//
//  IHFAlertController.m
//  IHFPopAnimationView
//
//  Created by chenjiasong on 16/8/9.
//  Copyright © 2016年 chenjiasong. All rights reserved.
//

#import "IHFAlertController.h"

@interface IHFAlertController ()

@end

@implementation IHFAlertController

+ (void)alertWithTitle:(NSString *)title message:(NSString *)message cancleHandler:(void (^)(UIAlertAction *action))cancleHandler confirmHandler:(void (^)(UIAlertAction *action))confirmHandler {
    
    IHFAlertController *alertController = [IHFAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    if (confirmHandler) {
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:confirmHandler];
        [alertController addAction:confirmAction];
    }
    if (cancleHandler) {
        UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:cancleHandler];
        [alertController addAction:cancleAction];
    }
    
    [alertController presentAnimated:YES];
}

+ (void)alertWithTitle:(NSString *)title message:(NSString *)message confirmHandler:(void (^)(UIAlertAction *))confirmHandler{
    [self alertWithTitle:title message:message cancleHandler:nil confirmHandler:confirmHandler];
}

+ (void)alertWithTitle:(NSString *)title message:(NSString *)message alertActions:(NSArray<IHFAlertAction *> *)alertActions inViewController:(UIViewController *)vc{
    
    IHFAlertController *alertController = [IHFAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    [alertActions enumerateObjectsUsingBlock:^(IHFAlertAction * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [alertController addAction:obj];
    }];
    
    if (vc) {
        [vc presentViewController:alertController animated:YES completion:nil];
    }else{
        [alertController presentAnimated:YES];
    }
}

+ (void)alertWithTitle:(NSString *)title message:(NSString *)message alertActions:(NSArray <IHFAlertAction *>*)alertActions{
    
    [self alertWithTitle:title message:message alertActions:alertActions inViewController:nil];
}
#pragma mark - alert animation

- (void)presentAnimated:(BOOL)animated {
    
    UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [window setBackgroundColor:[UIColor clearColor]];
    
    UIViewController *rootControllerView = [[UIViewController alloc] init];
    [rootControllerView.view setBackgroundColor:[UIColor clearColor]];
    
    [window setWindowLevel:UIWindowLevelAlert + 1];
    [window makeKeyAndVisible];
    
    [window setRootViewController:rootControllerView];
    rootControllerView.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [rootControllerView presentViewController:self animated:animated completion:nil];
}


@end
