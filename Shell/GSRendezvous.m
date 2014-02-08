//
//  SSLSocket.m
//  Shell
//
//  Created by Endika Gutiérrez Salas on 1/10/14.
//  Copyright (c) 2014 Endika Gutiérrez Salas. All rights reserved.
//

#import "GSRendezvous.h"

#include <sys/socket.h>
#include <resolv.h>
#include <netdb.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <string.h>

#include <openssl/bio.h>
#include <openssl/ssl.h>
#include <openssl/err.h>
#include <openssl/pem.h>

static int createSocket(const char *hostname, int port) {
    int sockfd;
    char *tmp_ptr = NULL;
    struct hostent *host;
    struct sockaddr_in dest_addr;

    host = gethostbyname(hostname);
    if (!host)
        return -1;

    // Create TCP socket
    sockfd = socket(AF_INET, SOCK_STREAM, 0);

    dest_addr.sin_family=AF_INET;
    dest_addr.sin_port=htons(port);
    dest_addr.sin_addr.s_addr = *(unsigned int*)(host->h_addr);

    memset(&(dest_addr.sin_zero), '\0', 8);

    tmp_ptr = inet_ntoa(dest_addr.sin_addr);

    // Try to make the host connect here
    if (connect(sockfd, (struct sockaddr *) &dest_addr, sizeof(struct sockaddr)) == -1)
        return -2;

    return sockfd;
}

@implementation GSRendezvous {
    SSL_CTX *_ctx;
    SSL *_ssl;
    int _socketfd;

    dispatch_queue_t _readQueue;
}

@synthesize isConnected = _isConnected;

+ (void)initialize
{
    // These function calls initialize openssl for correct work.
    SSL_library_init();
    OpenSSL_add_all_algorithms();
    ERR_load_BIO_strings();
    ERR_load_crypto_strings();
    SSL_load_error_strings();
}

- (BOOL)start {

    const char *dest_url = [self.URL.host cStringUsingEncoding:NSUTF8StringEncoding];

    //Try to create a new SSL context over TLSv1
    SSL_CTX *ctx = SSL_CTX_new(TLSv1_client_method());
    if (!ctx)
        return NO;

    _ctx = ctx;

    // Disabling SSLv2 will leave v3 and TSLv1 for negotiation
    SSL_CTX_set_options(ctx, SSL_OP_NO_SSLv2);

    // Create new SSL connection state object
    SSL * ssl = _ssl = SSL_new(ctx);

    //Make the underlying TCP socket connection
    int socketfd = _socketfd = createSocket(dest_url, (int) self.URL.port.intValue);
    if(socketfd <= 0)
        return NO;

    // Attach the SSL session to the socket descriptor
    BIO *sbio = BIO_new_socket(socketfd, BIO_NOCLOSE);

    SSL_set_bio(ssl, sbio, sbio);

    // Try to SSL-connect here, returns 1 for success
    if (SSL_connect(ssl) != 1)
        return NO;

    const char *secret = [self.URL.lastPathComponent cStringUsingEncoding:NSUTF8StringEncoding];
    SSL_write(ssl, secret, (int) strlen(secret));
    SSL_write(ssl, "\n", (int) strlen("\n"));
    char newline[16];
    SSL_read(ssl, newline, 16);

    _readQueue = dispatch_queue_create("rendezvousDispatchQueue", 0);

    dispatch_async(_readQueue, ^{
        int read_blocked_on_write, read_blocked;
        do {
            read_blocked_on_write = 0;
            read_blocked = 0;

            char buffer[512];
            int r=SSL_read(ssl,buffer,512);

            switch(SSL_get_error(ssl,r)){
                case SSL_ERROR_NONE: {
                    NSData *data = [NSData dataWithBytes:buffer length:r];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.delegate rendezvous:self didReadData:data];
                    });
                    break;
                }
                case SSL_ERROR_ZERO_RETURN:
                    /* End of data */
                    //if(!shutdown_wait)
                    //    SSL_shutdown(ssl);
                    //goto end;
                    break;
                case SSL_ERROR_WANT_READ:
                    read_blocked=1;
                    break;

                    /* We get a WANT_WRITE if we're
                     trying to rehandshake and we block on
                     a write during that rehandshake.

                     We need to wait on the socket to be
                     writeable but reinitiate the read
                     when it is */
                case SSL_ERROR_WANT_WRITE:
                    read_blocked_on_write=1;
                    break;
                default:
                    ;
                    // Ctrl-d
                    //exit(-8);//("SSL read problem");
            }

            /* We need a check for read_blocked here because
             SSL_pending() doesn't work properly during the
             handshake. This check prevents a busy-wait
             loop around SSL_read() */
        } while (1);
        NSLog(@"read-end");
    });

    _isConnected = YES;
    
    return YES;
}

- (void)dealloc
{
    if (_ssl)
        SSL_free(_ssl);
    if (_socketfd > 0)
        close(_socketfd);
    if (_ctx)
        SSL_CTX_free(_ctx);
}

- (BOOL)writeData:(NSData *)data
{
    return SSL_write(_ssl, data.bytes, (int) data.length) > 0;
}

- (NSData *)readData
{
    NSMutableData *data = [NSMutableData data];

    char buffer[512];
    int count = SSL_read(_ssl, buffer, 512);

    if (count <= 0)
        return nil;

    [data appendBytes:buffer length:count];

    return data;
}

- (void)getPeerCertificate
{
    X509_NAME       *certname = NULL;
    //Get the remote certificate into the X509 structure
    X509 *cert = SSL_get_peer_certificate(_ssl);
    if (cert == NULL)
        printf("Error: Could not get a certificate from: .\n");
    else
        printf("Retrieved the server's certificate from: .\n");

    //extract various certificate information

    certname = X509_NAME_new();
    certname = X509_get_subject_name(cert);

    // display the cert subject here
    
    /*
     BIO_printf(outbio, "Displaying the certificate subject data:\n");
     X509_NAME_print_ex(outbio, certname, 0, 0);
     BIO_printf(outbio, "\n");
     */
}

@end
