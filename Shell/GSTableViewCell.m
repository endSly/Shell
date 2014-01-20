//
//  GSTableViewCell.m
//  Shell
//
//  Created by Endika Gutiérrez Salas on 1/10/14.
//  Copyright (c) 2014 Endika Gutiérrez Salas. All rights reserved.
//

#import "GSTableViewCell.h"

#import "UIButton+IonIcons.h"

@implementation GSTableViewCell {

}

- (void)setRemoveButtonVisible:(BOOL)removeButtonVisible
{
    if (_removeButtonVisible == removeButtonVisible)
        return;

    if (removeButtonVisible) {
        UIButton *removeButton = [UIButton buttonWithIcon:icon_ios7_trash_outline size:32];
        [removeButton setTitle:icon_ios7_trash forState:UIControlStateHighlighted];
        removeButton.backgroundColor = [UIColor redColor];

        self.rightUtilityButtons = [self.rightUtilityButtons ?: @[] arrayByAddingObject:removeButton];
    } else {

    }
    removeButtonVisible = _removeButtonVisible;
}

- (void)setEditButtonVisible:(BOOL)editButtonVisible
{
    if (_editButtonVisible == editButtonVisible)
        return;

    if (editButtonVisible) {
        UIButton *editButton = [UIButton buttonWithIcon:icon_ios7_compose_outline size:32];
        [editButton setTitle:icon_ios7_compose forState:UIControlStateHighlighted];
        editButton.backgroundColor = [UIColor lightGrayColor];

        self.rightUtilityButtons = [self.rightUtilityButtons ?: @[] arrayByAddingObject:editButton];
    } else {

    }
    editButtonVisible = _editButtonVisible;

}

- (void)setRebootButtonVisible:(BOOL)rebootButtonVisible
{
    if (_rebootButtonVisible == rebootButtonVisible)
        return;

    if (rebootButtonVisible) {
        UIButton *rebootButton = [UIButton buttonWithIcon:icon_ios7_refresh_outline size:32];
        [rebootButton setTitle:icon_ios7_refresh forState:UIControlStateHighlighted];
        rebootButton.backgroundColor = [UIColor lightGrayColor];

        self.rightUtilityButtons = [self.rightUtilityButtons ?: @[] arrayByAddingObject:rebootButton];
    } else {

    }
    rebootButtonVisible = _rebootButtonVisible;
}


@end
