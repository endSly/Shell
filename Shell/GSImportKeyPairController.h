//
//  GSImportKeyPairController.h
//  Shell
//
//  Created by Endika Gutiérrez Salas on 2/10/14.
//  Copyright (c) 2014 Endika Gutiérrez Salas. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GSImportKeyPairController : UIViewController

@property (nonatomic, weak) IBOutlet UITextView *textView;

@property (nonatomic, copy) void (^importHandler)(GSImportKeyPairController *controller);
@property (nonatomic, copy) void (^cancelHandler)(GSImportKeyPairController *controller);

- (IBAction)importAction:(id)sender;
- (IBAction)cancelAction:(id)sender;

@end
