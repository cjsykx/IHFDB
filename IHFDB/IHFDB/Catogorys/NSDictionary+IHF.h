//
//  NSDictionary+IHF.h
//  nursing
//
//  Created by CjSon on 16/5/9.
//  Copyright © 2016年 IHEFE CO., LIMITED. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (IHF)

/**
 Returns the object for key 
 
 @ key : if key is nil , will return nil.
 @ instancetype : the object , if is NSNull class , it will change to nil .
 @ tips : (sometimes the data from network may be NSNull , so for safe , you'd better call the method.)
 */
- (instancetype)objectOrNilForKey:(NSString *)key;

/**
 Returns the object for key , if the object is NSNull class, it will return defaultValue!
 
 @ key : if key is nil , will return default value.
 @ defaultValue : will return it if the object is NSNull class!
 @ instancetype : the object , if is NSNull class , it will change to defaultValue .
 @ tips : (sometimes the data from network may be NSNull , so for safe , you'd better call the method.)
 */

- (instancetype)objectForKey:(NSString *)key defaultValue:(id)value;

//--------------------------------------------------------------------
//----------------------------- JSON ---------------------------------
//--------------------------------------------------------------------

/**
 Returns the JSON Stirng from this dictionary
 */
- (NSString *)jsonString;


/**
 Returns dictionary from given JSON String

 @param string : It must be JSON String ..
 */
+ (NSDictionary *)dictionaryWithJSONStirng:(NSString *)string;
@end

@interface NSMutableDictionary (IHF)
/**
 Returns the JSON Stirng from this dictionary
 */

- (NSString *)jsonString;

/**
 Returns dictionaryM from given JSON String
 
 @param string : It must be JSON String ..
 */

+ (NSMutableDictionary *)dictionaryWithJSONStirng:(NSString *)string;
@end
