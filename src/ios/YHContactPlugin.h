//
//  HKDContact
//  cutePuppyPics
//
//  Created by lv zaiyi on 2017/5/23.
//
//

#import <Cordova/CDV.h>

@interface YHContactPlugin : CDVPlugin

- (void)selectContactInfo:(CDVInvokedUrlCommand *)command;

- (void)getAllContactInfo:(CDVInvokedUrlCommand *)command;

@end
