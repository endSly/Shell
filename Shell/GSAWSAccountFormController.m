//
//  GSAWSAccountFormController.m
//  Shell
//
//  Created by Endika Gutiérrez Salas on 1/16/14.
//  Copyright (c) 2014 Endika Gutiérrez Salas. All rights reserved.
//

#import "GSAWSAccountFormController.h"

#import <ObjectiveRecord/ObjectiveRecord.h>

#import "GSAWSCredentials.h"

@interface GSAWSAccountFormController ()

@end

@implementation GSAWSAccountFormController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    QRootElement *root = [[QRootElement alloc] initWithJSONFile:@"aws-account-form"];

    QAppearance *defaultAppearance = [[QAppearance alloc] init];
    defaultAppearance.labelFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0];
    root.appearance = defaultAppearance;

    self = [super initWithRoot:root];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)saveAction:(id)sender
{
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    [self.root fetchValueUsingBindingsIntoObject:data];

    GSAWSCredentials *credentials = [GSAWSCredentials create:data];
    [credentials save];

    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperationWithBlock:^{
        @try {
            AmazonEC2Client *client = credentials.client;
            [client describeAccountAttributes:[[EC2DescribeAccountAttributesRequest alloc] init]];

            [[NSNotificationCenter defaultCenter] postNotificationName:kGSConnectionsListUpdated object:nil];

            [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        }
        @catch (NSException *exception) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error")
                                                                message:NSLocalizedString(@"Invalid credentials", @"Invalid credentials")
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"Ok", @"Ok")
                                                      otherButtonTitles:nil];
                [alert show];
            });
        }
    }];
}

@end
