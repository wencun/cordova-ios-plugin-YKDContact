//
//  YHContact.m
//  cutePuppyPics
//
//  Created by lv zaiyi on 2017/5/23.
//
//

#import "HKDContact.h"
#import <Contacts/Contacts.h>

@interface HKDContact()

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
                        //                        NSLog(@"-------------------------------------------------------");
                        NSString *givenName = contact.givenName;
                        NSString *familyName = contact.familyName;
                        NSString *name = [NSString stringWithFormat:@"%@%@", familyName,givenName];
                        //                        NSLog(@"givenName=%@, familyName=%@", givenName, familyName);
                        [tempDict setObject:name forKey:@"contactsName"];
                        
                        NSArray *phoneNumbers = contact.phoneNumbers;
                        NSString *contactPhone = @"";
                        for (CNLabeledValue *labelValue in phoneNumbers) {
                            //                            NSString *label = labelValue.label;
                            CNPhoneNumber *phoneNumber = labelValue.value;
                            contactPhone = phoneNumber.stringValue;
                            break;
                            //                            NSLog(@"label=%@, phone=%@", label, phoneNumber.stringValue);
                        }
                        [tempDict setObject:contactPhone forKey:@"contactsTel"];
                        [self.array addObject:tempDict];
                    }];
                    
                    [self getContactInfo:YES];
                    
                } else {
                    [self getContactInfo:NO];
                    NSLog(@"授权失败, error=%@", error);
                }
            }];
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
