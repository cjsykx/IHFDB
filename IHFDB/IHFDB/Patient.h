//
//  Patient.h
//  IHFDB
//
//  Created by CjSon on 16/6/8.
//  Copyright © 2016年 IHEFE CO., LIMITED. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Bed.h"
#import "Drug.h"
#import "IHFDB.h"
@interface Patient : NSObject
@property (copy,nonatomic) NSString * name ;
@property (strong,nonatomic) NSArray <Drug *>* drugs ;

@property (assign,nonatomic) NSInteger  age ;
@property (assign,nonatomic) CGFloat  height ;

@property (strong,nonatomic) NSDate * recordDate ;

@property (strong,nonatomic) NSNumber * idCard ;
@property (strong,nonatomic) Bed *bed;

@property (strong,nonatomic) NSString * patientID ;
@end
