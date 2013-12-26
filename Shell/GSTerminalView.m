//
//  GSTerminalView.m
//  Shell
//
//  Created by Endika Gutiérrez Salas on 12/26/13.
//  Copyright (c) 2013 Endika Gutiérrez Salas. All rights reserved.
//

#import "GSTerminalView.h"

@interface GSTerminalView ()

@property (nonatomic, weak) UIWebView *webView;

@end

@implementation GSTerminalView

- (id)init
{
    self = [super init];

    if (self) {
        UIWebView *webView = [[UIWebView alloc] initWithFrame:self.frame];
        webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        webView.delegate = self;
        [self addSubview:webView];
        self.webView = webView;
    }

    return self;
}

- (void)layoutSubviews
{
    self.webView.frame = self.frame;
}

#pragma mark - Web view delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([request.URL.scheme isEqualToString:@"objc-callback"]) {
        return NO;
    }

    return YES;
}

@end
