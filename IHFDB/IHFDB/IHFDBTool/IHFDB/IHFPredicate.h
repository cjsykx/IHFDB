//
//  IHFPredicate.h
//  IHFDB
//
//  Created by CjSon on 16/6/15.
//  Copyright © 2016年 IHEFE CO., LIMITED. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IHFPredicate : NSObject

// TODO: It have BUG if you want a predicate format = [[IHFPredicate alloc] initWithFormat:@"%@ = %@",@"RecordDate",[NSDate date]] ;

// IF You must use

// format = [[IHFPredicate alloc] initWithFormat:@"@"RecordDate = %@",[NSDate date]];
// Or
//NSStirng *str = [[IHFPredicate alloc] initWithFormat:@"%@ = %@",@"RecordDate",[NSDate date]];
//format = [[IHFPredicate alloc] initWithString:str];
//

@property (nonatomic, copy) NSString *predicateFormat;
@property (nonatomic, copy) NSString *orderBy;

@property (nonatomic, assign) BOOL isDesc; /**< Defalt is ASC (NO) , if you want DESC , you can set it YES */

// TODO: add groupBy . Because group by need count !
@property (nonatomic, copy) NSString *groupBy;

@property (nonatomic, assign) NSRange limitRange; /**< the range of data you want to select , it can be "limit (range.location,range.location + range.length)"*/


- (instancetype)initWithString:(NSString *)string;

- (instancetype)initWithString:(NSString *)string OrderBy:(NSString *)orderBy;

+ (instancetype)predicateWithString:(NSString *)string;

+ (instancetype)predicateWithString:(NSString *)string OrderBy:(NSString *)orderBy;


- (instancetype)initWithFormat:(NSString *)name, ...NS_FORMAT_FUNCTION(1,2);

- (instancetype)initWithOrderBy:(NSString *)orderBy Format:(NSString *)name, ...NS_FORMAT_FUNCTION(1,3);


+ (instancetype)predicateWithFormat:(NSString *)name, ...NS_FORMAT_FUNCTION(1,2);

+ (instancetype)predicateWithOrderBy:(NSString *)orderBy Format:(NSString *)name, ...NS_FORMAT_FUNCTION(1,3);

/** 
 Append and predicate format 
 @ Main use and_predicate.predicateFormat
 */
- (void)appendAnd_Predicate:(IHFPredicate *)and_predicate;

/**
 Append or predicate format
 @ Main use and_predicate.predicateFormat
 */

- (void)appendOr_Predicate:(IHFPredicate *)or_predicate;

@end
