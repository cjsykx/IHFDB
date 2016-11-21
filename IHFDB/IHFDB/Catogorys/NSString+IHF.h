//
//  NSString+IHF.h
//  NurseV2
//
//  Created by CjSon on 16/6/6.
//  Copyright © 2016年 IHEFE CO., LIMITED. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (IHF)

//--------------------------------- size and string -------------------------

/**
 *  Returns the string size with specified font and max zise
 *  @ lineBreakMode : NSLineBreakByWordWrapping.
 */
- (CGSize)sizeWithFont:(UIFont *)font maxSize:(CGSize)maxSize;

/**
 *  Returns the string size with specified font and max zise and lineBreakMode
 */

- (CGSize)sizeForFont:(UIFont *)font maxSize:(CGSize)size mode:(NSLineBreakMode)lineBreakMode ;

/**
 *  Returns the string height with specified font and width
 */

- (CGFloat)heightForFont:(UIFont *)font width:(CGFloat)width ;

// -----------------------------  support -----------------------
/**
 *  returns the result if the string is chinese
 */
- (BOOL)isChinese;


/**
 *  returns the result if the string is nil or length is zero;
 */
- (BOOL)isEmpty;

// -------------------------------    encryption   ----------------
/**
 *  returns the string is be MD5 hash string
 */

- (NSString *)MD5HashString;

/**
 *  returns the string is be MD5 hash string
 */
- (NSString *)sha256HashString ;

//--------------------------------- encoding and string -------------------------

/**
 Returns string for encode for URL Character
 */
- (NSString *)stringByAddingPercentEncodingWithURLQueryCharacterSet;


/**
 Returns number value ..
 */
- (NSNumber *)numberValue;


/**
 Returns the string is by trim
 */
- (NSString *)stringByTrimed ;


/**
 Returns whether the string contains given stirng
 */
- (BOOL)isContainString:(NSString *)string;

/**
 Returns whether the string contains given set
 */
- (BOOL)isContainCharacterSet:(NSCharacterSet *)set;

@end
