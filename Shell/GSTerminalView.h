//
//  GSTerminalView.h
//  Shell
//
//  Created by Endika Gutiérrez Salas on 12/26/13.
//  Copyright (c) 2013 Endika Gutiérrez Salas. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GSTerminalViewDelegate;

@interface GSTerminalView : UIView <UIWebViewDelegate>

@property (nonatomic, readonly) UIScrollView * scrollView;

@property (nonatomic, weak) id <GSTerminalViewDelegate> delegate;

- (void)terminalWrite:(NSString *)string;
- (void)setCols:(NSUInteger)cols rows:(NSUInteger)rows;
- (void)getScreenCols:(NSUInteger *)cols rows:(NSUInteger *)rows;
- (void)adjustSizeToScreen;

- (void)showAccessoryToolbar;
- (void)hideAccesoryToolbar;

@end

@protocol GSTerminalViewDelegate <NSObject>

- (void)terminalViewDidLoad:(GSTerminalView *)terminalView;
- (void)terminalView:(GSTerminalView *)terminalView didWrite:(NSString *)data;
- (void)terminalViewDidResize:(GSTerminalView *)terminalView;

@end
