//
//  GSSettingsController.m
//  Shell
//
//  Created by Endika Gutiérrez Salas on 1/25/14.
//  Copyright (c) 2014 Endika Gutiérrez Salas. All rights reserved.
//

#import "GSSettingsController.h"

#import <ObjectiveRecord/ObjectiveRecord.h>

#import "GSFormStyleProvider.h"

#import "UIBarButtonItem+IonIcons.h"

#import "GSDatabaseManager.h"

#import "GSKeyPair.h"
#import "GSAWSCredentials.h"
#import "GSHerokuAccount.h"

#import "GSProgressHUD.h"

#import "GSSettingsManager.h"

static NSString * const kGSUseCustomPassword = @"kGSUseCustomPassword";
static NSString * const kGSDatabasePassword = @"kGSDatabasePassword";

@implementation GSSettingsController {
    AKFormFieldSwitch *_forceSizeField;
    AKFormFieldTextField *_rowsField;
    AKFormFieldTextField *_colsField;
    AKFormFieldExpandablePicker *_sizeSelectField;

    AKFormFieldSwitch *_usePasswordField;
    AKFormFieldButton *_setPasswordButton;
    AKFormFieldTextField *_currentPasswordField;
    AKFormFieldTextField *_passwordField;
    AKFormFieldTextField *_passwordConfirmationField;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];

    [self buildForm];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithIcon:icon_ios7_close_outline target:self action:@selector(cancelAction:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveAction:)];
}

- (void)buildForm
{
    [self addScreenSizeSection];
    [self addFontSizeSection];
    
    if(![GSDatabaseManager manager].isGuest)
        [self addPasswordSection];

    [self addAccountsSection];
    [self addKeyPairsSection];
}

- (void)addScreenSizeSection
{
    _forceSizeField = [AKFormFieldSwitch fieldWithKey:@"forceSize"
                                                title:@"Set terminal size"
                                             delegate:self
                                        styleProvider:[GSFormStyleProvider styleProvider]];

    _forceSizeField.value = [AKFormValue value:@([GSSettingsManager manager].forceScreenSize)
                                      withType:AKFormValueBool];

    AKFormSection *section = [[AKFormSection alloc] initWithFields:@[_forceSizeField]];
    section.headerTitle = @"Screen Size";

    _rowsField = [AKFormFieldTextField fieldWithKey:@"rows"
                                              title:@"Rows"
                                        placeholder:@"24"
                                           delegate:self
                                      styleProvider:[GSFormStyleProvider styleProvider]];

    _rowsField.value = [AKFormValue value:[NSString stringWithFormat:@"%li", [GSSettingsManager manager].screenRows ?: 24]
                                 withType:AKFormValueString];
    _rowsField.keyboardType = UIKeyboardTypeDecimalPad;

    _colsField = [AKFormFieldTextField fieldWithKey:@"cols"
                                              title:@"Columns"
                                        placeholder:@"80"
                                           delegate:self
                                      styleProvider:[GSFormStyleProvider styleProvider]];

    _colsField.value = [AKFormValue value:[NSString stringWithFormat:@"%li", [GSSettingsManager manager].screenCols ?: 80]
                                 withType:AKFormValueString];
    _colsField.keyboardType = UIKeyboardTypeDecimalPad;


    NSMapTable *fieldsToShowOnOn = [NSMapTable mapTableWithKeyOptions:NSMapTableStrongMemory
                                                         valueOptions:NSMapTableStrongMemory];
    [fieldsToShowOnOn setObject:@[_rowsField, _colsField]
                         forKey:section];

    _forceSizeField.fieldsToShowOnOn = fieldsToShowOnOn;
    [self addSection:section];
}

- (void)addFontSizeSection
{
    NSMutableArray *sizeOptions = [NSMutableArray array];
    for (NSInteger size = 7; size < 19; ++size) {
        [sizeOptions addObject:@{KEY_METADATA_ID: @(size).stringValue, KEY_METADATA_NAME: @(size).stringValue}];
    }

    _sizeSelectField = [AKFormFieldExpandablePicker fieldWithKey:@"fontSize"
                                                           title:NSLocalizedString(@"Font Size", @"Font size")
                                                     placeholder:nil
                                              metadataCollection:[AKFormMetadataCollection metadataCollectionWithArray:[NSArray arrayWithArray:sizeOptions]]
                                                   styleProvider:[GSFormStyleProvider styleProvider]];

    NSDictionary *selectedOption = @{KEY_METADATA_ID: @([GSSettingsManager manager].fontSize ?: 10).stringValue,
                                     KEY_METADATA_NAME: @([GSSettingsManager manager].fontSize ?: 10).stringValue};

    _sizeSelectField.value = [AKFormValue value:[AKFormMetadata metadataWithDictionary:selectedOption]
                                       withType:AKFormValueMetadata];

    AKFormSection *section = [[AKFormSection alloc] initWithFields:@[_sizeSelectField]];
    section.headerTitle = @"Font Size";

    [self addSection:section];
}

