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
#import "MJExtension.h"
#import "IHFDataBaseExecute.h"
#import "IHFAlertController.h"
#import "Dog.h"
#import "Request.h"
#import "IHFDBChain.h"
@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *operations;

// deal with patients model
@property (strong, nonatomic) NSArray <Patient *>*patients;

@property (assign, nonatomic) BOOL useChain;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    [self setupTableView];
    self.operations = @[@"字典和模型的互转",@"创建表(CreateTable)",@"保存(Save)到数据库(单条)",@"保存(Save)到数据库(多条)",@"保存(Save)时删除脏数据(delete dirty data)",@"删除(Delete)通过IHFPrecidate",@"删除(Delete)通过主键",@"删除(Delete)通过自定义字段(column)",@"删除(Delete)通过自身(实例方法)",@"更新指定字段(Update)Precidate",@"更新指定字段(Update)Primarykey",@"更新指定字段(Update)customColumns",@"更新(Update)通过自身主键",@"更新指定字段(Update)(自身有值)",@"更新(Update)指定字段(值设置)",@"查询(Select)通过IHFPrecidate",@"查询(Select)通过主键(primarykeys)",@"查询(Select)通过自定义字段(customColumn)",@"查询(Select)不用递归(不查有关系属性)",@"模型转字典(直接不用申请关系)"];
    
    _useChain = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI
- (void)setupTableView {
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 10, self.view.frame.size.width, self.view.frame.size.height - 10) style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    _tableView = tableView;
    [self.view addSubview:tableView];
}

#pragma mark - table view delegate and datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.operations count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"IHFDBCellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    cell.textLabel.text = [self.operations objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[self.operations objectAtIndex:indexPath.row] isEqualToString:@"字典和模型的互转"]) {
        [self convertTo];
    } else if ([[self.operations objectAtIndex:indexPath.row] isEqualToString:@"模型转字典(直接不用申请关系)"]) {
        [self JSONObjectFromModelNotUseRelationShipTest];
    } else if ([[self.operations objectAtIndex:indexPath.row] isEqualToString:@"创建表(CreateTable)"]) {
        [self createTable];
    } else if ([[self.operations objectAtIndex:indexPath.row] isEqualToString:@"保存(Save)到数据库(单条)"]) {
        [self insertOneModelToDataBase];
    } else if ([[self.operations objectAtIndex:indexPath.row] isEqualToString:@"保存(Save)到数据库(多条)"]) {
        [self insertManyModelToDataBase];
    } else if ([[self.operations objectAtIndex:indexPath.row] isEqualToString:@"保存(Save)时删除脏数据(delete dirty data)"]) {
        [self deleteDirtyData];
    } else if ([[self.operations objectAtIndex:indexPath.row] isEqualToString:@"删除(Delete)通过主键"]) {
        [self deleteWithPirmaryKeys];
    } else if ([[self.operations objectAtIndex:indexPath.row] isEqualToString:@"删除(Delete)通过自身(实例方法)"]) {
        [self deleteWithSelf];
    } else if ([[self.operations objectAtIndex:indexPath.row] isEqualToString:@"删除(Delete)通过IHFPrecidate"]) {
        [self deleteWithPredicate];
    } else if ([[self.operations objectAtIndex:indexPath.row] isEqualToString:@"删除(Delete)通过自定义字段(column)"]) {
        [self deleteWithCustomColunm];
    } else if ([[self.operations objectAtIndex:indexPath.row] isEqualToString:@"更新指定字段(Update)Precidate"]) {
        [self updateColomnsByPredicate];
    } else if ([[self.operations objectAtIndex:indexPath.row] isEqualToString:@"更新指定字段(Update)Primarykey"]) {
        [self updateColumnsByPrimaryKey];
    } else if ([[self.operations objectAtIndex:indexPath.row] isEqualToString:@"更新指定字段(Update)customColumns"]) {
        [self updateColumnsByCustomColunms];
    } else if ([[self.operations objectAtIndex:indexPath.row] isEqualToString:@"更新(Update)通过自身主键"]) {
        [self updateByMyself];
    } else if ([[self.operations objectAtIndex:indexPath.row] isEqualToString:@"更新指定字段(Update)(自身有值)"]) {
        [self updateColumnsForSelfArray];
    } else if ([[self.operations objectAtIndex:indexPath.row] isEqualToString:@"更新(Update)指定字段(值设置)"]) {
        [self updateColumnsForGivenValue];
    } else if ([[self.operations objectAtIndex:indexPath.row] isEqualToString:@"查询(Select)通过IHFPrecidate"]) {
        [self selectByPredicate];
    } else if ([[self.operations objectAtIndex:indexPath.row] isEqualToString:@"查询(Select)通过主键(primarykeys)"]) {
        [self selectByCustomPrimaryKeyValueFromDataBase];
    } else if ([[self.operations objectAtIndex:indexPath.row] isEqualToString:@"查询(Select)不用递归(不查有关系属性)"]) {
        [self selectNotUseRecursive];
    } else if ([[self.operations objectAtIndex:indexPath.row] isEqualToString:@"查询(Select)通过自定义字段(customColumn)"]) {
        [self selectByCustomCulunm];
    }
}

