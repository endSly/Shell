//
//  GSConnectionFormController.m
//  Shell
//
//  Created by Endika Gutiérrez Salas on 1/3/14.
//  Copyright (c) 2014 Endika Gutiérrez Salas. All rights reserved.
//

#import "GSAddSSHFormController.h"

#import <ObjectiveRecord/ObjectiveRecord.h>
#import <TenzingCore/TenzingCore.h>

#import "GSConnection.h"
#import "GSKeyPair.h"

#import "UIBarButtonItem+IonIcons.h"

#import "GSFormStyleProvider.h"

@interface GSAddSSHFormController ()

@end

@implementation GSAddSSHFormController {
    AKFormFieldTextField *_nameField;
    AKFormFieldTextField *_hostField;
    AKFormFieldTextField *_portField;

    AKFormFieldTextField *_usernameField;
    AKFormFieldSwitch *_savePasswordField;
    AKFormFieldTextField *_passwordField;

    AKFormFieldButton *_saveField;

    AKFormFieldExpandablePicker *_keypairField;

    NSArray *_keyPairs;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self addNameSection];
    [self addServerSection];
    [self addUserAndPasswordSection];
    [self addSSHKeySection];
    [self addSaveSection];
}

- (void)addNameSection
{
    AKFormValidator *requiredValidator = [AKFormValidator requiredValidator:NSLocalizedString(@"Please enter a value", @"Error message")];

    _nameField = [AKFormFieldTextField fieldWithKey:@"name"
                                              title:NSLocalizedString(@"Name", @"Form field")
                                        placeholder:NSLocalizedString(@"My server", @"Name field placeholder")
                                           delegate:self
                                      styleProvider:[GSFormStyleProvider styleProvider]];

    _nameField.validators = @[requiredValidator];

    AKFormSection *section = [[AKFormSection alloc] initWithFields:@[_nameField]];
    section.headerTitle = NSLocalizedString(@"Name", @"Form section header");

    [self addSection:section];
}

- (void)addServerSection
{
    _hostField = [AKFormFieldTextField fieldWithKey:@"host"
                                              title:NSLocalizedString(@"Host", @"Form field")
                                        placeholder:@"myserver.com"
                                           delegate:self
                                      styleProvider:[GSFormStyleProvider styleProvider]];

    AKFormValidator *requiredValidator = [AKFormValidator requiredValidator:@"Please enter a value"];
    _hostField.validators = @[requiredValidator];

    _portField = [AKFormFieldTextField fieldWithKey:@"port"
                                              title:NSLocalizedString(@"Port", @"Form field")
                                        placeholder:@"22"
                                           delegate:self
                                      styleProvider:[GSFormStyleProvider styleProvider]];

    _portField.value = [AKFormValue value:@"22" withType:AKFormValueString];
    _portField.validators = @[requiredValidator];

    AKFormSection *section = [[AKFormSection alloc] initWithFields:@[_hostField, _portField]];
    section.headerTitle = NSLocalizedString(@"Server", @"Form section title");

    [self addSection:section];
}

- (void)addUserAndPasswordSection
{
    _savePasswordField = [AKFormFieldSwitch fieldWithKey:@"savePassword"
                                                   title:NSLocalizedString(@"Save password", @"Form button")
                                                delegate:self
                                           styleProvider:[GSFormStyleProvider styleProvider]];

    _savePasswordField.value = [AKFormValue value:@YES withType:AKFormValueBool];

    _passwordField = [AKFormFieldTextField fieldWithKey:@"password"
                                                  title:NSLocalizedString(@"Password", @"Form field")
                                            placeholder:@"password"
                                               delegate:self
                                          styleProvider:[GSFormStyleProvider styleProvider]];
    _passwordField.secureTextEntry = YES;


    _usernameField = [AKFormFieldTextField fieldWithKey:@"username"
                                                  title:NSLocalizedString(@"Username", @"Form field")
                                            placeholder:@"root"
                                               delegate:self
                                          styleProvider:[GSFormStyleProvider styleProvider]];


    AKFormSection *section = [[AKFormSection alloc] initWithFields:@[_usernameField, _savePasswordField]];
    section.headerTitle = @"User & Password";

    NSMapTable *fieldsToShowOnOn = [NSMapTable strongToStrongObjectsMapTable];
    [fieldsToShowOnOn setObject:@[_passwordField]
                         forKey:section];

    _savePasswordField.fieldsToShowOnOn = fieldsToShowOnOn;
    [self addSection:section];
}

- (void)addSSHKeySection
{
    _keyPairs = [GSKeyPair all];
    if (_keyPairs.count == 0)
        return;

    NSMutableArray *keysCollection = [NSMutableArray arrayWithCapacity:_keyPairs.count + 1];

    [keysCollection addObject:@{KEY_METADATA_ID: @"",
                                KEY_METADATA_NAME: NSLocalizedString(@"<No key>", @"No SSH key option")}];
    for (GSKeyPair *keyPair in _keyPairs) {
        [keysCollection addObject:@{KEY_METADATA_ID: [@([_keyPairs indexOfObject:keyPair]) stringValue],
                                    KEY_METADATA_NAME: keyPair.name}];
    }

    _keypairField = [AKFormFieldExpandablePicker fieldWithKey:@"privateKey"
                                                        title:NSLocalizedString(@"SSH Key", @"SSH Key form field")
                                                  placeholder:@"optional"
                                           metadataCollection:[AKFormMetadataCollection metadataCollectionWithArray:keysCollection]
                                                styleProvider:[GSFormStyleProvider styleProvider]];

    AKFormSection *section = [[AKFormSection alloc] initWithFields:@[_keypairField]];
    section.headerTitle = NSLocalizedString(@"SSH Key Pairs", @"SSH Key Pairs section title");
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
            BOOL savePassword = _savePasswordField.value.boolValue;

            NSDictionary *data = @{@"name": _nameField.value.stringValue,
                                   @"host": _hostField.value.stringValue,
                                   @"port": @(_portField.value.stringValue.intValue),
                                   @"username": _usernameField.value.stringValue,
                                   @"savePassword": @(savePassword),
                                   @"password": savePassword ? _passwordField.value.stringValue : [NSNull null]};

            GSConnection *connection = [GSConnection create:data];

            NSString *keyPairIndex = _keypairField.value.metadataValue.serverID;
            if (keyPairIndex.length) {
                // Key pair selected
                connection.keyPair = _keyPairs[keyPairIndex.integerValue];
            }

            [connection save];

            [[NSNotificationCenter defaultCenter] postNotificationName:@"kGSConnectionsListUpdated" object:nil];

            [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

- (void)cancelAction:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
