//
//  GSPasswordManager.h
//  Shell
//
//  Created by Endika Gutiérrez Salas on 2/3/14.
//  Copyright (c) 2014 Endika Gutiérrez Salas. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GSPasswordManager : NSObject

+ (instancetype)manager;

- (BOOL)useUserPassword;

- (void)getPassword:(void(^)(NSString *))callback;

- (BOOL)updateCurrentKey:(NSString *)curentKey newKey:(NSString *)key;


@end
