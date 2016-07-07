//
//  DateTool.h
//  Cjson tool
//
//  Created by administrator on 15-10-29.
//  Copyright (c) 2015年 Cjs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DateTool : NSObject

/**
 *  根据日期得到年月日+小时格式的字符串
 *
 *  @param
 *
 *  @return 年月日格式
 */
+ (NSString *)dateToolForGetDateStringWithInterval:(NSUInteger)interval;


/**
 *  根据日期得到年月日格式的字符串
 *
 *  @param
 *
 *  @return 年月日格式
 */
+(NSString *)dateToolforGetDateStringWithoutTimeWithInterval:(NSUInteger)interval;


/**
 *  获取星期几的字符串
 *
 *  @param interval
 *
 *  @return 星期几
 */
+(NSString *)dateToolForGetWeekTimeStringWithInterval:(NSUInteger)interval;


/**
 *  根据字符串获取对应的日期
 *
 *  @param dateString
 *
 *  @return 日期
 */
+(NSDate *)dateToolForGetDateWithDateString:(NSString *)dateString;


/**
 *  根据对应的日期获取对应的字符串
 *
 *  @param date
 *
 *  @return 日期字符串
 */
+(NSString *)dateToolForGetDateStringWithdate:(NSDate *)date;

/**
 *  date change into string . without time , 'yyyy-MM-dd'
 *
 *  @param date
 *
 *  @return
 */
+(NSString *)dateToolforGetDateStringWithoutTimeWithDate:(NSDate *)date;

/**
 *  根据字符串转化成为时间
 *
 *  转化时间的格式“yyyy-MM-dd”
 *
 *  @return NSDate
 */
+(NSDate *)dateToolForGetDateWithoutTimeWithDateString:(NSString *)dateString;


//从出生日期获取对应的年龄
+ (NSString *)ageFromBirthday:(NSString *)birthday;

/** use date change into string , the format is 'hh:mm:ss'    */

+(NSString *)dateToolforGetDateStringWithoutDateWithDate:(NSDate *)date;

/** change date format 'yyyy-MM-dd HH:mm:ss' into 'yyyy-MM-dd' */

+(NSDate *)dateToolforGetDateWithoutTimeWithDate:(NSDate *)date;

/**
 * 时间转化成时间字符串
 *
 * yyyy-MM-dd HH:mm:ss convert to HH:mm:ss
 *
 * @return NSString
 */
+(NSString *)dateToolForGetDateStringWithoutDateWithdate:(NSDate *)date;

// can get string , without second. like : hh:mm
+(NSString *)dateToolforGetDateStringWithoutSecondWithDate:(NSDate *)date;

/** change date into 'yyyy-MM-dd HH:mm' , without second */

+(NSDate *)dateToolForGetDateWithoutSecondWithDate:(NSDate *)date;

/**
 *  将格式为"yyyy-MM-dd HH:mm:ss"的时间字符串 transfrom to "yyyy-MM-dd HH:mm" 的格式
 *
 *  @param dateString 时间字符串
 *
 *  @return 返回"yyyy-MM-dd HH:mm"的格式字符串
 */
+ (NSString *)dateToolForDateStringWithoutSecondString:(NSString *)dateString;

/** get date with  yyyy-MM-dd HH:mm*/

+(NSDate *)dateToolforGetDateWithoutSecondWithDateString:(NSString *)dateString;

// 判断当前时间是否在指定的时间段之间
+ (BOOL)shouldPlaySound;

@end
