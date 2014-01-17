//
//  GSConnectionFormController.m
//  Shell
//
//  Created by Endika Gutiérrez Salas on 1/3/14.
//  Copyright (c) 2014 Endika Gutiérrez Salas. All rights reserved.
//

#import "GSAddSSHFormController.h"

#import <ObjectiveRecord/ObjectiveRecord.h>

#import "GSConnection.h"

#import "UIBarButtonItem+IonIcons.h"

@interface GSAddSSHFormController ()

@end

@implementation GSAddSSHFormController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    QRootElement *root = [[QRootElement alloc] initWithJSONFile:@"connection-form" andData:@{@"port": @22}];

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

    ((QEntryElement *) [self.root elementWithKey:@"name"]).delegate = self;
}

- (void)connectAction:(id)sender
{
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    [self.root fetchValueUsingBindingsIntoObject:data];

    GSConnection *connection = [GSConnection create:data];
    [connection save];

    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)cancelAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)QEntryEditingChangedForElement:(QEntryElement *)element andCell:(QEntryTableViewCell *)cell
{
    if ([element.key isEqualToString:@"name"]) {
        self.title = element.textValue.length > 0 ? element.textValue : @"New connection";
    }
}

@end
