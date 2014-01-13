//
//  GSHerokuAccount.h
//  Shell
//
//  Created by Endika Gutiérrez Salas on 1/13/14.
//  Copyright (c) 2014 Endika Gutiérrez Salas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface GSHerokuAccount : NSManagedObject

@property (nonatomic, retain) NSString * accessToken;
@property (nonatomic, retain) NSString * expiresIn;
@property (nonatomic, retain) NSString * refreshToken;
@property (nonatomic, retain) NSString * sessionNonce;
@property (nonatomic, retain) NSString * tokenType;
@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) NSString * name;

@end
