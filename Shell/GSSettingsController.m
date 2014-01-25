//
//  GSSettingsController.m
//  Shell
//
//  Created by Endika Gutiérrez Salas on 1/25/14.
//  Copyright (c) 2014 Endika Gutiérrez Salas. All rights reserved.
//

#import "GSSettingsController.h"

@interface GSSettingsController ()

@end

@implementation GSSettingsController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self addScreenSizeSection];
    [self addPasswordSection];
    [self addKeyPairsSection];
}

- (void)addScreenSizeSection
{
    AKFormFieldSwitch *forceSizeField = [AKFormFieldSwitch fieldWithKey:@"autoSize"
                                                                  title:@"Adjust size to Screen"
                                                               delegate:self
                                                          styleProvider:self];

    AKFormSection *section = [[AKFormSection alloc] initWithFields:@[forceSizeField]];
    section.headerTitle = @"Screen Size";

    NSMutableArray *fields = [NSMutableArray array];

    //Number Field
    AKFormFieldTextField *rowsField = [AKFormFieldTextField fieldWithKey:@"rows"
                                                                   title:@"Rows"
                                                             placeholder:@"24"
                                                                delegate:self
                                                           styleProvider:self];
    rowsField.keyboardType = UIKeyboardTypeDecimalPad;
    [fields addObject:rowsField];

    AKFormFieldTextField *colsField = [AKFormFieldTextField fieldWithKey:@"cols"
                                                                   title:@"Columns"
                                                             placeholder:@"80"
                                                                delegate:self
                                                           styleProvider:self];
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
                                                            styleProvider:self];

    AKFormSection *section = [[AKFormSection alloc] initWithFields:@[usePasswordField]];
    section.headerTitle = @"Password";

    NSMutableArray *fields = [NSMutableArray array];

    AKFormFieldTextField *passwordField = [AKFormFieldTextField fieldWithKey:@"password"
                                                                       title:@"Password"
                                                                 placeholder:@"required"
                                                                    delegate:self
                                                               styleProvider:self];
    passwordField.secureTextEntry = YES;
    [fields addObject:passwordField];

    AKFormFieldTextField *passwordConfirmationField = [AKFormFieldTextField fieldWithKey:@"passwordConfirmation"
                                                                                   title:@"Password Confirmation"
                                                                             placeholder:@"required"
                                                                                delegate:self
                                                                           styleProvider:self];
    passwordConfirmationField.secureTextEntry = YES;
    [fields addObject:passwordConfirmationField];


    NSMapTable *fieldsToShowOnOn = [NSMapTable mapTableWithKeyOptions:NSMapTableStrongMemory
                                                         valueOptions:NSMapTableStrongMemory];
    [fieldsToShowOnOn setObject:fields
                         forKey:section];
    
    usePasswordField.fieldsToShowOnOn = fieldsToShowOnOn;
    [self addSection:section];
}

- (void)addKeyPairsSection
{
    AKFormFieldButton *showKeyPairsButton = [AKFormFieldButton fieldWithKey:@"showKeyPairs"
                                                                      title:@"Show Key Pairs"
                                                                   subtitle:nil
                                                                      image:nil
                                                                   delegate:self
                                                              styleProvider:self];

    AKFormSection *section = [[AKFormSection alloc] initWithFields:@[showKeyPairsButton]];
    section.headerTitle = @"Key Pairs";
    [self addSection:section];
}

#pragma mark - Text Field Cell Style Provider

- (AKFormCellTextFieldStyle)styleForTextFieldCell:(AKFormCellTextField *)cell
{
    return AKFormCellTextFieldStyleLabelWithDynamicWidth;
}

- (UIFont *)labelFontForMode:(AKFormCellTextFieldMode)mode style:(AKFormCellTextFieldStyle)style forTextFieldCell:(AKFormCellTextField *)cell
{
    return [UIFont fontWithName:@"HelveticaNeue-Thin" size:17.0f];
}

#pragma mark - Switch Cell Style Provider

- (AKFormCellSwitchStyle)styleForSwitchCell:(AKFormCellSwitch *)cell
{
    return AKFormCellSwitchStyleLabelWithStaticWidth3;
}

- (CGFloat)labelWidthForSwitchCell:(AKFormCellSwitch *)cell
{
    return 280.0f;
}

- (UIColor *)tintColorForSwitchCell:(AKFormCellSwitch *)cell
{
    return [UIColor colorWith8BitRed:52 green:102 blue:176];
}

- (UIFont *)labelFontForMode:(AKFormCellSwitchMode)mode style:(AKFormCellSwitchStyle)style forSwitchCell:(AKFormCellSwitch *)cell
{
    return [UIFont fontWithName:@"HelveticaNeue-Thin" size:17.0f];
}

#pragma mark - Button Cell Style Provider

- (UIFont *)labelFontForMode:(AKFormCellButtonMode)mode style:(AKFormCellButtonStyle)style forButtonCell:(AKFormCellButton *)cell
{
    return [UIFont fontWithName:@"HelveticaNeue-Thin" size:17.0f];
}

#pragma mark - Button Cell Delegate

- (void)didPressButtonCell:(AKFormCellButton *)cell
{
    AKFormFieldButton *field = cell.valueDelegate;

    if ([field.key isEqualToString:@"showKeyPairs"]) {
        
    }
}


@end