#pragma mark - Json and model convert
- (void)JSONObjectFromModelNotUseRelationShipTest {
    Patient *patient = [[Patient alloc] init];
    patient.dogs = [NSMutableArray array];
    
    for (int i = 0; i < 5; i++) {
        Dog *dog = [[Dog alloc] init];
        dog.dogName = [NSString stringWithFormat:@"pity%d",i];
        [patient.dogs addObject:dog];
    }
    NSLog(@"jsonObject = %@",[patient JSONObjectFromModel]);
}

/**
 字典与模型的互转
 */
- (void)convertTo {
    
    NSMutableArray *patients = [NSMutableArray array];
    
    for (int i = 0; i < 2; i++) {
        
        NSMutableArray *array1 = [NSMutableArray array];
        
        Patient *patient = [[Patient alloc] init];
        patient.name = [NSString stringWithFormat:@"%@%d",@"张飞",i];
        patient.age = 5100 - i;
        patient.recordDate = [NSDate date];
        patient.idCard = @(1);
        patient.height = 100.89;
        patient.patientID = i;
        patient.test = @"333";
        patient.dict = @{
                         @"patient" : @"guanyu",
                         @"arry1" : [Drug JSONObjectsFromModelArray:array1],               };
        
        patient.dictM = [NSMutableDictionary dictionaryWithObject:patient.dict forKey:@"key"];
        
        patient.array = @[@"没有包含模型的数组",@"Not contain model in array"];
        patient.arrayM = [NSMutableArray arrayWithArray:patient.array];
        
        [self printPropertys:patient];
        Drug *drug = [[Drug alloc] init];
        drug.drugID = @(1);
        drug.name = @"感冒药";
        drug.price = @(10.5);
        
        Drug *drug1 = [[Drug alloc] init];
        drug1.price = @(20.5);
        
        if (i % 2 == 0){
            drug1.name = @"后悔药";
            drug1.drugID = @(2);
            
        } else {
            drug1.name = @"消炎药";
            drug1.drugID = @(3);
        }
                
        DrugType *type = [[DrugType alloc] init];
        type.type = @"处方药";
        type.doctorType = @"主治";
        type.drugTypeId = @(1);
        
        
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
        bed.bedID = @(2);
        
        patient.bed = bed;
        
        NSRange range;
        range.length = 5;
        range.location = 2;
        patient.range = range;
        
        [patients addObject:patient];
    }

    // begin convert
    NSDate *beginDate = [NSDate date];
    NSLog(@"begin model -> dict");
    NSArray *dicts = [patients JSONObjectsFromModelArray];
    NSLog(@"cost time for model -> dict ＝ %f",[[NSDate date] timeIntervalSince1970] - [beginDate timeIntervalSince1970]);

    NSDate *beginDateMJ = [NSDate date];
    NSLog(@"begin MJ model -> dict");
    NSArray *dictsMJ = [Patient mj_keyValuesArrayWithObjectArray:patients];
    NSLog(@"cost time MJ for model -> dict ＝ %f",[[NSDate date] timeIntervalSince1970] - [beginDateMJ timeIntervalSince1970]);

    NSDate *beginDate1 = [NSDate date];
    NSLog(@"begin dict -> model");
    NSArray *models = [Patient modelsFromJSONObjectArray:dicts];
    NSLog(@"cost time for dict -> model ＝ %f",[[NSDate date] timeIntervalSince1970] - [beginDate1 timeIntervalSince1970]);

    NSDate *beginDate1MJ = [NSDate date];
    NSLog(@"begin dict -> model");
    NSArray *modelsMJ = [Patient mj_objectArrayWithKeyValuesArray:dicts];
    NSLog(@"cost time for MJ dict -> model ＝ %f",[[NSDate date] timeIntervalSince1970] - [beginDate1MJ timeIntervalSince1970]);
    
    [self printPatients:models];
}

