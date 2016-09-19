//
//  IHFException.h
//  IHFDB
//
//  Created by chenjiasong on 16/8/26.
//  Copyright © 2016年 IHEFE CO., LIMITED. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IHFException : NSObject

@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *reason;
@property (copy, nonatomic) NSString *userInfo;
@property (copy, nonatomic) NSString *callStackSymbols;

@property (strong, nonatomic) NSException *exception;
@end
