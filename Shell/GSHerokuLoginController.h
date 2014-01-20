//
//  GSHerokuLoginController.h
//  Shell
//
//  Created by Endika Gutiérrez Salas on 1/12/14.
//  Copyright (c) 2014 Endika Gutiérrez Salas. All rights reserved.
//

@import UIKit;

#import "GSConnectionsTableController.h"

@interface GSHerokuLoginController : UIViewController <UIWebViewDelegate>

@property (nonatomic, weak) IBOutlet UIWebView *webView;

@end
