//
//  TypeCatagoty.h
//  IHFDB
//
//  Created by CjSon on 16/6/29.
//  Copyright © 2016年 IHEFE CO., LIMITED. All rights reserved.
//

#import <Foundation/Foundation.h>
@class TypeCatagoty;
@interface TypeCatagoty : NSObject
@property (copy,nonatomic) NSString *catagoty;
@property (strong,nonatomic) TypeCatagoty *typeCatagoty;
@property (strong,nonatomic) NSArray *typeCatagotys;

@end
