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

@interface GSConnectionFormController : QuickDialogController <QuickDialogEntryElementDelegate>

@property (nonatomic, strong) GSConnection * connection;
@property (nonatomic, weak) id <GSConnectionFormDelegate> delegate;

@end

@protocol GSConnectionFormDelegate <NSObject>

- (void)connectionForm:(GSConnectionFormController *)controller didSave:(GSConnection *)connection;

@end
