//
//  YHContact.m
//  cutePuppyPics
//
//  Created by lv zaiyi on 2017/5/23.
//
//

#import "YHContactPlugin.h"
#import <ContactsUI/ContactsUI.h>

@interface YHContactPlugin()<CNContactPickerDelegate>

@property (nonatomic, copy) NSString *callbackId;
@property (nonatomic, strong) NSMutableDictionary *contactDictionary;
@property (nonatomic, strong) NSMutableArray *array;

@end

@implementation YHContactPlugin

#pragma mark 选择联系人姓名和电话号码
- (void)selectContactInfo:(CDVInvokedUrlCommand *)command{
    NSDictionary *dict  = [command argumentAtIndex:0 withDefault:nil];
    if (dict) {
        _callbackId = [command.callbackId copy];
        self.contactDictionary = [NSMutableDictionary dictionary];
        // 判断是否授权
        //让用户给权限,没有的话会被拒的各位
        CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
        if (status == CNAuthorizationStatusNotDetermined) {
            CNContactStore *store = [[CNContactStore alloc] init];
            [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
                if (error) {
                    //                    NSLog(@"您未开启通讯录权限,请前往设置中心开启 ");
                    //                    [self getContactInfo:NO];
                } else {
                    //用户给权限了
                    CNContactPickerViewController * picker = [CNContactPickerViewController new];
                    picker.delegate = self;
                    picker.displayedPropertyKeys = @[CNContactPhoneNumbersKey];//只显示手机号
                    [self.viewController presentViewController: picker  animated:YES completion:nil];
                }
            }];
        } else if (status == CNAuthorizationStatusAuthorized) {//有权限时
            CNContactPickerViewController * picker = [CNContactPickerViewController new];
            picker.delegate = self;
            picker.displayedPropertyKeys = @[CNContactPhoneNumbersKey];
            [self.viewController presentViewController: picker  animated:YES completion:nil];
        } else if(status == CNAuthorizationStatusDenied) {
            [self getContactInfo:NO];
        }
        
    }
}

#pragma mark - 点击某个联系人的某个属性（property）时触发并返回该联系人属性（contactProperty）。
//只实现该方法时，可以进入到联系人详情页面（如果predicateForSelectionOfProperty属性没被设置或符合筛选条件，如不符合会触发默认操作，即打电话，发邮件等）。
- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContactProperty:(CNContactProperty *)contactProperty {
    CNContact *contact = contactProperty.contact;
    NSString *name = [NSString stringWithFormat:@"%@%@",contact.familyName,contact.givenName];
    if (![contactProperty.value isKindOfClass:[CNPhoneNumber class]]) {
        return;
    }
    CNPhoneNumber *phoneNumber = contactProperty.value;
    NSString * Str = phoneNumber.stringValue;
    NSCharacterSet *setToRemove = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
    NSString *phoneStr = [[Str componentsSeparatedByCharactersInSet:setToRemove]componentsJoinedByString:@""];
    [self.contactDictionary setObject:name forKey:@"name"];
    [self.contactDictionary setObject:phoneStr forKey:@"phone"];
    [self.contactDictionary setObject:@"1" forKey:@"grant"];
    
    [self getContactInfo:YES];
}

- (void)getContactInfo:(BOOL)isGranted{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if(isGranted){
        dict = _contactDictionary;
    }else{
        [self.contactDictionary setObject:@"" forKey:@"name"];
        [self.contactDictionary setObject:@"" forKey:@"phone"];
        [self.contactDictionary setObject:@"0" forKey:@"grant"];
        dict = _contactDictionary;
    }
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dict];
    [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
}

