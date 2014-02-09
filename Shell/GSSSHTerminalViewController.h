//
//  GSSSHTerminalViewController.h
//  Shell
//
//  Created by Endika Gutiérrez Salas on 1/12/14.
//  Copyright (c) 2014 Endika Gutiérrez Salas. All rights reserved.
//

#import "GSTerminalViewController.h"

#import <NMSSH/NMSSH.h>

#import <RMPickerViewController/RMPickerViewController.h>

@class GSKeyPair;

@interface GSSSHTerminalViewController : GSTerminalViewController <NMSSHSessionDelegate, NMSSHChannelDelegate, RMPickerViewControllerDelegate>

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *host;
@property (nonatomic, strong) NSNumber *port;

@property (nonatomic, strong) NSString *password;

@property (nonatomic, strong) GSKeyPair * keyPair;

@property (nonatomic) BOOL shouldUSeKeyPair;

@end
