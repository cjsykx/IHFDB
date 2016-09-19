//
//  AlertAction.m
//  IHFPopAnimationView
//
//  Created by chenjiasong on 16/8/9.
//  Copyright © 2016年 chenjiasong. All rights reserved.
//

#import "IHFAlertAction.h"

@implementation IHFAlertAction

+ (instancetype)actionForStyleOfDefaultWithTitle:(NSString *)title handler:(void (^)(UIAlertAction *))handler{
    
    return [self actionWithTitle:title style:UIAlertActionStyleDefault handler:handler];
}

+ (instancetype)actionForStyleOfDestructiveWithTitle:(NSString *)title handler:(void (^)(UIAlertAction *))handler{
    return [self actionWithTitle:title style:UIAlertActionStyleDestructive handler:handler];

}
@end
