//
//  GSAmazonService.m
//  Shell
//
//  Created by Endika Gutiérrez Salas on 1/15/14.
//  Copyright (c) 2014 Endika Gutiérrez Salas. All rights reserved.
//

#import "GSAmazonEC2Service.h"

#import <CommonCrypto/CommonCrypto.h>

@interface GSAmazonEC2Service (DynamicMethods)

- (void)sendAction:(NSDictionary *)params callback:(TZRESTCallback)callback;

@end

@implementation GSAmazonEC2Service

+ (void)initialize
{
    [self get:@"/" class:Nil as:@selector(sendAction:callback:)];
}

- (id)init
{
    self = [super init];
    if (self) {
        self.baseURL = [NSURL URLWithString:@"https://ec2.amazonaws.com"];
    }
    return self;
}

- (NSString *)generateSecretForMethod:(NSString *)method
                                 host:(NSString *)host
                                query:(NSString *)query
{
    NSMutableString *stringSign = [NSMutableString string];
    [stringSign appendFormat:@"%@\n", method];
    [stringSign appendFormat:@"%@\n", host];
    [stringSign appendString:@"/\n"];
    [stringSign appendString:query];

    NSData *data = [stringSign dataUsingEncoding:NSUTF8StringEncoding];

    NSData *secret = [self.accessSecret dataUsingEncoding:NSUTF8StringEncoding];

    NSMutableData *hash = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];

    CCHmac(kCCHmacAlgSHA256, secret.bytes, secret.length, data.bytes, data.length, hash.mutableBytes);

    return [hash base64EncodedStringWithOptions:0];
}

@end
