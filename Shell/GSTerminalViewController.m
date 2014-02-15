//
//  GSDetailViewController.m
//  Shell
//
//  Created by Endika Gutiérrez Salas on 12/26/13.
//  Copyright (c) 2013 Endika Gutiérrez Salas. All rights reserved.
//

#import "GSTerminalViewController.h"

#import <FrameAccessor/FrameAccessor.h>
#import <NJKScrollFullScreen/UIViewController+NJKFullScreenSupport.h>

#import "UIBarButtonItem+IonIcons.h"

#import "GSConnection.h"
#import "GSApplication.h"
#import "GSDyno.h"

#import "GSTerminalView.h"
#import "GSProgressHUD.h"

#import "GSHerokuService.h"

#import "GSSettingsManager.h"

@interface GSTerminalViewController ()

@property (strong, nonatomic) UIPopoverController *masterPopoverController;

@end

@implementation GSTerminalViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];

    self.terminalView.delegate = self;

    UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(backGestureRecognized:)];
    recognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:recognizer];

    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self.terminalView action:@selector(resignFirstResponder)];
    recognizer.direction = UISwipeGestureRecognizerDirectionDown;
    [self.view addGestureRecognizer:recognizer];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithIcon:icon_eject target:self action:@selector(disconnect)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)backGestureRecognized:(UISwipeGestureRecognizer *)recognizer
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)keyboardWillShow:(NSNotification *)note
{
    if (!self.isConnected)
        return;

    [self hideNavigationBar:YES];

    [self.terminalView performSelector:@selector(showAccessoryToolbar) withObject:nil afterDelay:0];

    // Scroll to bottom
    //CGPoint bottomOffset = CGPointMake(0, self.terminalView.scrollView.contentSize.height - self.terminalView.scrollView.bounds.size.height);
    //[self.terminalView.scrollView setContentOffset:bottomOffset animated:YES];

    [UIView animateWithDuration:0.1 animations:^{
        self.terminalView.scrollView.contentInsetTop = 20;
    }];
}

- (void)keyboardWillHide:(NSNotification *)note
{
    if (!self.isConnected)
        return;
    
    [self showNavigationBar:YES];

    [self.terminalView performSelector:@selector(hideAccesoryToolbar) withObject:nil afterDelay:0];
    
    [UIView animateWithDuration:0.1 animations:^{
        self.terminalView.scrollView.contentInsetTop = 64;
    }];

    self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Thin" size:22],
                                                                    NSForegroundColorAttributeName: [UIColor whiteColor]};
}

- (void)viewDidAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)isConnected
{
    return NO;
}

/*
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
*/

#pragma mark - Terminal view delegate

- (void)terminalViewDidLoad:(GSTerminalView *)terminalView
{
    self.terminalView.fontSize = [GSSettingsManager manager].fontSize ?: 10;
}

- (void)terminalViewDidResize:(GSTerminalView *)terminalView
{

}

- (void)terminalView:(GSTerminalView *)terminalView didWrite:(NSString *)data
{

}

@end
