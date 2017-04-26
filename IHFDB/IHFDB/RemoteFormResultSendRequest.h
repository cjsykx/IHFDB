//
//  RemoteFormResultSendRequest.h
//  IHFRemoteConsultation
//
//  Created by chenjiasong on 16/12/13.
//  Copyright © 2016年 IHEFE CO., LIMITED. All rights reserved.
//
#import <Foundation/Foundation.h>

#import "RemoteApplicationCreateRequest.h"

/*
 If send form result for application form ,it need RemoteApplicationCreateRequest all params
 If send Collection form , it only need content , template_id and applicationId ..
 */
@interface RemoteFormResultSendRequest : RemoteApplicationCreateRequest // extend
    
@property (copy, nonatomic) NSString *doctorNo;
@property (copy, nonatomic) NSString *hospId;

// Init with acording to you send to the type of the template

/**
 Send the application form 
 */
- (instancetype)initWithApplicationCreateRequest:(RemoteApplicationCreateRequest *)request;

@end
