//
//  GSImportKeyPairController.m
//  Shell
//
//  Created by Endika Gutiérrez Salas on 2/10/14.
//  Copyright (c) 2014 Endika Gutiérrez Salas. All rights reserved.
//

#import "GSImportKeyPairController.h"

@implementation GSImportKeyPairController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    self.textView.text = [UIPasteboard generalPasteboard].string;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)importAction:(id)sender
{
    if (self.importHandler) {
        self.importHandler(self);
    }
}

- (IBAction)cancelAction:(id)sender
{
    if (self.cancelHandler) {
        self.cancelHandler(self);
    }
}

@end
