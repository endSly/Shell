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

@dynamic access_token;
@dynamic expires_in;
@dynamic refresh_token;
@dynamic session_nonce;
@dynamic token_type;
@dynamic user_id;
@dynamic name;

@synthesize service = _service;

- (GSHerokuService *)service
{
    if (!_service) {
        _service = [GSHerokuService service];
        _service.authKey = self.access_token;
    }
    return _service;
}

@end
