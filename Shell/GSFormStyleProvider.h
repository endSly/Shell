//
//  GSFormStyleProvider.h
//  Shell
//
//  Created by Endika Gutiérrez Salas on 1/26/14.
//  Copyright (c) 2014 Endika Gutiérrez Salas. All rights reserved.
//

#import <AKForm/AKForm.h>

@interface GSFormStyleProvider : NSObject <AKFormCellTextFieldStyleProvider, AKFormCellSwitchStyleProvider, AKFormCellButtonStyleProvider, AKFormCellLabelStyleProvider>

+ (instancetype)styleProvider;

@end
