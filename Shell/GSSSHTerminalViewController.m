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

- (NSString *)askPassword
{
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    __block NSString *password = nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *passwordAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"User password", @"Alert title")
                                                                message:NSLocalizedString(@"You need a password to connect to server", @"")
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
        NMSSHSession *session = [NMSSHSession connectToHost:self.host
                                                       port:[self.port integerValue]
                                               withUsername:self.username];

        if (!session.rawSession) {
            [self closeWithError:@"Unable to connect to host."];
            return;
        }

        session.delegate = self;
        session.channel.delegate = self;

        session.channel.environmentVariables = @{@"TERM": @"xterm"};

        BOOL authenticated = NO;

        // Try to authenticate with Key Pair
        if (self.keyPair) {
            BOOL success = NO;
            BOOL hasPassword = self.keyPair.hasPassword.boolValue;
            do {
                NSString *password = nil;
                if (hasPassword) {
                    password = [self askKeyPairPassword];
                    if (!password)
                        break; // Cancel pressed

                }
                success = [session authenticateByPublicKey:self.keyPair.publicKeyPath
                                                privateKey:self.keyPair.privateKeyPath
                                               andPassword:password];
            } while (!success && hasPassword);

            authenticated = success;
        }

        // Try to authenticate with stored password
        if (!authenticated && self.password) {
            authenticated = [session authenticateByPassword:self.password];
        }

        // Try to authenticate with interactive
        if (!authenticated) {
            do {
                NSString *password = [self askKeyPairPassword];
                if (!password)
                    break; // Cancel pressed

                authenticated = [session authenticateByPassword:password];
            } while (!authenticated);
        }

        // Authentication Error
        if (!authenticated) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self closeWithError:NSLocalizedString(@"Authentication failed", @"Auth failed HUD message")];
            });
            return;
        }

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
    [GSProgressHUD dismiss];

    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [GSProgressHUD showError:error];
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

#pragma mark - SSH Channel delegate

- (void)channel:(NMSSHChannel *)channel didReadData:(NSString *)message
{
    [self.terminalView terminalWrite:message];
}

- (void)channel:(NMSSHChannel *)channel didReadError:(NSString *)error
{

}

@end
