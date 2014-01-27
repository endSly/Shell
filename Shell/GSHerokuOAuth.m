//
//  GSHerokuOAuth.m
//  Shell
//
//  Created by Endika Gutiérrez Salas on 1/27/14.
//  Copyright (c) 2014 Endika Gutiérrez Salas. All rights reserved.
//

#import "GSHerokuOAuth.h"

#import <TenzingCore/TenzingCore.h>

NSString * const kGSHerokuClientId = @"c07e2cb2-9ec6-4330-a846-d89e1398eaa4";
NSString * const kGSHerokuClientSecret = @"53b4e5ae-6bd2-4fdd-9d36-e30398324424";
NSString * const kGSHerokuCallbackHost = @"heroku-oauth-cb.local";

@implementation GSHerokuOAuth

+ (instancetype)sharedInstance
{
    static GSHerokuOAuth *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[GSHerokuOAuth alloc] init];
    });
    return sharedInstance;
}

- (void)loginWithAuthToken:(NSString *)code callback:(void(^)(NSDictionary *))callback
{
    NSDictionary *params = @{@"grant_type": @"authorization_code",
                             @"code": code,
                             @"client_secret": kGSHerokuClientSecret};

    [self OAuthCallWithParams:params callback:callback];
}

- (void)refreshAccessToken:(NSString *)refreshToken callback:(void(^)(NSDictionary *))callback
{
    NSDictionary *params = @{@"grant_type": @"refresh_token",
                             @"refresh_token": refreshToken,
                             @"client_secret": kGSHerokuClientSecret};

    [self OAuthCallWithParams:params callback:callback];
}

- (void)OAuthCallWithParams:(NSDictionary *)params callback:(void(^)(NSDictionary *))callback
{
    NSMutableURLRequest *oauthRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://id.heroku.com/oauth/token"]];
    oauthRequest.HTTPMethod = @"POST";
    oauthRequest.HTTPBody = [[params asURLQueryString] dataUsingEncoding:NSUTF8StringEncoding];

    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:oauthRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSDictionary *accountDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];

        callback(accountDict);
    }];
}

@end
