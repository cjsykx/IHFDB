# IHFDB
基于IHFDB上的一层封装，通过直接函数调用而不用关心sql代码的实现。
使用方法：以模型Patient为例：

用户主要是调用NSObject+IHFDB.h中的方法，例如

// -------------------------创建表 -------------------插入方法中已经包含创建表，所以不用太担心

[Patient createTable] ; 就可以为Patient创建一张表名为Patient的表

当然也可以使用Block回调，下面的增删改查的回调跟这个类似
[Patient createTableDidCompleteBlock:^(BOOL success) {
// 创建成功后的回调;
}]

如果想为Patient的关系类如例子中的Drugs建表，需要在Patient.m中声明（增删改查都是同理）
+(NSDictionary *)relationshipDictForClassInArray{
    return @{ @"drugs" : [Drug class],};
}

如果你不要创建跟类名一样的比如Patient,你可以通过传入Table name
+(BOOL)createTableWithName:(NSString *)tableName inDataBase:(FMDatabase *)db CompleteBlock:(IHFDBCompleteBlock)completion;  

// table name 为你想要的名称， 建议不要修改，修改后增删改查都要调用类似这样的方法（增删改查都提供）
// db 默认是空的 ， 但是你可以在如下

[_queue inDatabase:^(FMDatabase *db) {
    // 在已经开始的操作下调用
}];

// 增删改查与此同理


// ------------------------------ 插入 --------------------------------------
[Patient save]; 执行插入， 也有上述的回调，如果要插入子项，也就是 
+(NSDictionary *)relationshipDictForClassInArray{
return @{ @"drugs" : [Drug class],};
}

如果你创建的表名是你创建的table name ， 也要
-(BOOL)saveWithTableName:(NSString *)tableName;

// 查，更新,改 与此同理
但值得注意的是

// 建议在病人多的情况下，调用如下

[Patient saveModelArray:muArray completeBlock:^(BOOL success) {
    NSLog(@"因为这是使用事务,增加插入速度");
}];

// ------------------------------ 查询 --------------------------------------

// 同上，有block的回调，db和tableName

跟Core Data 一样使用 predicate ，但是predicate 是自定义的IHFPredicate
IHFPredicate *predicate = [[IHFPredicate alloc] initWithFormat:@"name = %@",@"张飞"];
[patient updateWithPredicate:predicate completeBlock:^(BOOL success) {
}];

如果你要找这个Patient表中的所有数据，你可以[Patient selectAll];
当然在CODE中，我们会将你要找的类和关联的类全部转成对象。

// ------------------------------ 删除 --------------------------------------

// 删除与上述的都类似，唯一注意的 cascade ：级联
+(void)deleteWithPredicate:(IHFPredicate *)predicate isCascade:(BOOL)cascade completeBlock:(IHFDBCompleteBlock)completion{

}

默认cascade yes . 也就是级联， 就是说当你删除了这个类后，会将他所关联的类都进行删除。当然你也可以设置成只删除这个类，不影响他的关联的类。

// ------------------------------ 更新 --------------------------------------


跟上述的类似，也有级联关系
-(void)updateWithPredicate:(IHFPredicate *)predicate isCascade:(BOOL)cascade completeBlock:(IHFDBCompleteBlock)completion;