- (void)addPasswordSection
{
    BOOL usesUserPassword = [[GSDatabaseManager manager] useUserPassword];

    _usePasswordField = [AKFormFieldSwitch fieldWithKey:@"usePassword"
                                                                    title:@"Use password"
                                                                 delegate:self
                                                            styleProvider:[GSFormStyleProvider styleProvider]];

    AKFormSection *section = [[AKFormSection alloc] initWithFields:@[_usePasswordField]];
    section.headerTitle = @"Password";

    _usePasswordField.value = [AKFormValue value:@(usesUserPassword) withType:AKFormValueBool];

    NSMutableArray *fields = [NSMutableArray array];

    if (usesUserPassword) {
        _currentPasswordField = [AKFormFieldTextField fieldWithKey:@"currentPassword"
                                                             title:@"Old Password"
                                                       placeholder:@"required"
                                                          delegate:self
                                                     styleProvider:[GSFormStyleProvider styleProvider]];
        _currentPasswordField.secureTextEntry = YES;
        [fields addObject:_currentPasswordField];
    }

    _passwordField = [AKFormFieldTextField fieldWithKey:@"password"
                                                  title:@"New Password"
                                            placeholder:@"required"
                                               delegate:self
                                          styleProvider:[GSFormStyleProvider styleProvider]];
    _passwordField.secureTextEntry = YES;
    [fields addObject:_passwordField];

    _passwordConfirmationField = [AKFormFieldTextField fieldWithKey:@"passwordConfirmation"
                                                              title:@"Verify"
                                                        placeholder:@"required"
                                                           delegate:self
                                                      styleProvider:[GSFormStyleProvider styleProvider]];
    _passwordConfirmationField.secureTextEntry = YES;
    [fields addObject:_passwordConfirmationField];

    _setPasswordButton = [AKFormFieldButton fieldWithKey:@"savePassword"
                                                   title:usesUserPassword ? @"Update password" : @"Save password"
                                                subtitle:nil
                                                   image:nil
                                                delegate:self
                                           styleProvider:[GSFormStyleProvider styleProvider]];

    [fields addObject:_setPasswordButton];


    NSMapTable *fieldsToShowOnOn = [NSMapTable mapTableWithKeyOptions:NSMapTableStrongMemory
                                                         valueOptions:NSMapTableStrongMemory];
    [fieldsToShowOnOn setObject:fields
                         forKey:section];
    
    _usePasswordField.fieldsToShowOnOn = fieldsToShowOnOn;
    [self addSection:section];
}

- (void)addKeyPairsSection
{
    AKFormFieldButton *showAccountsButton = [AKFormFieldButton fieldWithKey:@"editKeyPairs"
                                                                      title:@"Edit SSH Keys"
                                                                   subtitle:[NSString stringWithFormat:@"%lu keys", [[GSKeyPair all] count]]
                                                                      image:nil
                                                                   delegate:self
                                                              styleProvider:[GSFormStyleProvider styleProvider]];

    AKFormSection *section = [[AKFormSection alloc] initWithFields:@[showAccountsButton]];
    section.headerTitle = @"Key Pairs";
    [self addSection:section];
}

- (void)addAccountsSection
{
    NSUInteger connectionsCount = [[GSAWSCredentials all] count] + [[GSHerokuAccount all] count];
    AKFormFieldButton *showKeyPairsButton = [AKFormFieldButton fieldWithKey:@"editAccounts"
                                                                      title:@"Edit Accounts"
                                                                   subtitle:[NSString stringWithFormat:@"%lu accounts", connectionsCount]
                                                                      image:nil
                                                                   delegate:self
                                                              styleProvider:[GSFormStyleProvider styleProvider]];

    AKFormSection *section = [[AKFormSection alloc] initWithFields:@[showKeyPairsButton]];
    section.headerTitle = @"Accounts";
    [self addSection:section];
}

- (void)cancelAction:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)saveAction:(id)sender
{
    if ([self validateForm]) {
        [GSSettingsManager manager].forceScreenSize = _forceSizeField.value.boolValue;
        [GSSettingsManager manager].screenCols = _colsField.value.stringValue.integerValue;
        [GSSettingsManager manager].screenRows = _rowsField.value.stringValue.integerValue;
        [GSSettingsManager manager].fontSize = _sizeSelectField.value.metadataValue.serverID.integerValue;

        [[GSSettingsManager manager] synchronize];
        
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];

        [GSProgressHUD showSuccess:NSLocalizedString(@"Saved", @"Saved")];
    }

}

#pragma mark - Button Cell Delegate

- (void)didPressButtonCell:(AKFormCellButton *)cell
{
    AKFormFieldButton *field = cell.valueDelegate;

    if ([field.key isEqualToString:@"editKeyPairs"]) {
        [self performSegueWithIdentifier:@"GSEditKeyPairsSegue" sender:self];

    } else if ([field.key isEqualToString:@"editAccounts"]) {
        [self performSegueWithIdentifier:@"GSShowAccountsSegue" sender:self];

    } else if ([field.key isEqualToString:@"savePassword"]) {
        NSString *newPassword = _passwordField.value.stringValue;

        if ([newPassword isEqualToString:_passwordConfirmationField.value.stringValue]) {
            BOOL result = [[GSDatabaseManager manager] updateCurrentKey:_currentPasswordField.value.stringValue newKey:newPassword];

            if (result) {
                _passwordField.value = [AKFormValue value:@"" withType:AKFormValueString];
                _passwordConfirmationField.value = [AKFormValue value:@"" withType:AKFormValueString];

                [self.tableView reloadData];

                [GSProgressHUD showSuccess:NSLocalizedString(@"Password changed", @"Password changed hud")];

            } else {
                [GSProgressHUD showError:NSLocalizedString(@"The password is incorrect", @"Wrong password hud")];
            }
            _currentPasswordField.value = [AKFormValue value:@"" withType:AKFormValueString];

        } else {
            _passwordField.value = [AKFormValue value:@"" withType:AKFormValueString];
            _passwordConfirmationField.value = [AKFormValue value:@"" withType:AKFormValueString];
            
            [GSProgressHUD showError:NSLocalizedString(@"Passwords do not match", @"Passwords do not match hud")];
        }

        [self clearSections];
        [self buildForm];
        [self.tableView reloadData];
    }
}

@end
