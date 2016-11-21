//
//  Patient.h
//  IHFDB
//
//  Created by CjSon on 16/6/8.
//  Copyright © 2016年 IHEFE CO., LIMITED. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Drug.h"
#import "IHFDB.h"
#import "Person.h"
@interface Patient : Person

typedef void(^IHFDBCompleteBlock)(BOOL success);

@property (assign,nonatomic) int8_t aint8 ;
@property (assign,nonatomic) int16_t aint16 ;
@property (assign,nonatomic) int32_t aint32 ;
@property (assign,nonatomic) int64_t aint64 ;

@property (assign,nonatomic) Boolean aBoolean ;
@property (assign,nonatomic) BOOL aBool ;
@property (assign,nonatomic) NSInteger aNSInteger ;
@property (assign,nonatomic) int aInt ;
@property (assign,nonatomic) long long alonglong ;
@property (assign,nonatomic) long along ;
@property (assign,nonatomic) unsigned long aUnsignedlong ;
@property (assign,nonatomic) unsigned long long aUnsignedlonglong ;

@property (assign,nonatomic) Class aclass ;
@property (assign,nonatomic) IHFDBCompleteBlock aBlock ;
@property (assign,nonatomic) short ashort ;


@property (copy,nonatomic) NSString * name ;
@property (strong,nonatomic) NSMutableArray <Drug *>* drugs ;

@property (assign,nonatomic) CGFloat  height ;

@property (strong,nonatomic) NSDate * recordDate ;

@property (strong,nonatomic) Bed *bed;

@property (strong,nonatomic) NSString * patientID ;

@property (strong,nonatomic) NSString * mapperStr1 ;
@property (strong,nonatomic) NSString * mapperNumber1 ;

@property (strong,nonatomic) id test ;
@property (strong,nonatomic) NSDictionary * dict ;
@property (strong,nonatomic) NSMutableDictionary * dictM ;

@property (assign,nonatomic) NSRange range ;

@end