#pragma mark - create table
- (void)createTable {
    BOOL result;
    if (self.useChain) {
        result = CreateTable(Patient)
        .FromTable(nil)    // Default Class name , you can set your need table name ... Warning : If set table name , you need do other CURL in your set table name ....
        .execute;
    } else {
        result = [Patient createTable];
    }
    if (result) {
        NSLog(@"create table success");
    } else {
        NSLog(@"create table fail");
    }
}

#pragma mark - save
- (void)insertOneModelToDataBase {
    if (self.useChain) {
        SaveModels([self.patients firstObject]).execute;
    } else {
        Patient *patient = [self.patients firstObject];
        // If you want to insert the patient
        [patient save];
    }
    [self printPatients:[Patient selectAll]];
}

- (void)insertManyModelToDataBase {
    
    if (self.useChain) {
        SaveModels(self.patients).execute;
        // Or
//        Save(Patient).Models(self.patients).execute;
    } else {
        NSDate *beginDate = [NSDate date];
        [Patient saveModelArray:self.patients completeBlock:^(BOOL success,IHFDatabase *db) {
            NSLog(@"话费时间 ＝ %f",[[NSDate date] timeIntervalSince1970] - [beginDate timeIntervalSince1970]);
        }];
        // Or
//        [self.patients save];
    }
    [self printPatients:[Patient selectAll]];
}

- (void)insertManyRequest {
    
    [Request createTable];
    NSMutableArray *requestsM= [NSMutableArray array];
    for (int i = 0; i < 5; i++) {
        Request *request = [[Request alloc] init];
        request.requestId = [NSString stringWithFormat:@"%d",i];
        
        RemoteApplicationCreateRequest *create = [[RemoteApplicationCreateRequest alloc] init];
        PatientImage *patientImage = [[PatientImage alloc] init];
        patientImage.imageId = @"1";
        patientImage.imageName = @"影像1";
        PatientImage *patientImage1 = [[PatientImage alloc] init];
        patientImage1.imageId = @"2";
        patientImage1.imageName = @"影像2";
        create.patientImages = @[patientImage,patientImage1];
        
        request.request = create;
        
        [requestsM addObject:request];
    }
    
    [Request saveModelArray:requestsM completeBlock:^(BOOL success,IHFDatabase *db) {
        NSArray <Request *> *select = [Request selectAll];
        [select enumerateObjectsUsingBlock:^(Request * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSLog(@"patientImages = %@",obj.request.patientImages);
            for (PatientImage *image in obj.request.patientImages) {
                NSLog(@"imageName = %@",image.imageName);
            }
        }];
    }];
}

#pragma mark - select
- (void)selectByCustomPrimaryKeyValueFromDataBase {
    // Patient have priamry key id @[@"patientID",@"hostipalID"];
    if (self.useChain) {
        NSArray *patients = Select(Patient).WhereByPrimaryKeyValues(@[@1,@1]).query;
        [self printPatients:patients];
    } else {
        NSArray *patients = [Patient selectWithCustomPrimaryKeyValues:@[@1,@1]];
        [self printPatients:patients];
    }
}

- (void)selectByCustomCulunm {
    if (self.useChain) {
        NSArray *patients = Select(Patient)
        .WhereByColumns(@[@"hostipalID"])
        .ColumnsValues(@[@1])
        .Order(@"age")
        .IsRecursive(YES) // Default
        .query;

        [self printPatients:patients];
    } else {
        NSArray *patients = [Patient selectWithColumns:@[@"hostipalID"] withValues:@[@1]];
        [self printPatients:patients];
    }
}

