//
//  GSAmazonService.h
//  Shell
//
//  Created by Endika Gutiérrez Salas on 1/15/14.
//  Copyright (c) 2014 Endika Gutiérrez Salas. All rights reserved.
//

#import <TenzingCore/TenzingCore-RESTService.h>

@interface GSAmazonEC2Service : TZRESTService

@property (nonatomic, copy) NSString *accessKeyId;
@property (nonatomic, copy) NSString *accessSecret;

@end
