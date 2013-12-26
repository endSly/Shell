//
//  GSConnection.h
//  Shell
//
//  Created by Endika Gutiérrez Salas on 12/26/13.
//  Copyright (c) 2013 Endika Gutiérrez Salas. All rights reserved.
//

#import <NanoStore/NanoStore.h>

@interface GSConnection : NSFNanoObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *host;
@property (nonatomic, strong) NSNumber *port;
@property (nonatomic, strong) NSString *user;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSDate *lastConnected;

@end
