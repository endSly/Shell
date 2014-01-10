//
//  GSMasterViewController.h
//  Shell
//
//  Created by Endika Gutiérrez Salas on 12/26/13.
//  Copyright (c) 2013 Endika Gutiérrez Salas. All rights reserved.
//

@import UIKit;

#import <SWTableViewCell/SWTableViewCell.h>

#import "GSConnectionFormController.h"

@class GSTerminalViewController;

@interface GSConnectionsTableController : UITableViewController <GSConnectionFormDelegate, SWTableViewCellDelegate>

@property (weak, nonatomic) GSTerminalViewController *detailViewController;

@end
