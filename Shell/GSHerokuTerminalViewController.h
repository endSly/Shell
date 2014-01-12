//
//  GSHerokuTerminalViewController.h
//  Shell
//
//  Created by Endika Gutiérrez Salas on 1/12/14.
//  Copyright (c) 2014 Endika Gutiérrez Salas. All rights reserved.
//

#import "GSTerminalViewController.h"

#import "GSRendezvous.h"

@class GSHerokuService;
@class GSApplication;

@interface GSHerokuTerminalViewController : GSTerminalViewController <GSRendezvousDelegate>

@property (nonatomic, strong) GSHerokuService * herokuService;
@property (nonatomic, strong) GSApplication * application;

@end
