//
//  GSAddConnectionTableController.m
//  Shell
//
//  Created by Endika Gutiérrez Salas on 1/26/14.
//  Copyright (c) 2014 Endika Gutiérrez Salas. All rights reserved.
//

#import "GSAddConnectionTableController.h"

#import "UIBarButtonItem+IonIcons.h"

@implementation GSAddConnectionTableController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithIcon:icon_ios7_close_outline target:self action:@selector(cancelAction:)];
}

- (void)cancelAction:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
