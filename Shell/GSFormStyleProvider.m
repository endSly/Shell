//
//  GSFormStyleProvider.m
//  Shell
//
//  Created by Endika Gutiérrez Salas on 1/26/14.
//  Copyright (c) 2014 Endika Gutiérrez Salas. All rights reserved.
//

#import "GSFormStyleProvider.h"

@implementation GSFormStyleProvider

+ (instancetype)styleProvider
{
    static GSFormStyleProvider *styleProvider = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        styleProvider = [[GSFormStyleProvider alloc] init];
    });

    return styleProvider;
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

#pragma mark - Cell Label Style Provider

- (UIFont *)titleLabelFontForMode:(AKFormCellLabelMode)mode style:(AKFormCellLabelStyle)style forLabelCell:(AKFormCellLabel *)cell
{
    return [UIFont fontWithName:@"HelveticaNeue-Thin" size:17.0f];
}

- (UIFont *)valueLabelFontForMode:(AKFormCellLabelMode)mode style:(AKFormCellLabelStyle)style forLabelCell:(AKFormCellLabel *)cell
{
    return [UIFont fontWithName:@"HelveticaNeue-Thin" size:17.0f];
}

@end
