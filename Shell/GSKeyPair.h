//
//  GSKeyPair.h
//  Shell
//
//  Created by Endika Gutiérrez Salas on 1/9/14.
//  Copyright (c) 2014 Endika Gutiérrez Salas. All rights reserved.
//

@import CoreData;

@interface GSKeyPair : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * publicKeyPath;
@property (nonatomic, retain) NSString * privateKeyPath;
@property (nonatomic, retain) NSNumber * hasPassword;

/**
 *  @param size Key size in bits 1024, 2048 or 4096
 *  @param passsword Key for encrypt key pair
 */
+ (instancetype)createKeyPair:(NSString *)name size:(NSInteger)size password:(NSString *)password;

@end
