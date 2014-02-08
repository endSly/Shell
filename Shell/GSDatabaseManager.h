//
//  GSPasswordManager.h
//  Shell
//
//  Created by Endika Gutiérrez Salas on 2/3/14.
//  Copyright (c) 2014 Endika Gutiérrez Salas. All rights reserved.
//

@import Foundation;

extern NSString * const kGSUserHasLogged;

@interface GSDatabaseManager : NSObject

@property (nonatomic, readonly) BOOL isGuest;
@property (nonatomic, readonly) BOOL useUserPassword;

+ (instancetype)manager;

- (void)initializeDatabase;
- (BOOL)updateCurrentKey:(NSString *)curentKey newKey:(NSString *)key;


@end
