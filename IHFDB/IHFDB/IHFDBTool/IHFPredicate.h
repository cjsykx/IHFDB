//
//  IHFPredicate.h
//  IHFDB
//
//  Created by CjSon on 16/6/15.
//  Copyright © 2016年 IHEFE CO., LIMITED. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IHFPredicate : NSObject
@property (nonatomic,copy) NSString * predicateFormat;
@property (nonatomic,copy) NSString * orderBy;

// TODO: add groupBy 
@property (nonatomic,copy) NSString * groupBy;
// TODO: add limitCount
@property (nonatomic,copy) NSString * limitCount;


- (instancetype)initWithString:(NSString*)string;

- (instancetype)initWithString:(NSString *)string OrderBy:(NSString *)orderBy;

+ (instancetype)predicateWithString:(NSString *)string;

+ (instancetype)predicateWithString:(NSString *)string OrderBy:(NSString *)orderBy;


- (instancetype)initWithFormat:(NSString *)name, ...NS_FORMAT_FUNCTION(1,2);

- (instancetype)initWithOrderBy:(NSString *)orderBy Format:(NSString *)name, ...NS_FORMAT_FUNCTION(1,3);


+ (instancetype)predicateWithFormat:(NSString *)name, ...NS_FORMAT_FUNCTION(1,2);

+ (instancetype)predicateWithOrderBy:(NSString *)orderBy Format:(NSString*)name, ...NS_FORMAT_FUNCTION(1,3);


@end
