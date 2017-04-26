//
//  RemoteFormResultSendRequest.m
//  IHFRemoteConsultation
//
//  Created by chenjiasong on 16/12/13.
//  Copyright © 2016年 IHEFE CO., LIMITED. All rights reserved.
//

#import "RemoteFormResultSendRequest.h"

@implementation RemoteFormResultSendRequest
+ (NSArray<NSString *> *)propertyNamesForCustomPrimarykeys {
    return @[@"applicationId"];
}

- (instancetype)initWithApplicationCreateRequest:(RemoteApplicationCreateRequest *)request {
    self = [super init];
    if (self) {
        self.content = request.content;
        self.content_text = request.content_text;
        self.template_id = request.template_id;
        self.formTitle = request.formTitle;
        self.patientId = request.patientId;
        self.recipient = request.recipient;
        self.serverId  =  request.serverId;
        self.hospital  =  request.hospital;
        self.startTime = request.startTime;
        self.planEndTime = request.planEndTime;
        self.ihefeid   =  request.ihefeid;
        self.phoneNumber =  request.phoneNumber;
        self.template_type = request.template_type;
        self.patientImages = request.patientImages;
        self.patName = request.patName;
    }
    return self;
}

@end
