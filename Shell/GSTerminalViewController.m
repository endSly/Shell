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

@interface GSTerminalViewController ()

@property (strong, nonatomic) UIPopoverController *masterPopoverController;

@end

@implementation GSTerminalViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.terminalView.delegate = self;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];

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
    [self hideNavigationBar:YES];
    self.terminalView.scrollView.contentInsetTop = 20;
}

- (void)keyboardWillHide:(NSNotification *)note
{
    [self showNavigationBar:YES];
    self.terminalView.scrollView.contentInsetTop = 64;
    self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Thin" size:22],
                                                                    NSForegroundColorAttributeName: [UIColor whiteColor]};
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

}

- (void)terminalViewDidResize:(GSTerminalView *)terminalView
{

}

- (void)terminalView:(GSTerminalView *)terminalView didWrite:(NSString *)data
{

}

@end
