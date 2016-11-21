//
//  NSArray+IHF.h
//  NurseV2
//
//  Created by chenjiasong on 16/9/26.
//  Copyright © 2016年 IHEFE CO., LIMITED. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (IHF)

/**
 Returns the object with specified index, if the index out of bounds it will return nil.

 @ void out of bounds
 */
- (instancetype)objectOrNilAtIndex:(NSUInteger)index;

//--------------------------------------------------------------------
//----------------------------- JSON ---------------------------------
//--------------------------------------------------------------------

/**
 Returns the JSON Stirng from this dictionary
 */
- (NSString *)jsonString;


/**
 Returns array from given JSON String
 
 @param string : It must be JSON String ..
 */
+ (NSArray *)arrayWithJSONStirng:(NSString *)string;
@end

@interface NSMutableArray (IHF)
/**
 Returns the JSON Stirng from this dictionary
 */
- (NSString *)jsonString;

/**
 Returns arrryM from given JSON String
 
 @param string : It must be JSON String ..
 */

+ (NSMutableDictionary *)arrayWithJSONStirng:(NSString *)string;

@end
