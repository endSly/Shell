//
//  GSHerokuAccount.m
//  Shell
//
//  Created by Endika Gutiérrez Salas on 1/13/14.
//  Copyright (c) 2014 Endika Gutiérrez Salas. All rights reserved.
//

#import "GSHerokuAccount.h"

#import <ObjectiveRecord/ObjectiveRecord.h>

#import "GSHerokuService.h"

#import "GSHerokuOAuth.h"

@implementation GSHerokuAccount

@dynamic accessToken;
@dynamic expiresAt;
@dynamic refreshToken;
@dynamic sessionNonce;
@dynamic tokenType;
@dynamic userId;

@dynamic email;
@dynamic name;

@synthesize service = _service;

- (GSHerokuService *)service
{
    if (!_service) {
        _service = [GSHerokuService service];
        _service.authKey = self.accessToken;
    }
    return _service;
}

- (void)setExpiresIn:(NSNumber *)expiresIn
{
    self.expiresAt = [NSDate dateWithTimeIntervalSinceNow:expiresIn.integerValue];
}

- (NSNumber *)expiresIn
{
    return @([self.expiresAt timeIntervalSinceNow]);
}

- (BOOL)isExpired
{
    return [self.expiresAt timeIntervalSinceNow] < 0;
}

- (void)refreshAccessToken:(void(^)(void))callback
{
    [[GSHerokuOAuth sharedInstance] refreshAccessToken:self.refreshToken callback:^(NSDictionary *info) {
        [self update:info];
        [self save];
        callback();
    }];
}

- (void)getApps:(void(^)(NSArray *, NSError *))callback
{
    void (^loadApps)(void) = ^{
        [self.service getApps:nil callback:^(NSArray *apps, NSURLResponse *resp, NSError *err) {
            callback(apps, err);
        }];
    };

    if (self.isExpired) {
        [self refreshAccessToken:loadApps];
    } else {
        loadApps();
    }
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
}

@end
