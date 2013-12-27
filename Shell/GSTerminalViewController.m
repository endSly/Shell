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

    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        NMSSHSession *session = [NMSSHSession connectToHost:@"" port:22 withUsername:@"root"];
        session.delegate = self;
        self.session = session;

        [session authenticateByPassword:@""];

        //[session authenticateByKeyboardInteractive];

        NSError *error = nil;
        //NSString *response = [session.channel execute:@"ls -l /var/www/" error:&error];
        //NSLog(@"List of my sites: %@", response);

        session.channel.ptyTerminalType = NMSSHChannelPtyTerminalXterm;

        session.channel.delegate = self;
        session.channel.requestPty = YES;

        BOOL shell = [session.channel startShell:&error];
        NSLog(@"Error %@", error);


        [session.channel write:@"stty columns 50\n" error:&error];
        [session.channel write:@"stty rows 30\n" error:&error];
        //[session.channel write:@"ls -l /var/www/ --color=yes\n" error:&error];


        //[session.channel write:@"nano\n" error:&error];
        //NSLog(@"Error %@", error);
        
        //BOOL success = [session.channel uploadFile:@"~/index.html" to:@"/var/www/9muses.se/"];
        
        //[session disconnect];
    });

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    NSUInteger cols, rows;
    [terminalView getScreenCols:&cols rows:&rows];

    [terminalView adjustSizeToScreen];
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