#pragma mark 获取通讯录记录
- (void)getAllContactInfo:(CDVInvokedUrlCommand *)command{
    NSDictionary *dict  = [command argumentAtIndex:0 withDefault:nil];
    if (dict) {
        _callbackId = [command.callbackId copy];
        self.array = [NSMutableArray array];
        // 判断是否授权
        CNAuthorizationStatus authorizationStatus = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
        if (authorizationStatus == CNAuthorizationStatusNotDetermined) {
            CNContactStore *contactStore = [[CNContactStore alloc] init];
            [contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
                if (granted) {
                    // 获取指定的字段,并不是要获取所有字段，需要指定具体的字段
                    NSArray *keysToFetch = @[CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey];
                    CNContactFetchRequest *fetchRequest = [[CNContactFetchRequest alloc] initWithKeysToFetch:keysToFetch];
                    CNContactStore *contactStore = [[CNContactStore alloc] init];
                    
                    [contactStore enumerateContactsWithFetchRequest:fetchRequest error:nil usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
                        NSMutableDictionary *tempDict = [NSMutableDictionary dictionary];
                        NSString *givenName = contact.givenName;
                        NSString *familyName = contact.familyName;
                        NSString *name = [NSString stringWithFormat:@"%@%@", familyName,givenName];
                        [tempDict setObject:name forKey:@"contactsName"];
                        
                        NSArray *phoneNumbers = contact.phoneNumbers;
                        NSString *contactPhone = @"";
                        for (CNLabeledValue *labelValue in phoneNumbers) {
                            CNPhoneNumber *phoneNumber = labelValue.value;
                            contactPhone = phoneNumber.stringValue;
                            break;
                        }
                        [tempDict setObject:contactPhone forKey:@"contactsTel"];
                        [self.array addObject:tempDict];
                    }];
                    
                    [self sendPluginResult:YES];
                    
                } else {
                    [self sendPluginResult:NO];
                    //                    NSLog(@"授权失败, error=%@", error);
                }
            }];
        }else if (authorizationStatus == CNAuthorizationStatusAuthorized){
            CNContactStore *contactStore = [[CNContactStore alloc] init];
            [contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
                if (granted) {
                    // 获取指定的字段,并不是要获取所有字段，需要指定具体的字段
                    NSArray *keysToFetch = @[CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey];
                    CNContactFetchRequest *fetchRequest = [[CNContactFetchRequest alloc] initWithKeysToFetch:keysToFetch];
                    CNContactStore *contactStore = [[CNContactStore alloc] init];
                    
                    [contactStore enumerateContactsWithFetchRequest:fetchRequest error:nil usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
                        NSMutableDictionary *tempDict = [NSMutableDictionary dictionary];
                        NSString *givenName = contact.givenName;
                        NSString *familyName = contact.familyName;
                        NSString *name = [NSString stringWithFormat:@"%@%@", familyName,givenName];
                        [tempDict setObject:name forKey:@"contactsName"];
                        
                        NSArray *phoneNumbers = contact.phoneNumbers;
                        NSString *contactPhone = @"";
                        for (CNLabeledValue *labelValue in phoneNumbers) {
                            CNPhoneNumber *phoneNumber = labelValue.value;
                            contactPhone = phoneNumber.stringValue;
                            break;
                        }
                        [tempDict setObject:contactPhone forKey:@"contactsTel"];
                        [self.array addObject:tempDict];
                    }];
                    
                    [self sendPluginResult:YES];
                    
                } else {
                    [self sendPluginResult:NO];
                    //                    NSLog(@"授权失败, error=%@", error);
                }
            }];
        } else if(authorizationStatus == CNAuthorizationStatusDenied){
            [self sendPluginResult:NO];
        }
    }
}

- (void)sendPluginResult:(BOOL)isGranted{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if(isGranted){
        NSString *str = [self toJSONString:self.array];
        [dict setObject:str forKey:@"contacts"];
        [dict setObject:@(self.array.count) forKey:@"totalCount"];
    }else{
        [dict setObject:@(-1) forKey:@"totalCount"];
    }
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dict];
    [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
}

- (NSString *)toJSONString:(NSObject *)obj {
    NSData *data = [NSJSONSerialization dataWithJSONObject:obj options:NSJSONReadingMutableLeaves | NSJSONReadingAllowFragments error:nil];
    if (data == nil) {
        return @"";
    }
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return string;
}

@end
