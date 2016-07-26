//
//  ViewController.m
//  IHFDB
//
//  Created by CjSon on 16/6/8.
//  Copyright © 2016年 IHEFE CO., LIMITED. All rights reserved.
//

#import "ViewController.h"
#import "IHFDB.h"
#import "Patient.h"
#import "DateTool.h"
#import "Drug.h"
#import "Bed.h"
#import "DrugType.h"
#import "TypeCatagoty.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    int i = 16;
    NSMutableArray *array1 = [NSMutableArray array];
    
    Patient *patient = [[Patient alloc] init];
    patient.name = [NSString stringWithFormat:@"%@%d",@"张飞",i];
    patient.age = i;
    patient.recordDate = [NSDate date];
    patient.idCard = @(30.5);
    patient.height = 90.89;
    
    Drug *drug = [[Drug alloc] init];
    drug.name = @"感冒药";
    drug.price = @(10.5);
    
    Drug *drug1 = [[Drug alloc] init];
    drug1.name = @"后悔药";
    drug1.price = @(20.5);
    
    DrugType *type = [[DrugType alloc] init];
    type.type = @"处方药";
    type.doctorType = @"主治";
    
    TypeCatagoty *go = [[TypeCatagoty alloc] init];
    go.catagoty = @"口服";
    
    TypeCatagoty *go1 = [[TypeCatagoty alloc] init];
    go1.catagoty = @"注射";
    
    TypeCatagoty *go2 = [[TypeCatagoty alloc] init];
    go2.catagoty = @"滴注";
    
    go.typeCatagotys = [NSArray arrayWithObject:go2];
    
    go.typeCatagoty = go1;
    
    type.typeCatagoty = go;
    
    drug.drugType = type;
    drug1.drugType = type;
    
    [array1 addObject:drug];
    [array1 addObject:drug1];
    
    patient.drugs = array1;
    
    Bed *bed = [[Bed alloc] init];
    bed.bedNumber = @"+1";
    bed.ward = @"L1";
    
    patient.bed = bed;
    
//    NSLog(@"dictionaryBeConvertedFromModel = %@",patient.dictionaryBeConvertedFromModel);
    
    NSArray *patients = [NSArray arrayWithObjects:patient,patient, nil];
    
    NSLog(@"dictionaryBeConvertedFromModel = %@",patients.dictionaryArrayBeConvertedFromModelArray);

    Patient * model = [Patient modelBeConvertFromDictionary:patient.dictionaryBeConvertedFromModel];

    NSArray *models = [Patient modelArrayBeConvertFromDictionaryArray:patients.dictionaryArrayBeConvertedFromModelArray];
    
    for (Patient *model in models) {
        
        NSLog(@"model.name = %@",model.name);
        NSLog(@"age = %d",model.age);
        NSLog(@"bedNumber = %@",model.bed.bedNumber);
        NSLog(@"ward = %@",model.bed.ward);
        
        for (Drug *durg in patient.drugs) {
            NSLog(@"durgName = %@",durg.name);
            
            NSLog(@"durgtype name = %@",durg.drugType.type);
            
            NSLog(@"durgtype catagoty = %@",durg.drugType.typeCatagoty.catagoty);
            
            NSLog(@"durgtype - typeCatagoty - catagoty = %@",durg.drugType.typeCatagoty.typeCatagoty.catagoty);
            
            for (TypeCatagoty *ca in durg.drugType.typeCatagoty.typeCatagotys) {
                NSLog(@"durgtype - typeCatagoty - catagotys - catori = %@", ca.catagoty);
            }
            
        }
    }



//    [self selectFromDataBase];
//    IHFPredicate *predicate = [[IHFPredicate alloc] initWithFormat:@"idCard = %@",@(100)];
    
//    [Patient deleteAll];
//    IHFPredicate *predicate = [[IHFPredicate alloc] initWithFormat:@"name = %@",@"更只"];
//    [patient updateWithPredicate:predicate completeBlock:^(BOOL success) {
//    }];
    
    // 删除
//    [Patient deleteWithPredicate:predicate isCascade:NO completeBlock:^(BOOL success) {
//
//    }];

    //更新
//    [patient1 updateWithPredicate:predicate];

//    [Patient selectWithPredicate:predicate];
    
//    IHFPredicate *predicate = [[IHFPredicate alloc] initWithFormat:@"recordDate = %@",[DateTool dateToolforGetDateWithoutTimeWithDate:[NSDate date]]];
    
//    IHFPredicate *predicate = [[IHFPredicate alloc] initWithString:@"name = '张飞'"];
    
//    [patient1 updateWithPredicate:predicate];

//    [Patient deleteWithPredicate:predicate];
//    [patient1 updateWithPredicate:predicate completeBlock:^(BOOL success) {
//        NSLog(@"success = %d",success);
//    }];


}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)createTable{
    
    [Patient createTableDidCompleteBlock:^(BOOL success) {
        // 创建成功后的回调;
    }];
}

