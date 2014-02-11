//
//  GSAddKeyPairController.m
//  Shell
//
//  Created by Endika Gutiérrez Salas on 2/1/14.
//  Copyright (c) 2014 Endika Gutiérrez Salas. All rights reserved.
//

#import "GSAddKeyPairController.h"

#import "GSFormStyleProvider.h"

#import <MZFormSheetController/MZFormSheetController.h>

#import <ObjectiveRecord/ObjectiveRecord.h>
#import "GSKeyPair.h"

#import "GSImportKeyPairController.h"

#import "GSProgressHUD.h"

@implementation GSAddKeyPairController {
    AKFormFieldTextField *_nameField;

    AKFormFieldSwitch *_savePasswordField;
    AKFormFieldTextField *_passwordField;

    AKFormFieldExpandablePicker *_sizeSelectField;

    AKFormFieldButton *_saveField;

    GSKeyPair *_keyPair;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.title = NSLocalizedString(@"New SSH Key", @"New SSH Key form title");

    [self addNameSection];
    [self addImportSection];
    [self addSecuritySection];
    [self addSaveSection];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addNameSection
{
    AKFormValidator *requiredValidator = [AKFormValidator requiredValidator:@"Please enter a value"];

    _nameField = [AKFormFieldTextField fieldWithKey:@"name"
                                              title:@"Name"
                                        placeholder:@"My SSH key"
                                           delegate:self
                                      styleProvider:[GSFormStyleProvider styleProvider]];

    _nameField.validators = @[requiredValidator];

    AKFormSection *section = [[AKFormSection alloc] initWithFields:@[_nameField]];
    section.headerTitle = @"Name";

    [self addSection:section];
}

- (void)addImportSection
{
    AKFormFieldButton *importButton = [AKFormFieldButton fieldWithKey:@"import"
                                                                title:NSLocalizedString(@"Import", @"Import")
                                                             subtitle:NSLocalizedString(@"Copy parte key", @"")
                                                                image:nil
                                                             delegate:self
                                                        styleProvider:[GSFormStyleProvider styleProvider]];

    AKFormSection *section = [[AKFormSection alloc] initWithFields:@[importButton]];
    section.headerTitle = NSLocalizedString(@"Import", @"Import");

    [self addSection:section];
}

- (void)addSecuritySection
{
    // Size bits
    NSArray *sizeOptions = @[@{KEY_METADATA_ID: @"1024", KEY_METADATA_NAME: @"1024"},
                             @{KEY_METADATA_ID: @"2048", KEY_METADATA_NAME: @"2048"},
                             @{KEY_METADATA_ID: @"4096", KEY_METADATA_NAME: @"4096"}];

    _sizeSelectField = [AKFormFieldExpandablePicker fieldWithKey:@"keySize"
                                                           title:NSLocalizedString(@"Size in bits", @"Key pair size in bits")
                                                     placeholder:nil
                                              metadataCollection:[AKFormMetadataCollection metadataCollectionWithArray:sizeOptions]
                                                   styleProvider:[GSFormStyleProvider styleProvider]];

    _sizeSelectField.value = [AKFormValue value:[AKFormMetadata metadataWithDictionary:sizeOptions[1]]
                                       withType:AKFormValueMetadata];

    // Password fields
    _savePasswordField = [AKFormFieldSwitch fieldWithKey:@"savePassword"
                                                   title:NSLocalizedString(@"Save with password", @"Save with password")
                                                delegate:self
                                           styleProvider:[GSFormStyleProvider styleProvider]];

    _savePasswordField.value = [AKFormValue value:@YES withType:AKFormValueBool];

    _passwordField = [AKFormFieldTextField fieldWithKey:@"password"
                                                  title:NSLocalizedString(@"Password", @"Password")
                                            placeholder:NSLocalizedString(@"password", @"password")
                                               delegate:self
                                          styleProvider:[GSFormStyleProvider styleProvider]];
    _passwordField.secureTextEntry = YES;


    AKFormSection *section = [[AKFormSection alloc] initWithFields:@[_sizeSelectField, _savePasswordField]];
    section.headerTitle = NSLocalizedString(@"Security", @"Security section title");

    NSMapTable *fieldsToShowOnOn = [NSMapTable strongToStrongObjectsMapTable];
    [fieldsToShowOnOn setObject:@[_passwordField]
                         forKey:section];

    _savePasswordField.fieldsToShowOnOn = fieldsToShowOnOn;
    [self addSection:section];
}

- (void)addSaveSection
{
    _saveField = [AKFormFieldButton fieldWithKey:@"save"
                                           title:NSLocalizedString(@"Create", @"Create")
                                        subtitle:nil
                                           image:nil
                                        delegate:self
                                   styleProvider:[GSFormStyleProvider styleProvider]];

    AKFormSection *section = [[AKFormSection alloc] initWithFields:@[_saveField]];

    [self addSection:section];
}

- (void)addSaveImportedSection
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
    AKFormFieldButton *button = cell.valueDelegate;
    if ([button.key isEqualToString:@"import"]) {

        GSImportKeyPairController *importController = [self.storyboard instantiateViewControllerWithIdentifier:@"GSImportKeyPairController"];

        [self mz_presentFormSheetWithViewController:importController animated:YES completionHandler:nil];

        importController.importHandler = ^(GSImportKeyPairController *controller) {

            GSKeyPair *keyPair = [GSKeyPair createKeyPairWithRawPrivateKey:controller.textView.text];

            if (!keyPair) {
                [GSProgressHUD showError:NSLocalizedString(@"Invalid key", @"Invalid key")];
            } else {
                [GSProgressHUD showSuccess:NSLocalizedString(@"Key readed", @"Key readed")];
                _keyPair = keyPair;

                [self.tableView beginUpdates];
                [self clearSections];
                [self addNameSection];
                [self addSaveImportedSection];

                [self.tableView deleteSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 2)]
                              withRowAnimation:UITableViewRowAnimationFade];

                [self.tableView reloadData];
                [self.tableView endUpdates];
            }

            [controller mz_dismissFormSheetControllerAnimated:YES completionHandler:nil];
        };

        importController.cancelHandler = ^(GSImportKeyPairController *controller) {
            [controller mz_dismissFormSheetControllerAnimated:YES completionHandler:nil];
        };


    } else if ([button.key isEqualToString:@"save"]) {
        if (self.validateForm) {
            AKFormMetadata *sizeValue = _sizeSelectField.value.metadataValue;

            if (_keyPair) {
                [_keyPair update:@{@"name": _nameField.value.stringValue}];

            } else {
                NSString *password = _savePasswordField.value.boolValue
                ? _passwordField.value.stringValue
                : nil;

                GSKeyPair *keyPair = [GSKeyPair createKeyPair:_nameField.value.stringValue
                                                         size:sizeValue.serverID.integerValue
                                                     password:password];
                _keyPair = keyPair;
            }

            [_keyPair save];

            [self.navigationController popViewControllerAnimated:YES];
            
        }
    }

}

@end
