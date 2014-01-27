//
//  GSHerokuOAuth.h
//  Shell
//
//  Created by Endika Gutiérrez Salas on 1/27/14.
//  Copyright (c) 2014 Endika Gutiérrez Salas. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kGSHerokuClientId;
extern NSString * const kGSHerokuClientSecret;
extern NSString * const kGSHerokuCallbackHost;

@interface GSHerokuOAuth : NSObject

+ (instancetype)sharedInstance;

- (void)loginWithAuthToken:(NSString *)code callback:(void(^)(NSDictionary *))callback;

- (void)refreshAccessToken:(NSString *)refreshToken callback:(void(^)(NSDictionary *))callback;

@end
