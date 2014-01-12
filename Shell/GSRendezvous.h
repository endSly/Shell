//
//  SSLSocket.h
//  Shell
//
//  Created by Endika Gutiérrez Salas on 1/10/14.
//  Copyright (c) 2014 Endika Gutiérrez Salas. All rights reserved.
//

@import Foundation;

@protocol GSRendezvousDelegate;

@interface GSRendezvous : NSObject

@property (nonatomic, strong) NSURL *URL;
@property (nonatomic, weak) id <GSRendezvousDelegate> delegate;

- (BOOL)start;

- (BOOL)writeData:(NSData *)data;
- (NSData *)readData;

@end

@protocol GSRendezvousDelegate <NSObject>

- (void)rendezvous:(GSRendezvous *)rendezvous didReadData:(NSData *)data;

@end
