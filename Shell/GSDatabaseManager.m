//
//  GSPasswordManager.m
//  Shell
//
//  Created by Endika Gutiérrez Salas on 2/3/14.
//  Copyright (c) 2014 Endika Gutiérrez Salas. All rights reserved.
//

#import "GSDatabaseManager.h"

#import <UIAlertView+Blocks/UIAlertView+Blocks.h>

#import <ObjectiveRecord/ObjectiveRecord.h>
#import "EncryptedStore.h"

#import "NSData+AES256.h"

NSString * const kGSUserHasLogged = @"kGSUserHasLogged";

static NSString * const kGSUseCustomPassword = @"kGSUseCustomPassword";
static NSString * const kGSDatabasePassword = @"kGSDatabasePassword";

@implementation GSDatabaseManager

@synthesize isGuest = _isGuest;

- (id)init
{
    self = [super init];

    if (self) {
        _isGuest = YES;
    }

    return self;
}

- (void)initializeDatabase
{
    [CoreDataManager sharedManager].modelName = @"DataModel";

    // Set in memory store while not key
    [[CoreDataManager sharedManager] useInMemoryStore];

    [self getPassword:^(NSString *password) {
        if (password) {
            @try {
                NSPersistentStoreCoordinator *persistentStore = [EncryptedStore makeStore:[CoreDataManager sharedManager].managedObjectModel :password];
                [CoreDataManager sharedManager].persistentStoreCoordinator = persistentStore;
                _isGuest = NO;
            }
            @catch (NSException *exception) {
                NSLog(@"%@", exception);
            }

        }
        [[NSNotificationCenter defaultCenter] postNotificationName:kGSUserHasLogged object:self];
    }];
}

- (void)askForPassword:(void(^)(NSString *))callback
{
    UIAlertView *accessAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Password", @"Password alert title")
                                                          message:NSLocalizedString(@"Type your password for allow access to stored data", @"Password alert message")
                                                         delegate:self
                                                cancelButtonTitle:NSLocalizedString(@"Guest", @"Guest button")
                                                otherButtonTitles:NSLocalizedString(@"Unlock", @"Unlock button"), nil];

    accessAlert.alertViewStyle = UIAlertViewStyleSecureTextInput;
    accessAlert.tapBlock = ^(UIAlertView *alertView, NSInteger index) {
        if (index == 1) { // Unlock
            callback([alertView textFieldAtIndex:0].text);

        } else { // Guest
            callback(nil);
        }
    };
    [accessAlert show];
}

- (BOOL)useUserPassword
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kGSUseCustomPassword];
}

- (NSString *)getPasswordWithKey:(NSString *)key
{
    NSString *password = [[NSUserDefaults standardUserDefaults] stringForKey:kGSDatabasePassword];
    
    if (![self useUserPassword])
        return password;

    NSData *passwordData = [[NSData alloc] initWithBase64EncodedString:password options:0];
    return [[NSString alloc] initWithData:[passwordData AES256DecryptWithKey:key] encoding:NSUTF8StringEncoding];
}

- (void)getPassword:(void(^)(NSString *))callback
{
    if (!self.useUserPassword) {
        NSString *password = [[NSUserDefaults standardUserDefaults] stringForKey:kGSDatabasePassword];
        callback(password);
        return;
    }

    [self askForPassword:^(NSString *key) {
        if (!key) {
            callback(nil);
            return;
        }

        NSString *plainPassword = [self getPasswordWithKey:key];
        if (plainPassword) {
            callback(plainPassword);

        } else {
            // Wrong password
            UIAlertView *wrongPasswordAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Wrong password", @"Wrong password alert title")
                                                                  message:NSLocalizedString(@"Wrong password inserted. Try again, reset database or use  temporal storage", @"Wrong password alert message")
                                                                 delegate:self
                                                        cancelButtonTitle:NSLocalizedString(@"Try again", @"Try again button")
                                                        otherButtonTitles:/*NSLocalizedString(@"Reset database", @"Reset database button"),*/ NSLocalizedString(@"Login as Guest", @"Temporal storage button"), nil];
            wrongPasswordAlert.tapBlock = ^(UIAlertView *alertView, NSInteger index) {
                if (index == 0) { //  Try again
                    [self getPassword:callback];
/*
                } else if (index == 1) { // Reset Database
*/
                } else { // Temp storage
                    callback(nil);
                }
            };
            [wrongPasswordAlert show];
        }
    }];
}

- (BOOL)updateCurrentKey:(NSString *)currentKey newKey:(NSString *)key
{
    NSString *password = [self getPasswordWithKey:currentKey];

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

    if (key.length) {
        NSData *passwordEncryptedData = [[password dataUsingEncoding:NSUTF8StringEncoding] AES256EncryptWithKey:key];
        password = [passwordEncryptedData base64EncodedStringWithOptions:0];
    }
    if (!password) {
        return NO;
    }
    [userDefaults setObject:password forKey:kGSDatabasePassword];
    [userDefaults setBool:(BOOL) (key.length > 0) forKey:kGSUseCustomPassword];

    [userDefaults synchronize];

    return YES;
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

    static GSDatabaseManager *manager = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });

    return manager;
}

@end
