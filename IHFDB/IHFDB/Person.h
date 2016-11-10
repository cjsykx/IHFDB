//
//  Person.h
//  IHFDB
//
//  Created by chenjiasong on 16/11/10.
//  Copyright © 2016年 IHEFE CO., LIMITED. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Bed.h"

@interface Person : NSObject
@property (assign,nonatomic) NSUInteger  age ;
@property (strong,nonatomic) NSNumber * idCard ;
@property (strong,nonatomic) NSArray *works;
//@property (strong,nonatomic) Bed *otherBed;

@end
