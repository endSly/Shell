//
//  UIBarButtonItem+IonIcons.h
//  Neverlate
//
//  Created by Endika Gutiérrez Salas on 20/11/13.
//  Copyright (c) 2013 Endika Gutiérrez Salas. All rights reserved.
//

@import UIKit;

#import "UIFont+IonIcons.h"

@interface UIBarButtonItem (IonIcons)

- (id)initWithIcon:(NSString *)icon target:(id)target action:(SEL)action;
- (id)initWithIcon:(NSString *)icon color:(UIColor *)color target:(id)target action:(SEL)action;

@end
