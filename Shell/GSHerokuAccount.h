//
//  GSHerokuAccount.h
//  Shell
//
//  Created by Endika Gutiérrez Salas on 1/13/14.
//  Copyright (c) 2014 Endika Gutiérrez Salas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class GSHerokuService;

@interface GSHerokuAccount : NSManagedObject

@property (nonatomic, strong) NSString * accessToken;
@property (nonatomic, strong) NSDate * expiresAt;
@property (nonatomic, strong) NSString * refreshToken;
@property (nonatomic, strong) NSString * sessionNonce;
@property (nonatomic, strong) NSString * tokenType;
@property (nonatomic, strong) NSString * userId;

@property (nonatomic, strong) NSString * email;
@property (nonatomic, strong) NSString * name;

@property (nonatomic) NSNumber *expiresIn;
@property (nonatomic, readonly) BOOL isExpired;

@property (nonatomic, readonly) GSHerokuService *service;

- (void)refreshAccessToken:(void(^)(void))callback;

@end
