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

@property (nonatomic, strong) NSString * access_token;
@property (nonatomic, strong) NSString * expires_in;
@property (nonatomic, strong) NSString * refresh_token;
@property (nonatomic, strong) NSString * session_nonce;
@property (nonatomic, strong) NSString * token_type;
@property (nonatomic, strong) NSString * user_id;
@property (nonatomic, strong) NSString * name;

@property (nonatomic, readonly) GSHerokuService *service;

@end
