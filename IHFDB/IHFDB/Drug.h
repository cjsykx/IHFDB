//
//  Drug.h
//  IHFDB
//
//  Created by CjSon on 16/6/23.
//  Copyright © 2016年 IHEFE CO., LIMITED. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DrugType.h"
@interface Drug : NSObject
@property (copy,nonatomic) NSString *name;
@property (strong,nonatomic) NSNumber *price;
@property (strong,nonatomic) DrugType *drugType;
@end
