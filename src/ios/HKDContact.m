//
//  YHContact.m
//  cutePuppyPics
//
//  Created by lv zaiyi on 2017/5/23.
//
//

#import "HKDContact.h"
#import <Contacts/Contacts.h>

@interface HKDContact()<CNContactPickerDelegate>

@property (nonatomic, copy) NSString *callbackId;
@property (nonatomic, strong) NSMutableArray *array;

@end

@implementation HKDContact

- (void)getContact:(CDVInvokedUrlCommand *)command{
    NSDictionary *dict  = [command argumentAtIndex:0 withDefault:nil];
    if (dict) {
        _callbackId = [command.callbackId copy];
        self.array = [NSMutableArray array];
        // 判断是否授权
        //让用户给权限,没有的话会被拒的各位
        CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
        if (status == CNAuthorizationStatusNotDetermined) {
            CNContactStore *store = [[CNContactStore alloc] init];
            [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
                if (error) {
                    NSLog(@"weishouquan ");
                }else
                {
                    NSLog(@"chenggong ");//用户给权限了
                    CNContactPickerViewController * picker = [CNContactPickerViewController new];
                    picker.delegate = self;
                    picker.displayedPropertyKeys = @[CNContactPhoneNumbersKey];//只显示手机号
                    [self presentViewController: picker  animated:YES completion:nil];
                }
            }];
        }
        
        if (status == CNAuthorizationStatusAuthorized) {//有权限时
            CNContactPickerViewController * picker = [CNContactPickerViewController new];
            picker.delegate = self;
            picker.displayedPropertyKeys = @[CNContactPhoneNumbersKey];
            [self presentViewController: picker  animated:YES completion:nil];
        }
        else{
            @"您未开启通讯录权限,请前往设置中心开启";
        }
        
    }
}

- (void)getContactInfo:(BOOL)isGranted{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if(isGranted){
        NSData *data = [NSJSONSerialization dataWithJSONObject:self.array options:NSJSONWritingPrettyPrinted error:nil];
        NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        [dict setObject:str forKey:@"contacts"];
        [dict setObject:@(self.array.count) forKey:@"totalCount"];
    }else{
        [dict setObject:@(-1) forKey:@"totalCount"];
    }
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dict];
    [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
}
@end
