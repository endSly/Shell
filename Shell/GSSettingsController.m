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

#import "GSPasswordManager.h"

#import "GSKeyPair.h"
#import "GSAWSCredentials.h"
#import "GSHerokuAccount.h"

#import "GSProgressHUD.h"

static NSString * const kGSUseCustomPassword = @"kGSUseCustomPassword";
static NSString * const kGSDatabasePassword = @"kGSDatabasePassword";

@implementation GSSettingsController {

    AKFormFieldButton *_setPasswordButton;
    AKFormFieldTextField *_currentPasswordField;
    AKFormFieldTextField *_passwordField;
    AKFormFieldTextField *_passwordConfirmationField;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self addScreenSizeSection];
    [self addPasswordSection];
    [self addAccountsSection];
    [self addKeyPairsSection];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithIcon:icon_ios7_close_outline target:self action:@selector(cancelAction:)];
}

- (void)addScreenSizeSection
{
    AKFormFieldSwitch *forceSizeField = [AKFormFieldSwitch fieldWithKey:@"autoSize"
                                                                  title:@"Adjust size to Screen"
                                                               delegate:self
                                                          styleProvider:[GSFormStyleProvider styleProvider]];

    forceSizeField.value = [AKFormValue value:@YES withType:AKFormValueBool];

    AKFormSection *section = [[AKFormSection alloc] initWithFields:@[forceSizeField]];
    section.headerTitle = @"Screen Size";

    NSMutableArray *fields = [NSMutableArray array];

    //Number Field
    AKFormFieldTextField *rowsField = [AKFormFieldTextField fieldWithKey:@"rows"
                                                                   title:@"Rows"
                                                             placeholder:@"24"
                                                                delegate:self
                                                           styleProvider:[GSFormStyleProvider styleProvider]];
    rowsField.keyboardType = UIKeyboardTypeDecimalPad;
    [fields addObject:rowsField];

    AKFormFieldTextField *colsField = [AKFormFieldTextField fieldWithKey:@"cols"
                                                                   title:@"Columns"
                                                             placeholder:@"80"
                                                                delegate:self
                                                           styleProvider:[GSFormStyleProvider styleProvider]];
    rowsField.keyboardType = UIKeyboardTypeDecimalPad;
    [fields addObject:colsField];


    NSMapTable *fieldsToShowOnOn = [NSMapTable mapTableWithKeyOptions:NSMapTableStrongMemory
                                                         valueOptions:NSMapTableStrongMemory];
    [fieldsToShowOnOn setObject:fields
                         forKey:section];

    forceSizeField.fieldsToHideOnOn = fieldsToShowOnOn;
    [self addSection:section];
}

- (void)addPasswordSection
{
    AKFormFieldSwitch *usePasswordField = [AKFormFieldSwitch fieldWithKey:@"usePassword"
                                                                    title:@"Use password"
                                                                 delegate:self
                                                            styleProvider:[GSFormStyleProvider styleProvider]];

    AKFormSection *section = [[AKFormSection alloc] initWithFields:@[usePasswordField]];
    section.headerTitle = @"Password";

    NSMutableArray *fields = [NSMutableArray array];

    if ([[GSPasswordManager manager] useUserPassword]) {
        _currentPasswordField = [AKFormFieldTextField fieldWithKey:@"currentPassword"
                                                             title:@"Current Password"
                                                       placeholder:@"required"
                                                          delegate:self
                                                     styleProvider:[GSFormStyleProvider styleProvider]];
        _currentPasswordField.secureTextEntry = YES;
        [fields addObject:_currentPasswordField];
    }

    _passwordField = [AKFormFieldTextField fieldWithKey:@"password"
                                                  title:@"Password"
                                            placeholder:@"required"
                                               delegate:self
                                          styleProvider:[GSFormStyleProvider styleProvider]];
    _passwordField.secureTextEntry = YES;
    [fields addObject:_passwordField];

    _passwordConfirmationField = [AKFormFieldTextField fieldWithKey:@"passwordConfirmation"
                                                              title:@"Password Confirmation"
                                                        placeholder:@"required"
                                                           delegate:self
                                                      styleProvider:[GSFormStyleProvider styleProvider]];
    _passwordConfirmationField.secureTextEntry = YES;
    [fields addObject:_passwordConfirmationField];

    _setPasswordButton = [AKFormFieldButton fieldWithKey:@"savePassword"
                                                   title:@"Save password"
                                                subtitle:nil
                                                   image:nil
                                                delegate:self
                                           styleProvider:[GSFormStyleProvider styleProvider]];

    _setPasswordButton.value = [AKFormValue value:@([[GSPasswordManager manager] useUserPassword]) withType:AKFormValueBool];
    [fields addObject:_setPasswordButton];


    NSMapTable *fieldsToShowOnOn = [NSMapTable mapTableWithKeyOptions:NSMapTableStrongMemory
                                                         valueOptions:NSMapTableStrongMemory];
    [fieldsToShowOnOn setObject:fields
                         forKey:section];
    
    usePasswordField.fieldsToShowOnOn = fieldsToShowOnOn;
    [self addSection:section];
}

- (void)addKeyPairsSection
{
    AKFormFieldButton *showAccountsButton = [AKFormFieldButton fieldWithKey:@"editKeyPairs"
                                                                      title:@"Edit Key Pairs"
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
            BOOL result = [[GSPasswordManager manager] updateCurrentKey:_currentPasswordField.value.stringValue newKey:newPassword];

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
    }
}

@end
