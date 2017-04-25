//
//  IHFPredicate.m
//  IHFDB
//
//  Created by CjSon on 16/6/15.
//  Copyright © 2016年 IHEFE CO., LIMITED. All rights reserved.
//

#import "IHFPredicate.h"

@implementation IHFPredicate
- (instancetype)initWithString:(NSString*)string {
    self = [super init];
    if (self) {
        _predicateFormat = string;
    }
    return self;
}

- (instancetype)initWithString:(NSString *)string OrderBy:(NSString *)orderBy {
    self = [super init];
    if (self) {
        _predicateFormat = string;
        _orderBy = orderBy;
    }
    return self;
}

+ (instancetype)predicateWithString:(NSString *)string {
    IHFPredicate * predicate  = [[self alloc] initWithString:string];
    return predicate;
}

+ (instancetype)predicateWithString:(NSString *)string OrderBy:(NSString *)sortString {
    
    IHFPredicate *predicate = [[IHFPredicate alloc] initWithString:string OrderBy:sortString];
    return predicate;
}

- (instancetype)initWithFormat:(NSString *)name, ... {
    self = [super init];
    if (self) {

        // Add '' for %@
        NSString *format = [name stringByReplacingOccurrencesOfString:@"%@" withString:@"'%@'"];
        va_list args;
        va_start(args,name);
        _predicateFormat = [[NSString alloc] initWithFormat:format arguments:args];
        va_end(args);
    }
    return self;
}

- (instancetype)initWithOrderBy:(NSString *)orderBy Format:(NSString *)name, ... {
    self = [super init];
    if (self) {
        _orderBy = orderBy;
        
        // Add '' for %@
        NSString *format = [name stringByReplacingOccurrencesOfString:@"%@" withString:@"'%@'"];
        
        va_list args;
        va_start(args, name);
        _predicateFormat = [[NSString alloc] initWithFormat:format arguments:args];
        va_end(args);
    }
    return self;
}

+ (instancetype)predicateWithFormat:(NSString *)name, ... {
    IHFPredicate * predicate = [[IHFPredicate alloc] init];
    
    // add '' for %@
    NSString *format = [name stringByReplacingOccurrencesOfString:@"%@" withString:@"'%@'"];

    va_list args;
    va_start(args, name);
    predicate.predicateFormat = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    return predicate;
}

+ (instancetype)predicateWithOrderBy:(NSString *)orderBy Format:(NSString*)name, ...{
    
    NSString *format = [name stringByReplacingOccurrencesOfString:@"%@" withString:@"'%@'"];
    
    IHFPredicate * predicate = [[IHFPredicate alloc] init];
    predicate.orderBy = orderBy;
    va_list args;
    va_start(args, name);
    predicate.predicateFormat = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    return predicate;
}

#pragma mark - append AND and OR predicate
-(void)appendAnd_Predicate:(IHFPredicate *)and_predicate {
    
    self.predicateFormat = [NSString stringWithFormat:@"%@ AND %@",self.predicateFormat,and_predicate.predicateFormat];
}

-(void)appendOr_Predicate:(IHFPredicate *)or_predicate {
    
    self.predicateFormat = [NSString stringWithFormat:@"%@ OR %@",self.predicateFormat,or_predicate.predicateFormat];
}


@end
