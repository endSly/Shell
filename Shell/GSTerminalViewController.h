//
//  GSDetailViewController.h
//  Shell
//
//  Created by Endika Gutiérrez Salas on 12/26/13.
//  Copyright (c) 2013 Endika Gutiérrez Salas. All rights reserved.
//

@import UIKit;

#import "GSTerminalView.h"

@interface GSTerminalViewController : UIViewController <UISplitViewControllerDelegate, GSTerminalViewDelegate>

@property (nonatomic, weak) IBOutlet GSTerminalView * terminalView;
@end
