//
//  NSArray+IHF.m
//  NurseV2
//
//  Created by chenjiasong on 16/9/26.
//  Copyright © 2016年 IHEFE CO., LIMITED. All rights reserved.
//

#import "NSArray+IHF.h"
#import "JSONKit.h"
@implementation NSArray (IHF)

- (instancetype)objectOrNilAtIndex:(NSUInteger)index {
    return (index < self.count) ? [self objectAtIndex:index] : nil;
}

#pragma mark - JSON
- (NSString *)jsonString {
    if (!self) return nil;
    return [self JSONString];
}

+ (NSArray *)arrayWithJSONStirng:(NSString *)string {
    if (!string) return nil;
    return [NSJSONSerialization JSONObjectWithData:[string dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
}

@end

@implementation NSMutableArray (IHF)
- (NSString *)jsonString {
    if (!self) return nil;
    return [self JSONString];
}

+ (NSMutableArray *)arrayWithJSONStirng:(NSString *)string {
    if (!string) return nil;
    return [NSMutableArray arrayWithArray:[NSJSONSerialization JSONObjectWithData:[string dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil]];
}
@end