- (void)selectByPredicate {
    if (self.useChain) {
        NSArray *patients = Select(Patient)
        .Where(@"recordDate > %@ and age < %d",[[NSDate date] dateByAddingTimeInterval:60 * 60 * -5],90)
        .Order(@"age")
        .Limit(0,5)
        .query;
        [self printPatients:patients];
    } else {
        IHFPredicate *predicate = [[IHFPredicate alloc] initWithFormat:@"recordDate > %@ and mapperStr1 = %@",[[NSDate date] dateByAddingTimeInterval:60 * 60 * -5],nil];
        NSArray *patients = [Patient selectWithPredicate:predicate];
        [self printPatients:patients];
    }
}

- (void)selectNotUseRecursive {
    if (self.useChain) {
        NSArray *patients = Select(Patient)
        .Where(@"age < %d",50)
        .Order(@"recordDate")
        .IsRecursive(NO)
        .query;
        
        [self printPatients:patients];
    } else {
        NSDate *beginDate = [NSDate date];
        IHFPredicate *predicate = [[IHFPredicate alloc] initWithFormat:@"age < %d",50];
        predicate.orderBy = @"recordDate";
        NSArray *patients =  [Patient selectWithPredicate:predicate isRecursive:NO];
        NSLog(@"cost time ＝ %f",[[NSDate date] timeIntervalSince1970] - [beginDate timeIntervalSince1970]);
        [self printPatients:patients];
    }
}

- (void)selectByDate {
    NSDate *date = [DateTool dateToolforGetDateWithoutTimeWithDate:[NSDate date]];
    
    NSArray *patients = [Patient selectWithPredicate:[[IHFPredicate alloc] initWithFormat:@"birthday > %@",date]];
    for (Patient *patient in patients) {
        NSLog(@"name =  %@",patient.name);
        NSLog(@"birthday = %@",patient.birthday);
    }
}

#pragma mark - delete
- (void)deleteWithPredicate {
    if (_useChain) {
        Delete(Patient).Where(@"patientID < %d and hostipalID = '%@'",3,@1).IsCascade(YES).execute;
    } else {
        [Patient deleteWithPredicate:[[IHFPredicate alloc] initWithFormat:@"patientID < %d and hostipalID = '%@'",3,@1] isCascade:YES completeBlock:nil];
    }
    [self printPatients:[Patient selectAll]];
}

- (void)deleteAllWithPredicate {
    // If want delete all
    if (_useChain) {
        Delete(Patient).Where(nil).IsCascade(YES).execute;
    } else {
        [Patient deleteAll];
    }
    [self printPatients:[Patient selectAll]];
}

- (void)deleteWithPirmaryKeys {
    // Warning : need set primary keys ...
    // like Patient primary keys : return @[@"patientID",@"hostipalID"];

    NSArray *values = @[@1,@1];
    NSLog(@"Before delete = %d",Select(Patient).WhereByPrimaryKeyValues(values).query.count);
    if (_useChain) {
        Delete(Patient).WhereByPrimaryKeyValues(values).IsRecursive(NO).execute; // Recursive Default NO ..
    } else {
        [Patient deleteWithCustomPrimaryKeyValues:values];
    }
    NSLog(@"after delete = %d",[Patient selectWithCustomPrimaryKeyValues:values].count);
}

- (void)deleteWithCustomColunm {
    NSArray *column = @[@"patientID",@"hostipalID"];
    NSArray *values = @[@1,@1];
    NSLog(@"Before delete = %d",Select(Patient).WhereByColumns(column).ColumnsValues(values).count);
    if (_useChain) {
        Delete(Patient).WhereByColumns(column).ColumnsValues(values).IsRecursive(NO).execute; // Recursive Default NO ..
    } else {
        [Patient deleteWithColumns:column withValues:values];
    }
    NSLog(@"after delete = %d",[Patient selectWithColumns:column withValues:values].count);
}

- (void)deleteWithSelf {
    __block NSMutableArray *deletePatients = [NSMutableArray array];
    [self.patients enumerateObjectsUsingBlock:^(Patient * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx % 2 == 0) {
            [deletePatients addObject:obj];
        }
    }];
    if (_useChain) {
        DeleteModels(deletePatients).execute;
    } else {
        [deletePatients deleteFromTableIsCascade:NO completeBlock:^(BOOL result, IHFDatabase *db) {
            NSLog(@"结果 = %d",result);
        }];
    }
    [self printPatients:[Patient selectAll]];
}

