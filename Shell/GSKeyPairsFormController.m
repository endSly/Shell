//
//  GSKeyPairsFormController.m
//  Shell
//
//  Created by Endika Gutiérrez Salas on 1/25/14.
//  Copyright (c) 2014 Endika Gutiérrez Salas. All rights reserved.
//

#import "GSKeyPairsFormController.h"

#import <OpenSSL/rsa.h>
#import <OpenSSL/pem.h>

@implementation GSKeyPairsFormController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)generateKeyPair
{
    RSA *rsa = RSA_new();
    BIGNUM *e = BN_new();
    BN_set_word(e, 65537);
    int ret;

    ret = RSA_generate_key_ex(rsa, 2048, e, NULL);

    FILE *publicFile = fopen("/Users/endika/Desktop/rsa.pub", "w+");
    ret = PEM_write_RSAPublicKey(publicFile, rsa);
    fclose(publicFile);

    FILE *privateFile = fopen("/Users/endika/Desktop/rsa.pem", "w+");
    unsigned char *password = NULL;

    if (password != NULL) {
        ret = PEM_write_RSAPrivateKey(privateFile, rsa, EVP_aes_256_cbc(), password, (int) strlen((char *) password), NULL, NULL);//use given password
    } else {
        ret = PEM_write_RSAPrivateKey(privateFile, rsa, NULL, NULL, 0, NULL, NULL);//use default passwd callback
    }

    fclose(privateFile);

    BN_free(e);
    
    RSA_free(rsa);
}


@end
