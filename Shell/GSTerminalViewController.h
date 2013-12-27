//
//  GSDetailViewController.h
//  Shell
//
//  Created by Endika Gutiérrez Salas on 12/26/13.
//  Copyright (c) 2013 Endika Gutiérrez Salas. All rights reserved.
//

@import UIKit;
#import <NMSSH/NMSSH.h>

#import "GSTerminalView.h"

@class GSConnection;

@interface GSTerminalViewController : UIViewController <UISplitViewControllerDelegate, GSTerminalViewDelegate, NMSSHSessionDelegate, NMSSHChannelDelegate>

@property (strong, nonatomic) GSConnection * connection;

@property (weak, nonatomic) IBOutlet GSTerminalView * terminalView;
@end
