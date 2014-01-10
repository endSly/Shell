//
//  UIButton+IonIcons.m
//  Shell
//
//  Created by Endika Gutiérrez Salas on 1/10/14.
//  Copyright (c) 2014 Endika Gutiérrez Salas. All rights reserved.
//

#import "UIButton+IonIcons.h"

@implementation UIButton (IonIcons)

+ (instancetype)buttonWithIcon:(NSString *)icon size:(CGFloat)size
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.titleLabel.font = [UIFont iconicFontOfSize:size];
    [button setTitle:icon forState:UIControlStateNormal];
    return button;
}

@end
