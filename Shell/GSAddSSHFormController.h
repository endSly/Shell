//
//  GSConnectionFormController.h
//  Shell
//
//  Created by Endika Gutiérrez Salas on 1/3/14.
//  Copyright (c) 2014 Endika Gutiérrez Salas. All rights reserved.
//

#import <AKForm/AKForm.h>

@class GSConnection;

@interface GSAddSSHFormController : AKFormController <AKFormCellTextFieldDelegate, AKFormCellButtonDelegate>

@property (nonatomic, strong) GSConnection * connection;

@end

