//
//  GSAWSAccountFormController.m
//  Shell
//
//  Created by Endika Gutiérrez Salas on 1/16/14.
//  Copyright (c) 2014 Endika Gutiérrez Salas. All rights reserved.
//

#import "GSAWSAccountFormController.h"

#import <ObjectiveRecord/ObjectiveRecord.h>
#import <AWSRuntime/AWSRuntime.h>

#import "GSAWSCredentials.h"

#import "GSFormStyleProvider.h"

@interface GSAWSAccountFormController ()

@end

@implementation GSAWSAccountFormController {
    AKFormFieldTextField *_nameField;
    AKFormFieldTextField *_accessKeyField;
    AKFormFieldTextField *_accessSecretField;

    AKFormFieldButton *_saveField;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = NSLocalizedString(@"Add AWS Account", @"Add AWS Account");

    [self addNameSection];
    [self addCredentialsSection];
    [self addSaveSection];
}

- (void)addNameSection
{
    AKFormValidator *requiredValidator = [AKFormValidator requiredValidator:@"Please enter a value"];

    _nameField = [AKFormFieldTextField fieldWithKey:@"accountName"
                                              title:@"Name"
                                        placeholder:@"My AWS account"
                                           delegate:self
                                      styleProvider:[GSFormStyleProvider styleProvider]];

    _nameField.validators = @[requiredValidator];

    AKFormSection *section = [[AKFormSection alloc] initWithFields:@[_nameField]];
    section.headerTitle = @"Name";

    [self addSection:section];
}

- (void)addCredentialsSection
{
    AKFormValidator *requiredValidator = [AKFormValidator requiredValidator:@"Please enter a value"];

    _accessKeyField = [AKFormFieldTextField fieldWithKey:@"accessKey"
                                                   title:@"Key"
                                             placeholder:@"AWS Key"
                                                delegate:self
                                           styleProvider:[GSFormStyleProvider styleProvider]];

    _nameField.validators = @[requiredValidator];

    _accessSecretField = [AKFormFieldTextField fieldWithKey:@"accessSecret"
                                                      title:@"Secret"
                                                placeholder:@"AWS Secret"
                                                   delegate:self
                                              styleProvider:[GSFormStyleProvider styleProvider]];

    _accessSecretField.validators = @[requiredValidator];

    AKFormSection *section = [[AKFormSection alloc] initWithFields:@[_accessKeyField, _accessSecretField]];
    section.headerTitle = @"Credentials";
    
    [self addSection:section];
}

- (void)addSaveSection
{
    _saveField = [AKFormFieldButton fieldWithKey:@"save"
                                           title:NSLocalizedString(@"Save", @"Save")
                                        subtitle:nil
                                           image:nil
                                        delegate:self
                                   styleProvider:[GSFormStyleProvider styleProvider]];

    AKFormSection *section = [[AKFormSection alloc] initWithFields:@[_saveField]];

    [self addSection:section];
}

- (void)didPressButtonCell:(AKFormCellButton *)cell
{
    if (cell.valueDelegate == _saveField) {
        if ([self validateForm]) {

            NSDictionary *data = @{@"accountName": _nameField.value.stringValue,
                                   @"accessKey": _accessKeyField.value.stringValue,
                                   @"accessSecret": _accessSecretField.value.stringValue};

            GSAWSCredentials *connection = [GSAWSCredentials create:data];
            [connection save];

            [[NSNotificationCenter defaultCenter] postNotificationName:@"kGSConnectionsListUpdated" object:nil];

            [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        }
    }
}


@end
