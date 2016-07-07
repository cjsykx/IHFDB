//
//  DateTool.m
//  PlanBrother
//
//  Created by administrator on 15-3-12.
//  Copyright (c) 2015年 Cjs. All rights reserved.
//

#import "DateTool.h"

@implementation DateTool
// can get date and time
+(NSString *)dateToolForGetDateStringWithInterval:(NSUInteger)interval{
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
    
    //实例化一个NSDateFormatter对象
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    //返回日期字符串
    return [dateFormatter stringFromDate:date];
}

// can get date , without time
+(NSString *)dateToolforGetDateStringWithoutTimeWithInterval:(NSUInteger)interval{
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
    
    //实例化一个NSDateFormatter对象
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    //返回日期字符串
    return [dateFormatter stringFromDate:date];
}

// can get week time
+(NSString *)dateToolForGetWeekTimeStringWithInterval:(NSUInteger)interval{
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
    
    //实例化一个NSDateFormatter对象
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    // 中文
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:@"EEEE"];
    
    //返回日期字符串
    return [dateFormatter stringFromDate:date];
}

// use string for get date
+(NSDate *)dateToolForGetDateWithDateString:(NSString *)dateString{
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    
    // 中文
    dateFormat.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    return  [dateFormat dateFromString:dateString];
}

// use string for get date
+(NSDate *)dateToolForGetDateWithoutTimeWithDateString:(NSString *)dateString{
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    
    // 中文
    dateFormat.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    
    return  [dateFormat dateFromString:dateString];
}



// use date for get stirng
+(NSString *)dateToolForGetDateStringWithdate:(NSDate *)date{
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    return  [dateFormat stringFromDate:date];
}

// use date for get stirng
+(NSString *)dateToolForGetDateStringWithoutDateWithdate:(NSDate *)date{
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    
    [dateFormat setDateFormat:@"HH:mm:ss"];
    
    return  [dateFormat stringFromDate:date];
}

// can get string , without time
+(NSString *)dateToolforGetDateStringWithoutTimeWithDate:(NSDate *)date{
    
    //实例化一个NSDateFormatter对象
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    //返回日期字符串
    return [dateFormatter stringFromDate:date];
}

// can get string , without date. like : hh:mm:ss
+(NSString *)dateToolforGetDateStringWithoutDateWithDate:(NSDate *)date{
    
    //实例化一个NSDateFormatter对象
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    
    //返回日期字符串
    return [dateFormatter stringFromDate:date];
}

// can get string , without second. like : hh:mm
+(NSString *)dateToolforGetDateStringWithoutSecondWithDate:(NSDate *)date{
    
    //实例化一个NSDateFormatter对象
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    
    //返回日期字符串
    return [dateFormatter stringFromDate:date];
}

// can get string , without second. like : hh:mm
+(NSDate *)dateToolforGetDateWithoutSecondWithDateString:(NSString *)dateString{
    
    //实例化一个NSDateFormatter对象
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    
    //返回日期字符串
    return [dateFormatter dateFromString:dateString];
}

+(NSDate *)dateToolForGetDateWithoutSecondWithDate:(NSDate *)date{
    
    NSString *dateString = [self dateToolforGetDateStringWithoutSecondWithDate:date];
    
    return [self dateToolforGetDateWithoutSecondWithDateString:dateString];
}

+(NSDate *)dateToolforGetDateWithoutTimeWithDate:(NSDate *)date{
    
    //实例化一个NSDateFormatter对象
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    return [DateTool dateToolForGetDateWithoutTimeWithDateString:[dateFormatter stringFromDate:date]];

}

//从出生日期获取对应的年龄
+ (NSString *)ageFromBirthday:(NSString *)birthday {
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"yyyyMMdd"];
//    NSDate *birthDate = [dateFormatter dateFromString:birthday];
//    NSDate *today = [NSDate date];
//    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:birthDate toDate:today options:0];
//    return [NSString stringWithFormat:@"%ld",(long)components.year];
    
    if (!birthday.length || birthday.length < 4) return @"";
    
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy"];
    NSString *now = [dateFormatter stringFromDate:[NSDate date]];
    NSString *yearString = [birthday substringWithRange:NSMakeRange(0,4)];
    NSNumber *age = @([now integerValue] - [yearString integerValue] + 1);
    return [NSString stringWithFormat:@"%@", age];
}

/**
 *  将格式为"yyyy-MM-dd HH:mm:ss"的时间字符串 transfrom to "yyyy-MM-dd HH:mm" 的格式
 *
 *  @param dateString 时间字符串
 *
 *  @return 返回"yyyy-MM-dd HH:mm"的格式字符串
 */
+ (NSString *)dateToolForDateStringWithoutSecondString:(NSString *)dateString {
    NSDate *date = [self dateToolForGetDateWithDateString:dateString];
    return [self dateToolforGetDateStringWithoutSecondWithDate:date];
}

#pragma mark - 校验当前时间是否在某一个时间段中 - 告知是否应该

+ (BOOL)shouldPlaySound {
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierChinese];
    NSDateComponents *component = [[NSDateComponents alloc] init];
    
    NSInteger units = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    component = [calendar components:units fromDate:date];
    
    NSDate *fromDate = [self getCustomDateWithDay:[component day] andHour:8 andMinute:0];
    NSDate *toDate = [self getCustomDateWithDay:[component day] andHour:16 andMinute:30];
    
    NSDate *currentDate = [NSDate date];
    
    if ([currentDate compare:fromDate] == NSOrderedDescending && [currentDate compare:toDate] == NSOrderedAscending) {
        return YES;
    }
    return NO;
}

+ (NSDate *)getCustomDateWithDay:(NSInteger)day andHour:(NSInteger)hour andMinute:(NSInteger)minute {
    
    NSDate *currentDate = [NSDate date];
    NSCalendar *currentCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *currentComps = [[NSDateComponents alloc] init];
    
    NSInteger flagUnits = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    
    currentComps = [currentCalendar components:flagUnits fromDate:currentDate];
    
    // 设置某一个时间点
    NSDateComponents *resultComps = [[NSDateComponents alloc] init];
    [resultComps setYear:[currentComps year]];
    [resultComps setMonth:[currentComps month]];
    [resultComps setDay:day];
    [resultComps setHour:hour];
    [resultComps setMinute:minute];
    [resultComps setSecond:[currentComps second]];
    
    NSCalendar *resultCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    return [resultCalendar dateFromComponents:resultComps];
}

@end