- (void)deleteWithModel {
    Patient *patient = [self.patients firstObject];
    if (_useChain) {
        DeleteModels(patient).execute;
    } else {
        [patient deleteFromTableIsCascade:NO completeBlock:^(BOOL result, IHFDatabase *db) {
            NSLog(@"结果 = %d",result);
        }];
    }
    [self printPatients:[Patient selectAll]];
}

- (void)deleteDirtyData {
    
    // delete the data NOT fetch in network
    // Like we have inserted the patient id (0 - 9) , but now the network only give us where (id % 2 == 0) , other patients have out of hopital .
    // also can DeleteDirtyData(Patient).DeleteDirtyDataWhere(nil).execute;

    NSMutableArray *patientsInHospital = [NSMutableArray array];
    [self.patients enumerateObjectsUsingBlock:^(Patient * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.patientID % 2 == 0) {
            [patientsInHospital addObject:obj];
        }
    }];
    if (self.useChain) {
        [SaveModels(patientsInHospital)
         .DeleteDirtyDataWhere(@"hostipalID = %@",@1)
         executeCompletion:^(BOOL success, IHFDatabase *db) {
             NSLog(@"delete dirty data success");
         }];
    } else {
        [patientsInHospital save];
        IHFPredicate *predicate = [IHFPredicate predicateWithString:nil];
        [Patient deleteWithPredicate:predicate];
    }
    [self printPatients:[Patient selectAll]];
}

#pragma mark - update
- (void)updateColomnsByPredicate {
    NSArray *updateColumns = @[@"mapperStr1",@"mapperNumber1"];
    NSArray *updateValues = @[@"updateMapperStr1",@"updateMapperNumbers1"];
    IHFPredicate *predicate = [IHFPredicate predicateWithFormat:@"patientID = %d and hostipalID = %@",3,@1];

    if (self.useChain) {
        Update(Patient).UpdateColumns(updateColumns).UpdateValues(updateValues).Where(@"patientID = %d and hostipalID = %@",3,@1).execute;
    } else {
        [Patient updateColumns:updateColumns setValues:updateValues predicate:predicate];
    }
    [self printPatients:[Patient selectWithPredicate:predicate]];
}

- (void)updateColumnsByPrimaryKey {
    NSArray *values = @[@1,@1];
    
    NSArray *updateColumns = @[@"mapperStr1",@"mapperNumber1"];
    NSArray *updateValues = @[@"updateMapperStr1ByPrimaryKeys",@"updateMapperNumbers1ByPirmaryKeys"];

    if (self.useChain) {
        Update(Patient).UpdateColumns(updateColumns).UpdateValues(updateValues).WhereByPrimaryKeyValues(values).execute;
    } else {
        [Patient updateColumns:updateColumns setValues:updateValues customPrimaryKeyValues:values fromTable:nil inDataBase:nil completeBlock:^(BOOL result, IHFDatabase *db) {
            NSLog(@"111");
        }];
    }
    [self printPatients:Select(Patient).WhereByPrimaryKeyValues(values).query];
}

- (void)updateColumnsByCustomColunms {
    NSArray *column = @[@"patientID",@"hostipalID"];
    NSArray *values = @[@1,@1];
    
    NSArray *updateColumns = @[@"mapperStr1",@"mapperNumber1"];
    NSArray *updateValues = @[@"updateMapperStr1ByCustomColunms",@"updateMapperNumbers1ByCustomColunms"];

    [Patient updateColumns:updateColumns setValues:updateValues conditionColumns:column conditionValues:values fromTable:nil inDataBase:nil completeBlock:nil];
    [self printPatients:Select(Patient).WhereByPrimaryKeyValues(values).query];
}

- (void)updateByMyself {
    Patient *patient = [self.patients firstObject];
    patient.mapperStr1 = @"mapperStr1BySelf";
    patient.mapperNumber1 = @"mapperNumber1BySelf";
    
    PatientImage *image = [patient.request.patientImages firstObject];
    image.imageName = @"影像1Update";
    PatientImage *image3 = [[PatientImage alloc] init];
    image3.imageId = @"3";
    image3.imageName = @"影像3new";
    NSMutableArray *patientImages = [NSMutableArray arrayWithArray:patient.request.patientImages];
    [patientImages addObject:image3];
    patient.request.patientImages = patientImages;
    
    if (_useChain) {
        UpdateModels(patient).execute;
    } else {
        [patient updateFromTable];
    }
    [self printPatients:Select(Patient).WhereByPrimaryKeyValues(@[@(patient.patientID),patient.hostipalID]).query];
}

