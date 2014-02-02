//
//  GSKeyPairsFormController.m
//  Shell
//
//  Created by Endika Gutiérrez Salas on 1/25/14.
//  Copyright (c) 2014 Endika Gutiérrez Salas. All rights reserved.
//

#import "GSKeyPairsFormController.h"

#import "UIBarButtonItem+IonIcons.h"

#import <OpenSSL/rsa.h>
#import <OpenSSL/pem.h>

@implementation GSKeyPairsFormController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithIcon:icon_ios7_plus_outline target:self action:@selector(addKeyPairAction:)];
}

- (void)addKeyPairAction:(id)sender
{
    [self performSegueWithIdentifier:@"GSAddKeyPairSegue" sender:self];
}

@end
