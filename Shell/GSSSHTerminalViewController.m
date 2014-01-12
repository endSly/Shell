//
//  GSSSHTerminalViewController.m
//  Shell
//
//  Created by Endika Gutiérrez Salas on 1/12/14.
//  Copyright (c) 2014 Endika Gutiérrez Salas. All rights reserved.
//

#import "GSSSHTerminalViewController.h"

#import "GSConnection.h"

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

- (void)connect
{
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

        [session authenticateByPassword:self.connection.password];

        session.channel.ptyTerminalType = NMSSHChannelPtyTerminalXterm;

        session.channel.requestPty = YES;
        self.session = session;
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *error = nil;

            [session.channel startShell:&error];

            if (error) {
                [self closeWithError:error.description];
                return;
            }
        });
    }];
}

- (void)closeWithError:(NSString *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:error
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        [alert show];

        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self.navigationController popViewControllerAnimated:YES];
        });
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
