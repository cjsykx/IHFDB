//
//  Request.h
//  IHFDB
//
//  Created by chenjiasong on 2017/4/20.
//  Copyright © 2017年 IHEFE CO., LIMITED. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RemoteApplicationCreateRequest.h"

@interface Request : NSObject
@property (strong,nonatomic) RemoteApplicationCreateRequest *request;
@property (copy,nonatomic) NSString *requestId;

@end