- (void)updateByMyModelArray {
    NSMutableArray *patientsInHospital = [NSMutableArray array];
    [self.patients enumerateObjectsUsingBlock:^(Patient * _Nonnull patient, NSUInteger idx, BOOL * _Nonnull stop) {
        if (patient.patientID % 2 == 0) {
            [patientsInHospital addObject:patient];
            patient.mapperStr1 = @"mapperStr1BySelf";
            patient.mapperNumber1 = @"mapperNumber1BySelf";
        }
    }];
    if (_useChain) {
        UpdateModels(patientsInHospital).execute;
    } else {
        [patientsInHospital updateFromTable];
    }
    [self printPatients:[Patient selectAll]];
}

- (void)updateColumnsForSelf {
    NSArray *updateColumns = @[@"mapperStr1",@"mapperNumber1"];

    Patient *patient = [[Patient alloc] init];
    // Must have priamry key values..
    patient.patientID = 1;
    patient.hostipalID = @1;
    patient.mapperStr1 = @"updateColumnMapperStr1BySelf";
    patient.mapperNumber1 = @"updateColumnMapperNumber1BySelf";
    patient.age = 1000;  // It will ignore it

    if (_useChain) {
        UpdateModels(patient).UpdateColumns(updateColumns).execute;
    } else {
        [patient updateColumns:updateColumns];
    }
    [self printPatients:Select(Patient).WhereByPrimaryKeyValues(@[@(patient.patientID),patient.hostipalID]).query];
}

- (void)updateColumnsForSelfArray {
    NSArray *updateColumns = @[@"mapperStr1",@"mapperNumber1"];
    NSMutableArray *patients = [NSMutableArray array];
    for (int i = 1; i < 6; i++) {
        Patient *patient = [[Patient alloc] init];
        patient.patientID = i;
        patient.hostipalID = @1;
        patient.mapperStr1 = @"updateColumnMapperStr1BySelf";
        patient.mapperNumber1 = @"updateColumnMapperNumber1BySelf";
        [patients addObject:patient];
    }
    if (_useChain) {
        UpdateModels(patients).UpdateColumns(updateColumns).execute;
    } else {
        [patients updateColumns:updateColumns];
    }
    [self printPatients:[Patient selectAll]];
}

- (void)updateColumnsForGivenValue {
    Patient *patient = [self.patients firstObject];
    
    NSArray *updateColumns = @[@"mapperStr1",@"mapperNumber1"];
    NSArray *updateValues = @[@"updateMapperStr1ByGivenValue",@"updatemapperNumber1ByGivenValue"];

    if (_useChain) {
        UpdateModels(patient).UpdateColumns(updateColumns).UpdateValues(updateValues).execute;
    } else {
        [patient updateColumns:updateColumns setValues:updateValues];
    }
    [self printPatients:Select(Patient).WhereByPrimaryKeyValues(@[@(patient.patientID),patient.hostipalID]).query];
}

// statement BY you
- (void)updateStatementByYou {
    // 也可以自己写sql语句
    [Patient executeUpdateWithSqlStatement:@"INSERT INTO Patient (name,age,height,recordDate,idCard) VALUES ('神1',70,0,'(null)','20')"];
}

