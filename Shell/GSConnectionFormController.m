//
//  GSConnectionFormController.m
//  Shell
//
//  Created by Endika Gutiérrez Salas on 1/3/14.
//  Copyright (c) 2014 Endika Gutiérrez Salas. All rights reserved.
//

#import "GSConnectionFormController.h"

#import "GSConnection.h"

#import "UIBarButtonItem+IonIcons.h"

@interface GSConnectionFormController ()

@end

@implementation GSConnectionFormController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithIcon:icon_ios7_close_outline target:self action:@selector(cancelAction:)];

    ((QEntryElement *) [self.root elementWithKey:@"name"]).delegate = self;
}

- (void)connectAction:(id)sender
{
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    [self.root fetchValueUsingBindingsIntoObject:data];

    for (NSString *key in data) {
        [self.connection setValue:data[key] forKey:key];
    }

    [self.delegate connectionForm:self didSave:self.connection];

    [self dismissViewControllerAnimated:YES completion:nil];
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
