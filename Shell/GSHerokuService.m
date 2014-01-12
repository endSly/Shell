//
//  GSHerokuService.m
//  Shell
//
//  Created by Endika Gutiérrez Salas on 1/10/14.
//  Copyright (c) 2014 Endika Gutiérrez Salas. All rights reserved.
//

#import "GSHerokuService.h"

#import "GSApplication.h"
#import "GSDyno.h"

@implementation GSHerokuService

+ (void)initialize
{
    [self get:@"/apps" class:GSApplication.class as:@selector(getApps:callback:)];
    [self get:@"/apps/:id/dynos" class:GSDyno.class as:@selector(getDynos:callback:)];
    [self post:@"/apps/:id/dynos" class:GSDyno.class as:@selector(postDyno:callback:)];
}

+ (instancetype)service
{
    GSHerokuService *service = [[self alloc] init];
    service.baseURL = [NSURL URLWithString:@"https://api.heroku.com"];
    service.delegate = service;
    return service;
}

- (void)RESTService:(TZRESTService *)service beforeSendRequest:(NSMutableURLRequest *__autoreleasing *)request
{
    NSString *authString = [@":" stringByAppendingString:self.authKey];
    NSString *authorizationCode = [[authString dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];

    [(* request) setValue:@"application/vnd.heroku+json; version=3" forHTTPHeaderField:@"Accept"];
    [(* request) setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [(* request) setValue:authorizationCode forHTTPHeaderField:@"Authorization"];

}

@end
