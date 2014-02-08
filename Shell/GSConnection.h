//
//  GSConnection.h
//  Shell
//
//  Created by Endika Gutiérrez Salas on 12/26/13.
//  Copyright (c) 2013 Endika Gutiérrez Salas. All rights reserved.
//

@import CoreData;

@class GSKeyPair;

@interface GSConnection : NSManagedObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *host;
@property (nonatomic, copy) NSNumber *port;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, copy) NSNumber *savePassword;
@property (nonatomic, copy) NSDate *lastConnected;

@property (nonatomic, strong) GSKeyPair *keyPair;

@end
