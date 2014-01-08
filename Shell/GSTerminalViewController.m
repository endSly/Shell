//
//  GSDetailViewController.m
//  Shell
//
//  Created by Endika Gutiérrez Salas on 12/26/13.
//  Copyright (c) 2013 Endika Gutiérrez Salas. All rights reserved.
//

#import "GSTerminalViewController.h"

#import <FrameAccessor/FrameAccessor.h>

#import "GSConnection.h"

#import "GSTerminalView.h"

@interface GSTerminalViewController ()

@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (strong, nonatomic) NMSSHSession *session;

@end

@implementation GSTerminalViewController {
    NSOperationQueue *_queue;

    BOOL hidden;
    CGFloat startContentOffset;
    CGFloat lastContentOffset;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _queue = [[NSOperationQueue mainQueue] init];

    self.terminalView.delegate = self;

    self.title = [self.connection objectForKey:@"name"];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];

    [self.view addGestureRecognizer:[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGestureRecognized:)]];
}

- (void)connect
{
    [_queue addOperationWithBlock:^{
        NMSSHSession *session = [NMSSHSession connectToHost:[self.connection objectForKey:@"host"]
                                                       port:[[self.connection objectForKey:@"port"] integerValue]
                                               withUsername:[self.connection objectForKey:@"username"]];

        if (!session.rawSession) {
            [self closeWithError:@"Unable to connect to host."];
            return;
        }

        session.delegate = self;
        session.channel.delegate = self;

        session.channel.environmentVariables = @{@"TERM": @"xterm"};

        [session authenticateByPassword:[self.connection objectForKey:@"password"]];

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

- (void)viewDidDisappear:(BOOL)animated
{
    [_queue addOperationWithBlock:^{
        [self.session disconnect];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)adjustSizeToTerminalView
{
    NSUInteger cols, rows;
    [self.terminalView getScreenCols:&cols rows:&rows];

    rows = MAX(rows, 20);

    [self.terminalView setCols:cols rows:rows];
    [self.session.channel requestSizeWidth:cols height:rows];
}

- (void)swipeGestureRecognized:(UISwipeGestureRecognizer *)recognizer
{
    switch (recognizer.direction) {
        case UISwipeGestureRecognizerDirectionDown:
            [self.terminalView resignFirstResponder];
            break;
        case UISwipeGestureRecognizerDirectionRight:
            [self.navigationController popViewControllerAnimated:YES];
            break;
        default:
            break;
    }
}

- (void)keyboardWillShow:(NSNotification *)note
{
    self.terminalView.scrollView.contentInsetTop = 64.0f;

    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)keyboardWillHide:(NSNotification *)note
{
    self.terminalView.scrollView.contentInsetTop = 0.f;

    [self.navigationController setNavigationBarHidden:NO animated:YES];
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
