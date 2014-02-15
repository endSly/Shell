//
//  GSSettingsManager.h
//  Shell
//
//  Created by Endika Gutiérrez Salas on 2/11/14.
//  Copyright (c) 2014 Endika Gutiérrez Salas. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GSSettingsManager : NSObject

@property (nonatomic) BOOL forceScreenSize;
@property (nonatomic) NSInteger screenRows;
@property (nonatomic) NSInteger screenCols;
@property (nonatomic) NSInteger fontSize;

+ (instancetype)manager;

@end