-(void)insertOneModelToDataBase{
    
    
    
    NSMutableArray *array1 = [NSMutableArray array];

    Patient *patient = [[Patient alloc] init];
    patient.name = @"张飞";
    patient.age = 40;
    patient.recordDate = [NSDate date];
    patient.idCard = @(30.5);
    patient.height = 90.89;

    Drug *drug = [[Drug alloc] init];
    drug.name = @"感冒药";
    drug.price = @(10.5);

    Drug *drug1 = [[Drug alloc] init];
    drug1.name = @"后悔药";
    drug1.price = @(20.5);

    DrugType *type = [[DrugType alloc] init];
    type.type = @"处方药";
    type.doctorType = @"主治";

    TypeCatagoty *go = [[TypeCatagoty alloc] init];
    go.catagoty = @"口服";

    TypeCatagoty *go1 = [[TypeCatagoty alloc] init];
    go1.catagoty = @"注射";

    TypeCatagoty *go2 = [[TypeCatagoty alloc] init];
    go2.catagoty = @"滴注";

    go.typeCatagotys = [NSArray arrayWithObject:go2];

    go.typeCatagoty = go1;

    type.typeCatagoty = go;

    drug.drugType = type;
    drug1.drugType = type;

    [array1 addObject:drug];
    [array1 addObject:drug1];

    patient.drugs = array1;

    Bed *bed = [[Bed alloc] init];
    bed.bedNumber = @"+1";
    bed.ward = @"L1";
    
    patient.bed = bed;

    // If you want to insert the patient
    [patient save];

}

-(void)insertManyModelToDataBase{
    
    NSMutableArray *patients = [NSMutableArray array];
    
    for (int i = 0; i < 5000; i++) {
        
        NSMutableArray *array1 = [NSMutableArray array];
        
        Patient *patient = [[Patient alloc] init];
        patient.name = [NSString stringWithFormat:@"%@%d",@"张飞",i];
        patient.age = i;
        patient.recordDate = [NSDate date];
        patient.idCard = @(30.5);
        patient.height = 90.89;
        
        Drug *drug = [[Drug alloc] init];
        drug.name = @"感冒药";
        drug.price = @(10.5);
        
        Drug *drug1 = [[Drug alloc] init];
        drug1.name = @"后悔药";
        drug1.price = @(20.5);
        
        DrugType *type = [[DrugType alloc] init];
        type.type = @"处方药";
        type.doctorType = @"主治";
        
        TypeCatagoty *go = [[TypeCatagoty alloc] init];
        go.catagoty = @"口服";
        
        TypeCatagoty *go1 = [[TypeCatagoty alloc] init];
        go1.catagoty = @"注射";
        
        TypeCatagoty *go2 = [[TypeCatagoty alloc] init];
        go2.catagoty = @"滴注";
        
        go.typeCatagotys = [NSArray arrayWithObject:go2];
        
        go.typeCatagoty = go1;
        
        type.typeCatagoty = go;
        
        drug.drugType = type;
        drug1.drugType = type;
        
        [array1 addObject:drug];
        [array1 addObject:drug1];
        
        patient.drugs = array1;
        
        Bed *bed = [[Bed alloc] init];
        bed.bedNumber = @"+1";
        bed.ward = @"L1";
        
        patient.bed = bed;
        
        [patients addObject:patient];
    }
    
    // 建议在病人多的情况下，调用
    
    NSDate *beginDate = [NSDate date];
    
    [Patient saveModelArray:patients completeBlock:^(BOOL success) {
        //        NSLog(@"因为这是使用事务,增加插入速度");
        NSLog(@"话费时间 ＝ %f",[[NSDate date] timeIntervalSince1970] - [beginDate timeIntervalSince1970]);
    }];
}

-(void)selectFromDataBase{
    
    NSDate *beginDate = [NSDate date];

    IHFPredicate *predicate = [[IHFPredicate alloc] initWithFormat:@"age < %d",100];
    
    predicate.orderBy = @"recordDate asc";

    NSArray *patients =  [Patient selectWithPredicate:predicate];
    NSLog(@"cost time ＝ %f",[[NSDate date] timeIntervalSince1970] - [beginDate timeIntervalSince1970]);


    if ([patients count]) {

        for (Patient *patient in patients) {
            NSLog(@"%@",patient.name);

            for (Drug *durg in patient.drugs) {
                NSLog(@"durgName = %@",durg.name);

                NSLog(@"durgtype name = %@",durg.drugType.type);

                NSLog(@"durgtype catagoty = %@",durg.drugType.typeCatagoty.catagoty);

                NSLog(@"durgtype - typeCatagoty - catagoty = %@",durg.drugType.typeCatagoty.typeCatagoty.catagoty);

                for (TypeCatagoty *ca in durg.drugType.typeCatagoty.typeCatagotys) {
                    NSLog(@"durgtype - typeCatagoty - catagotys - catori = %@", ca.catagoty);
                }

            }
            NSLog(@"age = %d",patient.age);
            NSLog(@"%@",patient.recordDate);
            NSLog(@"11--%@",patient.idCard);
            NSLog(@"class--%@",[patient.idCard class]);

            NSLog(@"height--%f",patient.height);

            NSLog(@"id = %d",patient.objectID);
            NSLog(@"111--%@",[DateTool dateToolForGetDateStringWithdate:patient.recordDate]);
        }


    }else{
        
    }


}

// statement BY you
-(void)updateStatementByYou{
    
    // 也可以自己写sql语句
    [Patient executeUpdateWithSqlStatement:@"INSERT INTO Patient (name,age,height,recordDate,idCard) VALUES ('神1',70,0,'(null)','20')"];

//    [Patient executeUpdateWithSqlStatement:@"INSERT INTO Patient (name,age,height,recordDate,idCard) VALUES ('神1',70,0,'(null)','20')" completeBlock:^(BOOL success) {
//                NSLog(@"save success");
//    }];
    
    
    // query
    //    NSArray *array = [Patient executeQueryWithSqlStatement:@"SELECT * FROM Patient WHERE name = '张量' or name = '吕蒙'"];

}


@end
