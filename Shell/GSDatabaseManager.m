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

#import "GSProgressHUD.h"

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

- (NSURL *)databaseURL
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *applicationSupportURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    [fileManager createDirectoryAtURL:applicationSupportURL withIntermediateDirectories:NO attributes:nil error:nil];
    return [applicationSupportURL URLByAppendingPathComponent:@"db.sqlcipher"];
}

- (void)initializeDatabase
{
    [CoreDataManager sharedManager].modelName = @"DataModel";

    // Set in memory store while not key
    [[CoreDataManager sharedManager] useInMemoryStore];

    [self getPassword:^(NSString *password) {
        if (password) {
            @try {
                
                NSPersistentStoreCoordinator *persistentStore = [EncryptedStore makeStoreWithDatabaseURL:[self databaseURL]
                                                                                      managedObjectModel:[CoreDataManager sharedManager].managedObjectModel
                                                                                                passcode:password];
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

- (void)resetDatabase:(void(^)(BOOL))callback
{
    UIAlertView *resetDatabaseAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Reset database", @"Alert title")
                                                                 message:NSLocalizedString(@"All information stored will be removed. Type \"delete\" for confirm reset.", @"Remove database confirmation message")
                                                                delegate:self
                                                       cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                                       otherButtonTitles:NSLocalizedString(@"Reset", @"Reset database button"), nil];

    resetDatabaseAlert.alertViewStyle = UIAlertViewStylePlainTextInput;

    resetDatabaseAlert.tapBlock = ^(UIAlertView *alertView, NSInteger index) {
        if (index == 1) {
            NSString *confirmText = [alertView textFieldAtIndex:0].text;
            if ([confirmText isEqualToString:NSLocalizedString(@"delete", @"Remove database confirmation text (see message!!)")]) {
                NSFileManager *fileManager = [NSFileManager defaultManager];
                NSError *error;
                BOOL result = [fileManager removeItemAtURL:[self databaseURL] error:&error];

                // Reset config
                [GSDatabaseManager buildDatabaseConfig];

                callback (result);

            } else {
                [self resetDatabase:callback];
            }
        } else {
            callback(NO);
        }
    };

    [resetDatabaseAlert show];
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
                                                               otherButtonTitles:NSLocalizedString(@"Reset database", @"Reset database button"), NSLocalizedString(@"Login as Guest", @"Temporal storage button"), nil];
            wrongPasswordAlert.tapBlock = ^(UIAlertView *alertView, NSInteger index) {
                if (index == 0) { //  Try again
                    [self getPassword:callback];

                } else if (index == 1) { // Reset Database
                    [self resetDatabase:^(BOOL reset) {
                        [self getPassword:callback];

                        if (reset) {
                            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC));
                            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                [GSProgressHUD showSuccess:NSLocalizedString(@"Database reset", @"HUD message")];
                            });
                        }
                    }];

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

+ (void)buildDatabaseConfig
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *password = [[NSProcessInfo processInfo] globallyUniqueString];
    [userDefaults setBool:NO forKey:kGSUseCustomPassword];
    [userDefaults setObject:password forKey:kGSDatabasePassword];
}

+ (instancetype)manager
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

    // Initialize if password not set
    if (![userDefaults stringForKey:kGSDatabasePassword]) {
        [self buildDatabaseConfig];
    }

    static GSDatabaseManager *manager = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ manager = [[self alloc] init]; });

    return manager;
}

@end
