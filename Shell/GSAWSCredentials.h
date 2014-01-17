//
//  GSAWSCredentials.h
//  Shell
//
//  Created by Endika Gutiérrez Salas on 1/16/14.
//  Copyright (c) 2014 Endika Gutiérrez Salas. All rights reserved.
//

@import CoreData;
@import Foundation;

#import <AWSEC2/AWSEC2.h>

@interface GSAWSCredentials : NSManagedObject

@property (nonatomic, retain) NSString * accountName;
@property (nonatomic, retain) NSString * accessKey;
@property (nonatomic, retain) NSString * accessSecret;

@property (nonatomic, readonly) AmazonEC2Client *client;

@end
