//
//  GSMasterViewController.h
//  Shell
//
//  Created by Endika Gutiérrez Salas on 12/26/13.
//  Copyright (c) 2013 Endika Gutiérrez Salas. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GSTerminalViewController;

@interface GSConnectionsTableController : UITableViewController

@property (strong, nonatomic) GSTerminalViewController *detailViewController;

@end
