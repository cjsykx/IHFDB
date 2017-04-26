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

// Normal
- (void)eat1;
- (void)sleep1;

// [] ..
- (Person *)eat2;
- (Person *)sleep2;

// {}
- (void (^)())eat3;
- (void (^)())sleep3;

// 2 and 3
- (Person * (^)())eat4;
- (Person * (^)())sleep4;

// 4 and value
- (Person * (^)(NSString *food))eat5;
- (Person * (^)(NSInteger hour))sleep5;

@end
