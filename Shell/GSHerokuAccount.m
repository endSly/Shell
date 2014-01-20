//
//  GSHerokuAccount.m
//  Shell
//
//  Created by Endika Gutiérrez Salas on 1/13/14.
//  Copyright (c) 2014 Endika Gutiérrez Salas. All rights reserved.
//

#import "GSHerokuAccount.h"

#import "GSHerokuService.h"

@implementation GSHerokuAccount

@dynamic accessToken;
@dynamic expiresIn;
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

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
}

@end
