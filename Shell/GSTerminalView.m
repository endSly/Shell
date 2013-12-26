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

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];

    if (self) {
        UIWebView *webView = [[UIWebView alloc] initWithFrame:self.frame];
        webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        webView.delegate = self;
        [self addSubview:webView];
        self.webView = webView;

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
    }
    
    return self;
}

- (void)layoutSubviews
{
    self.webView.frame = self.frame;

    NSURLRequest *terminalLoadRequest = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"terminal" ofType:@"html"] isDirectory:NO]];
    [self.webView loadRequest:terminalLoadRequest];
}

#pragma mark - Web view delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([request.URL.scheme isEqualToString:@"objc-callback"]) {
        return NO;
    }

    return YES;
}

#pragma mark - Remove keyboard

- (void)keyboardWillShow:(NSNotification *)note {
    [self performSelector:@selector(removeBar) withObject:nil afterDelay:0];
}
- (void)removeBar {
    // Locate non-UIWindow.
    UIWindow *keyboardWindow = nil;
    for (UIWindow *window in [[UIApplication sharedApplication] windows]) {
        if (![[window class] isEqual:[UIWindow class]]) {
            keyboardWindow = window;
            break;
        }
    }
    UIView *keyboardView = nil;

    // Locate UIWebFormView.
    for (UIView *formView in [keyboardWindow subviews]) {
        // iOS 5 sticks the UIWebFormView inside a UIPeripheralHostView.
        if ([[formView description] rangeOfString:@"UIPeripheralHostView"].location != NSNotFound) {
            keyboardView = formView;
            for (UIView *subView in [formView subviews]) {
                if ([subView.description rangeOfString:@"UIWebFormAccessory"].location != NSNotFound) {
                    // remove the input accessory view
                    [subView removeFromSuperview];
                }
            }
        }
    }

    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, keyboardWindow.frame.size.width, 44.0f)];
    toolbar.items = @[[[UIBarButtonItem alloc] initWithTitle:@"Tab" style:UIBarButtonItemStylePlain target:self action:@selector(test)]];
    [keyboardView addSubview:toolbar];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
