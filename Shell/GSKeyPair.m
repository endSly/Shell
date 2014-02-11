//
//  GSKeyPair.m
//  Shell
//
//  Created by Endika Gutiérrez Salas on 1/9/14.
//  Copyright (c) 2014 Endika Gutiérrez Salas. All rights reserved.
//

#import "GSKeyPair.h"

#import <ObjectiveRecord/ObjectiveRecord.h>

#import <OpenSSL/rsa.h>
#import <OpenSSL/pem.h>

int pemPasswordCallback(char *buf, int size, int rwflag, void *userdata) {
    return 0;
}

@implementation GSKeyPair

@dynamic name;
@dynamic publicKeyPath;
@dynamic privateKeyPath;
@dynamic hasPassword;

+ (instancetype)createKeyPair:(NSString *)name size:(NSInteger)size password:(NSString *)password
{
    NSString *keysPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    keysPath = [keysPath stringByAppendingString:@"/key_pairs"];

    if (![[NSFileManager defaultManager] fileExistsAtPath:keysPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:keysPath withIntermediateDirectories:NO attributes:nil error:nil];
    }

    NSString *keyIdentifier = [[NSProcessInfo processInfo] globallyUniqueString];
    NSString *publicKeyPath = [NSString stringWithFormat:@"%@/%@.pub", keysPath, keyIdentifier];
    NSString *privateKeyPath = [NSString stringWithFormat:@"%@/%@.pem", keysPath, keyIdentifier];

    RSA *rsa = RSA_new();
    BIGNUM *e = BN_new();
    BN_set_word(e, 65537);
    int ret;

    ret = RSA_generate_key_ex(rsa, (int) size, e, NULL);

    FILE *publicFile = fopen([publicKeyPath cStringUsingEncoding:NSUTF8StringEncoding], "w+");
    ret = PEM_write_RSAPublicKey(publicFile, rsa);
    fclose(publicFile);

    FILE *privateFile = fopen([privateKeyPath cStringUsingEncoding:NSUTF8StringEncoding], "w+");

    if (password != NULL) {
        //use given password
        const char *passwordData = [password cStringUsingEncoding:NSUTF8StringEncoding];
        ret = PEM_write_RSAPrivateKey(privateFile,
                                      rsa,
                                      EVP_aes_256_cbc(),
                                      (unsigned char *) passwordData,
                                      (int) strlen(passwordData),
                                      NULL,
                                      NULL);
    } else {
        //use default passwd callback
        ret = PEM_write_RSAPrivateKey(privateFile, rsa, NULL, NULL, 0, NULL, NULL);
    }

    fclose(privateFile);

    BN_free(e);

    RSA_free(rsa);

    return [self create:@{@"name": name,
                          @"publicKeyPath": publicKeyPath,
                          @"privateKeyPath": privateKeyPath,
                          @"hasPassword": @(password != nil)}];
}

+ (instancetype)createKeyPairWithRawPrivateKey:(NSString *)privateKey
{
    NSString *keysPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    keysPath = [keysPath stringByAppendingString:@"/key_pairs"];

    if (![[NSFileManager defaultManager] fileExistsAtPath:keysPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:keysPath withIntermediateDirectories:NO attributes:nil error:nil];
    }

    NSString *keyIdentifier = [[NSProcessInfo processInfo] globallyUniqueString];
    NSString *publicKeyPath = [NSString stringWithFormat:@"%@/%@.pub", keysPath, keyIdentifier];
    NSString *privateKeyPath = [NSString stringWithFormat:@"%@/%@.pem", keysPath, keyIdentifier];

    NSError *error;
    [privateKey writeToFile:privateKeyPath
                 atomically:YES
                   encoding:NSUTF8StringEncoding
                      error:&error];

    FILE *privateKeyFile = fopen([privateKeyPath cStringUsingEncoding:NSUTF8StringEncoding], "r");

    RSA *rsa = PEM_read_RSAPrivateKey(privateKeyFile, NULL, pemPasswordCallback, "User data");

    if (!rsa)
        return nil;

    FILE *publicFile = fopen([publicKeyPath cStringUsingEncoding:NSUTF8StringEncoding], "w");
    int ret = PEM_write_RSAPublicKey(publicFile, rsa);
    fclose(publicFile);

    if (!ret)
        return nil;

    return [self create:@{@"publicKeyPath": publicKeyPath,
                          @"privateKeyPath": privateKeyPath,
                          @"hasPassword": @NO}];
}

@end
