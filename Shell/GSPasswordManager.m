//
//  GSPasswordManager.m
//  Shell
//
//  Created by Endika Gutiérrez Salas on 2/3/14.
//  Copyright (c) 2014 Endika Gutiérrez Salas. All rights reserved.
//

#import "GSPasswordManager.h"

#import <UIAlertView+Blocks/UIAlertView+Blocks.h>

#import "NSData+AES256.h"

static NSString * const kGSUseCustomPassword = @"kGSUseCustomPassword";
static NSString * const kGSDatabasePassword = @"kGSDatabasePassword";

@implementation GSPasswordManager

- (void)askForPassword:(void(^)(NSString *))callback
{
    UIAlertView *accessAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Password", @"Password alert title")
                                                          message:NSLocalizedString(@"Type your password for allow access to stored data", @"Password alert message")
                                                         delegate:self
                                                cancelButtonTitle:NSLocalizedString(@"Unlock", @"Unlock button")
                                                otherButtonTitles:NSLocalizedString(@"Temp storage", @"Use temp storage button"), nil];

    accessAlert.alertViewStyle = UIAlertViewStyleSecureTextInput;
    accessAlert.tapBlock = ^(UIAlertView *alertView, NSInteger index) {
        if (index == 0) {
            callback([alertView textFieldAtIndex:0].text);

        } else {
            callback(nil);
        }
    };
    [accessAlert show];
}

- (BOOL)useUserPassword
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kGSUseCustomPassword];
}

- (void)getPassword:(void(^)(NSString *))callback
{
    NSString *password = [[NSUserDefaults standardUserDefaults] stringForKey:kGSDatabasePassword];

    if (!self.useUserPassword) {
        callback(password);
        return;
    }

    [self askForPassword:^(NSString *key) {
        if (!key) {
            callback(nil);
            return;
        }

        NSData *passwordData = [[NSData alloc] initWithBase64EncodedString:password options:0];
        NSString *plainPassword = [[NSString alloc] initWithData:[passwordData AES256DecryptWithKey:key] encoding:NSUTF8StringEncoding];
        if (plainPassword) {
            callback(plainPassword);

        } else {
            // Wrong password
            UIAlertView *wrongPasswordAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Wrong password", @"Wrong password alert title")
                                                                  message:NSLocalizedString(@"Wrong password inserted. Try again, reset database or use  temporal storage", @"Wrong password alert message")
                                                                 delegate:self
                                                        cancelButtonTitle:NSLocalizedString(@"Try again", @"Try again button")
                                                        otherButtonTitles:NSLocalizedString(@"Reset database", @"Reset database button"), NSLocalizedString(@"Temporal storage", @"Temporal storage button"), nil];
            wrongPasswordAlert.tapBlock = ^(UIAlertView *alertView, NSInteger index) {
                if (index == 0) { //  Try again
                    [self getPassword:callback];

                } else if (index == 1) { // Reset Database

                } else { // Temp storage
                    callback(nil);
                }
            };
            [wrongPasswordAlert show];
        }
    }];
}

- (void)updatePasswordKey:(NSString *)key callback:(void(^)(void))callback
{
    [self getPassword:^(NSString *password) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

        if (key.length) {
            NSData *passwordEncryptedData = [[password dataUsingEncoding:NSUTF8StringEncoding] AES256EncryptWithKey:key];
            password = [passwordEncryptedData base64EncodedStringWithOptions:0];

        }
        [userDefaults setObject:password forKey:kGSDatabasePassword];
        [userDefaults setBool:(BOOL) (key.length > 0) forKey:kGSUseCustomPassword];
        
        [userDefaults synchronize];

        callback();
    }];
}

+ (instancetype)manager
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

    // Initialize if password not set
    if (![userDefaults stringForKey:kGSDatabasePassword]) {
        NSString *password = [[NSProcessInfo processInfo] globallyUniqueString];
        [userDefaults setBool:NO forKey:kGSUseCustomPassword];
        [userDefaults setObject:password forKey:kGSDatabasePassword];
    }

    static GSPasswordManager *manager = nil;
    if (!manager) {
        manager = [[GSPasswordManager alloc] init];
    }
    return manager;
}

@end