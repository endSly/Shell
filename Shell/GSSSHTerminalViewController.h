//
//  GSSSHTerminalViewController.h
//  Shell
//
//  Created by Endika Gutiérrez Salas on 1/12/14.
//  Copyright (c) 2014 Endika Gutiérrez Salas. All rights reserved.
//

#import "GSTerminalViewController.h"

#import <NMSSH/NMSSH.h>

@class GSConnection;

@interface GSSSHTerminalViewController : GSTerminalViewController <NMSSHSessionDelegate, NMSSHChannelDelegate>

@property (nonatomic, strong) GSConnection * connection;

@end
