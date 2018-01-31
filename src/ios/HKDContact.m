//
//  YHContact.m
//  cutePuppyPics
//
//  Created by lv zaiyi on 2017/5/23.
//
//

#import "HKDContact.h"
#import <ContactsUI/ContactsUI.h>

@interface HKDContact()<CNContactPickerDelegate>

@property (nonatomic, copy) NSString *callbackId;
@property (nonatomic, strong) NSMutableDictionary *contactDictionary;

@end

@implementation HKDContact

- (void)getContact:(CDVInvokedUrlCommand *)command{
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
                    NSLog(@"您未开启通讯录权限,请前往设置中心开启 ");
                    //                    [self getContactInfo:NO];
                }else
                {
                    NSLog(@"用户给权限了 ");//用户给权限了
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
    //    NSLog(@"givenName: %@, familyName: %@", contact.givenName, contact.familyName);
    NSString *name = [NSString stringWithFormat:@"%@%@",contact.familyName,contact.givenName];
    if (![contactProperty.value isKindOfClass:[CNPhoneNumber class]]) {
        //        [[HNPublicTool shareInstance] showHudErrorMessage:@"请选择11位手机号"];
        return;
    }
    CNPhoneNumber *phoneNumber = contactProperty.value;
    NSString * Str = phoneNumber.stringValue;
    NSCharacterSet *setToRemove = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
    NSString *phoneStr = [[Str componentsSeparatedByCharactersInSet:setToRemove]componentsJoinedByString:@""];
    //    if (phoneStr.length != 11) {
    //        [[HNPublicTool shareInstance] showHudErrorMessage:@"请选择11位手机号"];
    //        return;
    //    }
    //    NSLog(@"-=-=%@",phoneStr);
    [self.contactDictionary setObject:name forKey:@"name"];
    [self.contactDictionary setObject:phoneStr forKey:@"phone"];
    [self.contactDictionary setObject:@"1" forKey:@"grant"];
    
    [self getContactInfo:YES];
    
    //    self.phoneTextView.text = phoneStr;
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
@end

