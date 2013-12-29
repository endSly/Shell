//
//  GSDetailViewController.m
//  Shell
//
//  Created by Endika Gutiérrez Salas on 12/26/13.
//  Copyright (c) 2013 Endika Gutiérrez Salas. All rights reserved.
//

#import "GSTerminalViewController.h"

#import "GSConnection.h"

#import "GSTerminalView.h"

@interface GSTerminalViewController ()

@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (strong, nonatomic) NMSSHSession *session;

@end

@implementation GSTerminalViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.terminalView.delegate = self;

    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){

        NMSSHSession *session = [NMSSHSession connectToHost:@"fry.ekaidepd.com" port:22 withUsername:@"root"];
        session.delegate = self;
        session.channel.delegate = self;

        session.channel.environmentVariables = @{@"TERM": @"xterm"};

        [session authenticateByPassword:@"dC3RbSF4s"];

        NSError *error = nil;

        session.channel.ptyTerminalType = NMSSHChannelPtyTerminalXterm;

        session.channel.requestPty = YES;

        [session.channel startShell:&error];
        NSLog(@"Error %@", error);

        //[session disconnect];

        self.session = session;
    });

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)adjustSizeToTerminalView
{
    NSUInteger cols, rows;
    [self.terminalView getScreenCols:&cols rows:&rows];

    rows = MAX(rows, 24);

    [self.terminalView setCols:cols rows:rows];
    [self.session.channel requestSizeRows:rows cols:cols];
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

#pragma mark - Terminal view delegate

- (void)terminalViewDidLoad:(GSTerminalView *)terminalView
{
    [self adjustSizeToTerminalView];
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
