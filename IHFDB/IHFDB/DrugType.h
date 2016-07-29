//
//  DrugType.h
//  IHFDB
//
//  Created by CjSon on 16/6/29.
//  Copyright © 2016年 IHEFE CO., LIMITED. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TypeCatagoty.h"

@interface DrugType : NSObject

@property (copy,nonatomic) NSString *type;
@property (copy,nonatomic) NSString *doctorType;
@property (strong,nonatomic) TypeCatagoty *typeCatagoty;
@property (strong,nonatomic) NSNumber *drugTypeId;
@end
