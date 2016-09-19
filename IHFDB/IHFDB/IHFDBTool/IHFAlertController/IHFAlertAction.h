//
//  AlertAction.h
//  IHFPopAnimationView
//
//  Created by chenjiasong on 16/8/9.
//  Copyright © 2016年 chenjiasong. All rights reserved.
//
#import <UIKit/UIKit.h>

@class IHFAlertAction;

@interface IHFAlertAction : UIAlertAction

/**
 create alert action , style is default
*/
+ (instancetype)actionForStyleOfDefaultWithTitle:(NSString *)title handler:(void (^)(UIAlertAction *action))handler;

/**
 create alert action , style is Destructive
 */

+ (instancetype)actionForStyleOfDestructiveWithTitle:(NSString *)title handler:(void (^)(UIAlertAction *action))handler;


@end
