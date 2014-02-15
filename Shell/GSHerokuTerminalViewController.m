//
//  GSHerokuTerminalViewController.m
//  Shell
//
//  Created by Endika Gutiérrez Salas on 1/12/14.
//  Copyright (c) 2014 Endika Gutiérrez Salas. All rights reserved.
//

#import "GSHerokuTerminalViewController.h"

#import "GSHerokuService.h"
#import "GSApplication.h"
#import "GSDyno.h"

#import "GSProgressHUD.h"

#import "GSSettingsManager.h"

@interface GSHerokuTerminalViewController ()

@property (nonatomic, strong) GSRendezvous *rendezvous;

@end

@implementation GSHerokuTerminalViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = self.application.name;
}

- (void)connect
{
    [GSProgressHUD show:NSLocalizedString(@"Connecting...", @"Connecting hud")];

    NSUInteger cols, rows;

    if ([GSSettingsManager manager].forceScreenSize) {
        rows = [GSSettingsManager manager].screenRows;
        cols = [GSSettingsManager manager].screenCols;

    } else {
        [self.terminalView getScreenCols:&cols rows:&rows];
    }
    rows = MAX(rows, 20);
    cols = MAX(cols, 40);

    [self.terminalView setCols:cols rows:rows];

    NSDictionary *env = @{@"TERM": @"xterm",
                          @"COLUMNS": @(cols),
                          @"LINES": @(rows)};

    NSDictionary *params = @{@"id": self.application.id,
                             @"attach": @YES,
                             @"command": @"bash",
                             @"env": env,
                             @"size": @1};

    [self.herokuService postDyno:params callback:^(GSDyno *dyno, NSURLResponse *resp, NSError *error) {

        NSURL *rendezvousURL = [NSURL URLWithString:dyno.attach_url];

        GSRendezvous *rendezvous = [[GSRendezvous alloc] init];
        rendezvous.delegate = self;
        rendezvous.URL = rendezvousURL;

        self.rendezvous = rendezvous;

        [rendezvous start];

        dispatch_async(dispatch_get_main_queue(), ^{
            [GSProgressHUD dismiss];
        });
    }];
}

- (BOOL)isConnected
{
    return self.rendezvous.isConnected;
}

#pragma mark - Terminal view delegate

- (void)terminalViewDidLoad:(GSTerminalView *)terminalView
{
    [super terminalViewDidLoad:terminalView];

    [self connect];
}

- (void)terminalViewDidResize:(GSTerminalView *)terminalView
{
    //[self adjustSizeToTerminalView];
}

- (void)terminalView:(GSTerminalView *)terminalView didWrite:(NSString *)data
{
    [_rendezvous writeData:[data dataUsingEncoding:NSUTF8StringEncoding]];
}

#pragma mark - Rendezvous delegate

- (void)rendezvous:(GSRendezvous *)rendezvous didReadData:(NSData *)data
{
    [self.terminalView terminalWrite:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
}

@end
