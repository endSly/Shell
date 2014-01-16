//
//  GSAWSCredentials.m
//  Shell
//
//  Created by Endika Gutiérrez Salas on 1/16/14.
//  Copyright (c) 2014 Endika Gutiérrez Salas. All rights reserved.
//

#import "GSAWSCredentials.h"


@implementation GSAWSCredentials

@dynamic accessKey;
@dynamic accessSecret;

@synthesize client = _client;

- (AmazonEC2Client *)client
{
    if (!_client) {
        _client = [[AmazonEC2Client alloc] initWithAccessKey:self.accessKey withSecretKey:self.accessSecret];
    }
    return _client;
}

@end
