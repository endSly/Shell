//
//  GSDetailViewController.h
//  Shell
//
//  Created by Endika Gutiérrez Salas on 12/26/13.
//  Copyright (c) 2013 Endika Gutiérrez Salas. All rights reserved.
//

@import UIKit;

#import <NMSSH/NMSSH.h>
#import "GSRendezvous.h"

#import "GSTerminalView.h"

@class GSConnection;
@class GSApplication;

@interface GSTerminalViewController : UIViewController <UISplitViewControllerDelegate, GSTerminalViewDelegate, NMSSHSessionDelegate, NMSSHChannelDelegate, GSRendezvousDelegate>

@property (nonatomic, strong) GSConnection * connection;
@property (nonatomic, strong) GSApplication * application;

@property (nonatomic, weak) IBOutlet GSTerminalView * terminalView;
@end
