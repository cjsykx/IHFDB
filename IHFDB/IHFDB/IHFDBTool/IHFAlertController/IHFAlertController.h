//
//  IHFAlertController.h
//  IHFPopAnimationView
//
//  Created by chenjiasong on 16/8/9.
//  Copyright © 2016年 chenjiasong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IHFAlertAction.h"
@interface IHFAlertController : UIAlertController

+ (void)alertWithTitle:(NSString *)title message:(NSString *)message cancleHandler:(void (^)(UIAlertAction *action))cancleHandler confirmHandler:(void (^)(UIAlertAction *action))confirmHandler ;

/**
 *  alert confirm
 */
+ (void)alertWithTitle:(NSString *)title message:(NSString *)message confirmHandler:(void (^)(UIAlertAction *action))confirmHandler;

/**
 Present alert controller with alert actions
 */
+ (void)alertWithTitle:(NSString *)title message:(NSString *)message alertActions:(NSArray <IHFAlertAction *>*)alertActions;

/**
 Present alert controller with alert actions in view controller
 */
+ (void)alertWithTitle:(NSString *)title message:(NSString *)message alertActions:(NSArray <IHFAlertAction *>*)alertActions inViewController:(UIViewController *)vc;

@end
