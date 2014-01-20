//
//  GSConnectionFormController.h
//  Shell
//
//  Created by Endika Gutiérrez Salas on 1/3/14.
//  Copyright (c) 2014 Endika Gutiérrez Salas. All rights reserved.
//

#import <QuickDialog/QuickDialog.h>

@class GSConnection;

@protocol GSConnectionFormDelegate;

@interface GSAddSSHFormController : QuickDialogController <QuickDialogEntryElementDelegate>

@property (nonatomic, strong) GSConnection * connection;

@end

