//
//  RemoteApplicationCreateRequest.h
//  IHFRemoteConsultation
//
//  Created by chenjiasong on 16/12/13.
//  Copyright © 2016年 IHEFE CO., LIMITED. All rights reserved.
//

#import <IHFKit/IHFKit.h>
#import "RemoteFormResult.h"
#import "RemoteApplication.h"
#import "RemoteConsultationRequest.h"
@interface RemoteApplicationCreateRequest : RemoteConsultationRequest

// If not set , can from formResult
@property (nonatomic, strong) NSDictionary *content;
@property (nonatomic, strong) NSDictionary *content_text; /**< Currently use for record images upload in local area network */
@property (nonatomic, copy) NSString *template_id;

//@property (nonatomic, assign) NSInteger group_id;

// If not set , can from formResult.application
@property (copy, nonatomic) NSString *formTitle;
@property (copy, nonatomic) NSString *patientId;
@property (copy, nonatomic) NSString *patName;
@property (copy, nonatomic) NSString *recipient;
@property (copy, nonatomic) NSString *serverId;
@property (copy, nonatomic) NSString *hospital;
@property (copy, nonatomic) NSString *startTime;
@property (copy, nonatomic) NSString *planEndTime;
@property (copy, nonatomic) NSString *ihefeid; // 1health 
@property (copy, nonatomic) NSString *phoneNumber;

// Not know what to use , fixed set 1..
@property (copy, nonatomic) NSString *template_type;

// Send the patient image
@property (strong, nonatomic) NSArray <RemotePatientImage *> *patientImages;

// Ignore
@property (strong, nonatomic, readonly) RemoteApplication *application;

// It will be removed while do custom model convert to dictionary , it only use for primary key for save
@property (copy, nonatomic) NSString *applicationId;

- (instancetype)initWithApplication:(RemoteApplication *)application recipient:(NSString *)recipient serverId:(NSString *)serverId;
@end
