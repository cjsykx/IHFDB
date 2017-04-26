//
//  RemoteApplicationCreateRequest.m
//  IHFRemoteConsultation
//
//  Created by chenjiasong on 16/12/13.
//  Copyright © 2016年 IHEFE CO., LIMITED. All rights reserved.
//

#import "RemoteApplicationCreateRequest.h"

@implementation RemoteApplicationCreateRequest

//- (instancetype)initWithApplication:(RemoteApplication *)application recipient:(NSString *)recipient serverId:(NSString *)serverId {
//    self = [super init];
//    if (self) {
//        _recipient = recipient;
//        _serverId = serverId;
//        if (application) {
//            _application = application;
//            RemoteFormResult *result = application.formResult;
//            self.template_id = result.template_id;
//            self.content = result.resultDictM;
//            self.applicationId = result.applicationId;
//            self.patientImages = result.patientImages;
//            self.content_text  = result.additionalResultDictM;
//
//            // Application
//            self.formTitle = application.title;
//            self.patientId = application.patient.homepageNo;
//            self.startTime = application.startTime;
//            self.planEndTime = application.planEndTime;
//            self.hospital = @"tlyy";
//            self.patName = application.patientName;
//            self.ihefeid = application.ihefeId;
//            self.phoneNumber = @"13818183704";
//        }
//    }
//    return self;
//}

+ (NSDictionary *)propertyNameDictForClassInArray {
    return @{@"patientImages": [PatientImage class]};
}

+ (NSArray<NSString *> *)propertyNamesForCustomPrimarykeys {
    return @[@"applicationId"];
}

+ (NSDictionary *)propertyNameDictForMapper {
    return @{@"formTitle" : @"formtitle" };
}
    
- (NSDictionary *)content_text {
    if (!_content_text) {
        _content_text = [[NSDictionary alloc] init];
    }
    return _content_text;
}
    
+ (NSArray <NSString *>*)propertyNamesForIgnore {
    return @[@"application"];
}

- (NSString *)template_type {
    return @"1";
}

@end
