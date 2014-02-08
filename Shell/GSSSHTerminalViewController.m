//
//  GSSSHTerminalViewController.m
//  Shell
//
//  Created by Endika Gutiérrez Salas on 1/12/14.
//  Copyright (c) 2014 Endika Gutiérrez Salas. All rights reserved.
//

#import "GSSSHTerminalViewController.h"

#import "GSConnection.h"
#import "GSKeyPair.h"

#import "GSProgressHUD.h"

#import <UIAlertView+Blocks/UIAlertView+Blocks.h>

@interface GSSSHTerminalViewController ()

@property (strong, nonatomic) NMSSHSession *session;

@end

@implementation GSSSHTerminalViewController {
    NSOperationQueue *_queue;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _queue = [[NSOperationQueue mainQueue] init];
    self.title = self.connection.name;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [_queue addOperationWithBlock:^{
        [self.session disconnect];
    }];
}

- (NSString *)askKeyPairPassword
{
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    __block NSString *password = nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *passwordAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SSH Key password", @"Alert title")
                                                                message:NSLocalizedString(@"You need a password to unlock the SSH key", @"")
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                                      otherButtonTitles:NSLocalizedString(@"Ok", @"Ok"), nil];

        passwordAlert.alertViewStyle = UIAlertViewStyleSecureTextInput;

        passwordAlert.tapBlock = ^(UIAlertView *alertView, NSInteger index) {
            if (index == 1) { // Cancel button
                password = [alertView textFieldAtIndex:0].text;
            }
            dispatch_semaphore_signal(sema);
        };

        [passwordAlert show];
    });

    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);

    return password;
}

- (void)connect
{
    [GSProgressHUD show:NSLocalizedString(@"Connecting...", @"Connecting hud")];

    [_queue addOperationWithBlock:^{
        NMSSHSession *session = [NMSSHSession connectToHost:self.connection.host
                                                       port:[self.connection.port integerValue]
                                               withUsername:self.connection.username];

        if (!session.rawSession) {
            [self closeWithError:@"Unable to connect to host."];
            return;
        }

        session.delegate = self;
        session.channel.delegate = self;

        session.channel.environmentVariables = @{@"TERM": @"xterm"};

        GSKeyPair *keyPair = self.connection.keyPair;
        if (keyPair) {
            BOOL success;
            do {
                NSString *password = nil;
                if (keyPair.hasPassword.boolValue) {
                    password = [self askKeyPairPassword];
                    if (!password) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [GSProgressHUD dismiss];
                            [self.navigationController popViewControllerAnimated:YES];
                        });
                        return;
                    }
                }
                success = [session authenticateByPublicKey:keyPair.publicKeyPath
                                                privateKey:keyPair.privateKeyPath
                                               andPassword:password];
            } while (!success);

        }
        NSLog(@"-- %@", self.connection.keyPair);
        NSLog(@"++ %@", self.connection.password);

        [session authenticateByPassword:self.connection.password];

        session.channel.ptyTerminalType = NMSSHChannelPtyTerminalXterm;

        session.channel.requestPty = YES;
        self.session = session;
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *error = nil;

            [session.channel startShell:&error];

            [GSProgressHUD dismiss];

            if (error) {
                [self closeWithError:error.description];
                return;
            }
        });
    }];
}

- (void)closeWithError:(NSString *)error
{
    [GSProgressHUD showError:@"Connection error"];

    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.navigationController popViewControllerAnimated:YES];
    });
}

- (void)disconnect
{
    [_queue addOperationWithBlock:^{
        [self.session disconnect];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
        });
    }];
}

- (BOOL)isConnected
{
    return self.session.connected;
}

- (void)adjustSizeToTerminalView
{
    NSUInteger cols, rows;
    [self.terminalView getScreenCols:&cols rows:&rows];

    rows = MAX(rows, 20);

    [self.terminalView setCols:cols rows:rows];
    [self.session.channel requestSizeWidth:cols height:rows];
}

#pragma mark - Terminal view delegate

- (void)terminalViewDidLoad:(GSTerminalView *)terminalView
{
    [self adjustSizeToTerminalView];

    [self connect];
}

- (void)terminalViewDidResize:(GSTerminalView *)terminalView
{
    [self adjustSizeToTerminalView];
}

- (void)terminalView:(GSTerminalView *)terminalView didWrite:(NSString *)data
{
    NSError *error;
    [self.session.channel write:data error:&error];
}

#pragma mark - SSH Session delegate

- (void)session:(NMSSHSession *)session didDisconnectWithError:(NSError *)error
{

}

- (NSString *)session:(NMSSHSession *)session keyboardInteractiveRequest:(NSString *)request
{
    return @"";
}

#pragma mark - SSH Channel delegate

- (void)channel:(NMSSHChannel *)channel didReadData:(NSString *)message
{
    [self.terminalView terminalWrite:message];
}

- (void)channel:(NMSSHChannel *)channel didReadError:(NSString *)error
{

}

@end
