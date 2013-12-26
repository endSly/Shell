//
//  GSAppDelegate.h
//  Shell
//
//  Created by Endika Gutiérrez Salas on 12/26/13.
//  Copyright (c) 2013 Endika Gutiérrez Salas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <NanoStore/NanoStore.h>

@interface GSAppDelegate : UIResponder <UIApplicationDelegate> {
    NSFNanoStore *_nanoStore;
}

@property (strong, nonatomic) UIWindow *window;

@end
