//
//  GSSettingsManager.m
//  Shell
//
//  Created by Endika Gutiérrez Salas on 2/11/14.
//  Copyright (c) 2014 Endika Gutiérrez Salas. All rights reserved.
//

#import "GSSettingsManager.h"

@implementation GSSettingsManager {
    NSUserDefaults *_settingsDefaults;
}

- (id)init
{
    self = [super init];
    if (self) {
        _settingsDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"GSSettings"];
    }
    return self;
}

- (BOOL)forceScreenSize
{
    return [_settingsDefaults boolForKey:@"GSForceScreenSize"];
}

- (void)setForceScreenSize:(BOOL)forceScreenSize
{
    [_settingsDefaults setBool:forceScreenSize forKey:@"GSForceScreenSize"];
}

- (NSInteger)screenCols
{
    return [_settingsDefaults integerForKey:@"GSScreenCols"];
}

- (void)setScreenCols:(NSInteger)screenCols
{
    [_settingsDefaults setInteger:screenCols forKey:@"GSScreenCols"];
}

- (NSInteger)screenRows
{
    return [_settingsDefaults integerForKey:@"GSScreenRows"];
}

- (void)setScreenRows:(NSInteger)screenRows
{
    [_settingsDefaults setInteger:screenRows forKey:@"GSScreenRows"];
}

+ (instancetype)manager
{
    static GSSettingsManager *manager = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ manager = [[self alloc] init]; });

    return manager;
}

@end
