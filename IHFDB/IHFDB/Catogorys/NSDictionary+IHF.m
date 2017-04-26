//
//  NSDictionary+IHF.m
//  nursing
//
//  Created by CjSon on 16/5/9.
//  Copyright © 2016年 IHEFE CO., LIMITED. All rights reserved.
//

#import "NSDictionary+IHF.h"
#import "JSONKit.h"
@implementation NSDictionary (IHF)

- (instancetype)objectOrNilForKey:(NSString *)key {
    return [self objectForKey:key defaultValue:nil];
}

- (instancetype)objectForKey:(NSString *)key defaultValue:(id)defaultValue{
    
    NSAssert(key, @"key can not be nil");
    if (!key) return defaultValue;
    
    id object = [self objectForKey:key];
    
    BOOL isNull = [object isKindOfClass:[NSNull class]];
    if (!isNull) {
        return [self objectForKey:key];
    } else {
        NSLog(@"Warning : the object for key %@ is NSNull clsss",key);
    }
    return defaultValue;
}

#pragma mark - JSON
- (NSString *)jsonString {
    if (!self) return nil;
    return [self JSONString];
}

+ (NSDictionary *)dictionaryWithJSONStirng:(NSString *)string {
    if (!string) return nil;
    return [NSJSONSerialization JSONObjectWithData:[string dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
}

@end

@implementation NSMutableDictionary (IHF)
- (NSString *)jsonString {
    if (!self) return nil;
    return [self JSONString];
}

+ (NSMutableDictionary *)dictionaryWithJSONStirng:(NSString *)string {
    if (!string) return nil;
    return [NSMutableDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:[string dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil]];
}
@end
