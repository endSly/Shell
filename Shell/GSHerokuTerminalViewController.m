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
    NSDictionary *params = @{@"id": self.application.id,
                             @"attach": @YES,
                             @"command": @"bash",
                             @"size": @1};

    [self.herokuService postDyno:params callback:^(GSDyno *dyno, NSURLResponse *resp, NSError *error) {

        NSURL *rendezvousURL = [NSURL URLWithString:dyno.attach_url];

        GSRendezvous *rendezvous = [[GSRendezvous alloc] init];
        rendezvous.delegate = self;
        rendezvous.URL = rendezvousURL;

        self.rendezvous = rendezvous;

        [rendezvous start];
    }];
}

#pragma mark - Terminal view delegate

- (void)terminalViewDidLoad:(GSTerminalView *)terminalView
{
    //[self adjustSizeToTerminalView];

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
