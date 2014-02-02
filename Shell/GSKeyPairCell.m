//
//  GSKeyPairCell.m
//  Shell
//
//  Created by Endika Gutiérrez Salas on 2/2/14.
//  Copyright (c) 2014 Endika Gutiérrez Salas. All rights reserved.
//

#import "GSKeyPairCell.h"

#import "UIFont+IonIcons.h"

@implementation GSKeyPairCell

- (void)layoutSubviews
{
    [super layoutSubviews];

    self.passwordIcon.font = [UIFont iconicFontOfSize:22.0];
    self.passwordIcon.text = icon_key;
}

@end