#pragma mark - print
- (void)printPropertys:(Patient *)patient {
    NSLog(@"%@",@"开始打印结果 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
    NSLog(@"111 - %@",patient.getAllPropertyName);
    NSLog(@"ignore = %@",[patient dictWithIgnoredPropertyNames]);
    NSLog(@"array = %@",[[patient class] propertiesForTypeOfArray]);
    NSLog(@"model = %@",[[patient class] propertiesForTypeOfModel]);
    NSLog(@"allow = %@",[[patient class] allowedPropertyNames]);
    NSLog(@"map = %@",[[patient class] mappedPropertyNameDicts]);
    NSLog(@"relation = %@",[[patient class] relationPropertyNameDicts]);

    [[patient class] enumeratePropertiesUsingBlock:^(IHFProperty *property, NSUInteger idx, BOOL *stop) {
        NSLog(@"%@",property.propertyName);
    }];
}

- (void)printPatients:(NSArray *)patients {
    
    NSLog(@"%@,个数 = %d",@"开始打印结果 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>",[patients count]);
    if ([patients count]) {
        
        for (Patient *patient in patients) {
            
            NSLog(@"primary key = %@",[patient customPrimarykeyValues]);
            
            NSLog(@"name = %@",patient.name);
            
            NSLog(@"hostipalID = %@",patient.hostipalID);
            NSLog(@"hostipalID class = %@",[patient.hostipalID class]);

            
            NSLog(@"Aclass = %@",patient.aclass);
            NSLog(@"Aclass class= %@",[patient.aclass class]);

            NSLog(@"test = %@",patient.test);
            NSLog(@"testclass = %@",[patient.test class]);
            
            NSLog(@"age = %d",patient.age);
            NSLog(@"idCard = %@",patient.idCard);
            
            NSLog(@"aBlock = %@",patient.aBlock);

            NSLog(@"mapperstr1 = %@",patient.mapperStr1);
            NSLog(@"mappersrt1 class = %@",[patient.mapperStr1 class]);

            NSLog(@"mapperNumber1 = %@",patient.mapperNumber1);
            NSLog(@"mapperNumber1 class = %@",[patient.mapperNumber1 class]);

            NSLog(@"dict = %@",patient.dict);
            NSLog(@"dict class = %@",[patient.dict class]);
            
            NSLog(@"dictM = %@",patient.dictM);
            NSLog(@"dictM class = %@",[patient.dictM class]);
            
            // array not contain model
            NSLog(@"array = %@",patient.array);
            NSLog(@"array class = %@",[patient.array class]);
            
            NSLog(@"arrayM = %@",patient.arrayM);
            NSLog(@"arrayM class = %@",[patient.arrayM class]);

            NSLog(@"length = %d",patient.range.length);
            NSLog(@"location = %d",patient.range.location);
            
            NSLog(@"image = %@",patient.image);
            NSLog(@"image class = %@",patient.image.class);
            
            NSLog(@"data = %@",patient.data);
            NSLog(@"data class = %@",patient.data.class);

            for (Drug *durg in patient.drugs) {
                NSLog(@"durgName = %@",durg.name);
                NSLog(@"patient-ID = %d",durg.parentObject.objectID);
                NSLog(@"durgtype name = %@",durg.drugType.type);
                NSLog(@"durgtype catagoty = %@",durg.drugType.typeCatagoty.catagoty);
                NSLog(@"durgtype - typeCatagoty - catagoty = %@",durg.drugType.typeCatagoty.typeCatagoty.catagoty);
                
                for (TypeCatagoty *ca in durg.drugType.typeCatagoty.typeCatagotys) {
                    NSLog(@"durgtype - typeCatagoty - catagotys - catori = %@", ca.catagoty);
                }
            }
            
            NSLog(@"bedNumber  = %@",patient.bed.bedNumber);
            NSLog(@"bedID  = %@",patient.bed.bedID);
            NSLog(@"bed.patient-ID = %d",patient.bed.parentObject.objectID);
            
            NSLog(@"recordDate = %@",patient.recordDate);
            NSLog(@"idCard = %@",patient.idCard);
            NSLog(@"idCard class -- %@",[patient.idCard class]);
            
            NSLog(@"height = %f",patient.height);
            
            NSLog(@"objectID = %d",patient.objectID);
            NSLog(@"recordDate = %@",[DateTool dateToolForGetDateStringWithdate:patient.recordDate]);
            
            NSLog(@"patientImages = %@",patient.request.patientImages);
            
            for (PatientImage *image in patient.request.patientImages) {
                NSLog(@"%@",image.imageName);
            }
        }
    }
}

#pragma mark - test error
- (void)beyongOfArray:(NSArray *)arr {
    NSLog(@"222");
    NSArray *array = [NSArray arrayWithObject:@"there is only one object in this arary app will crash and throw an exception!"];
    NSLog(@"%@", [array objectAtIndex:1]); // Index 1 beyond 0 - 0
    NSLog(@"222222");
}

- (void)buttonClick:(UIButton *)sender {
    [self beyongOfArray:nil];
}

- (void)addButton {
    UIButton *button = [[UIButton alloc] init];
    button.frame = CGRectMake(50, 50, 50, 50);
    [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    button.backgroundColor = [UIColor redColor];
    [self.view addSubview:button];
}

#pragma mark - support
- (UIImage *)createImageWithColor:(UIColor *)color {
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}


- (void)mapperTest {
    
    NSMutableArray *array1 = [NSMutableArray array];
    
    for (int i = 0 ; i < 5000 ; i++) {
        NSString *maperString = [NSString stringWithFormat:@"映射%d",i];
        NSDictionary *dict = @{ @"name" : @"张飞",
                                @"mapperStr" : maperString,
                                @"mapperNumber" : @(i),
                                };
        
        [array1 addObject:dict];
    }
    
    NSArray *patients = [Patient modelsFromJSONObjectArray:array1];
    NSArray *dicts = [patients JSONObjectsFromModelArray];
    NSLog(@"dicts = %@",dicts);
}

#pragma mark - 
- (void)test1 {
    Person *person = [[Person alloc] init];
    [person eat1];
    [person sleep1];
}

- (void)test2 {
    Person *person = [[Person alloc] init];
    [[person eat2] sleep2];
    [[person sleep2] eat2];
}

- (void)test3 {
    Person *person = [[Person alloc] init];
    person.eat3();
    person.sleep3();
}

- (void)test4 {
    Person *person = [[Person alloc] init];
    person.eat4().sleep4();
    person.sleep4().eat4();
}

- (void)test5 {
    Person *person = [[Person alloc] init];
    person.eat5(@"milk").sleep5(5);
    person.sleep5(6).eat5(@"coffice");
}

/// Data source
- (NSArray<Patient *> *)patients {
    if (!_patients) {
        
        NSMutableArray *patients = [NSMutableArray array];
        for (int i = 0; i < 10; i++) {
            NSMutableArray *array1 = [NSMutableArray array];
            Patient *patient = [[Patient alloc] init];
            if (i % 2 == 0) {
                patient.birthday = [NSDate date];
            } else {
                patient.birthday = [NSDate dateWithTimeIntervalSinceNow:-24 * 60 * 60];
            }
            
            patient.name = [NSString stringWithFormat:@"%@%d",@"张飞",i];
            patient.age = arc4random() % 100;
            patient.recordDate = [[NSDate date] dateByAddingTimeInterval:60 * 60 * -i];
            patient.idCard = @(30.5);
            patient.height = 100.89;
            patient.test = @{@"11" : @"22"};
            patient.aclass = [Patient class];
            patient.hostipalID = @(1);
            patient.patientID = i;
            patient.image = [self createImageWithColor:[UIColor redColor]];
            patient.data = nil;
            Drug *drug = [[Drug alloc] init];
            drug.drugID = @(1);
            drug.name = @"感冒药";
            drug.price = @(10.5);
            
            patient.dict = @{
                             @"patient" : @"guanyu",
                             @"arry1" : [Drug JSONObjectsFromModelArray:array1],               };
            
            patient.dictM = [NSMutableDictionary dictionaryWithObject:patient.dict forKey:@"key"];
            
            patient.array = @[@"没有包含模型的数组",@"Not contain model in array"];
            patient.arrayM = [NSMutableArray arrayWithArray:patient.array];
            
            
            Drug *drug1 = [[Drug alloc] init];
            drug1.price = @(20.5);
            
            if (i % 2 == 0) {
                drug1.name = @"后悔药";
                drug1.drugID = @(2);
            } else {
                drug1.name = @"消炎药";
                drug1.drugID = @(3);
            }
            
            DrugType *type = [[DrugType alloc] init];
            type.type = @"处方药";
            type.doctorType = @"主治";
            type.drugTypeId = @(1);
            
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
            bed.bedID = @(1);
            
            patient.bed = bed;
            
            RemoteApplicationCreateRequest *request = [[RemoteApplicationCreateRequest alloc] init];
            request.applicationId = @"1";
            
            PatientImage *patientImage = [[PatientImage alloc] init];
            patientImage.imageId = @"1";
            patientImage.imageName = @"影像1";
            PatientImage *patientImage1 = [[PatientImage alloc] init];
            patientImage1.imageId = @"2";
            patientImage1.imageName = @"影像2";
            
            request.patientImages = @[patientImage,patientImage1];
            
            patient.request = request;
            [patients addObject:patient];
        }
        _patients = patients;
    }
    return _patients;
}

@end
