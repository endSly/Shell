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
        webView.scrollView.bounces = NO;
        webView.dataDetectorTypes = UIDataDetectorTypeNone;
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
    NSURL *htmlURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"terminal" ofType:@"html"] isDirectory:NO];
    [self.webView loadRequest:[NSURLRequest requestWithURL:htmlURL]];
}

- (void)terminalWrite:(NSString *)data
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *string = data;
        string = [string stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
        string = [string stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
        string = [string stringByReplacingOccurrencesOfString:@"\'" withString:@"\\\'"];
        string = [string stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
        string = [string stringByReplacingOccurrencesOfString:@"\r" withString:@"\\r"];
        string = [string stringByReplacingOccurrencesOfString:@"\f" withString:@"\\f"];

        [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.term.write(\"%@\");", string]];

        NSLog(@"--------------\n%@", string);
    });

}

- (void)setCols:(NSUInteger)cols rows:(NSUInteger)rows
{
    [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.term.resize(%lu, %lu);", cols, rows]];
}

- (void)getScreenCols:(NSUInteger *)cols rows:(NSUInteger *)rows
{
    NSString *sizeJSON = [self.webView stringByEvaluatingJavaScriptFromString:@"JSON.stringify(getSize());"];
    NSDictionary *size = [NSJSONSerialization JSONObjectWithData:[sizeJSON dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];

    *cols = [size[@"cols"] integerValue];
    *rows = [size[@"rows"] integerValue];
}

- (void)adjustSizeToScreen
{
    [self.webView stringByEvaluatingJavaScriptFromString:@"adjustToWindow();"];
}

#pragma mark - Web view delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([request.URL.scheme isEqualToString:@"term-write"]) {
        NSString *data = [request.URL.fragment stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [self.delegate terminalView:self didWrite:data];
        return NO;
    }

    if ([request.URL.scheme isEqualToString:@"term-title"]) {
        NSString *data = [request.URL.fragment stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [self.delegate terminalView:self didWrite:data];
        return NO;
    }

    if ([request.URL.scheme isEqualToString:@"term-resize"]) {
        [self.delegate terminalViewDidResize:self];

        return NO;
    }

    if ([request.URL.scheme isEqualToString:@"term-will-appear"]) {

        return NO;
    }

    if ([request.URL.scheme isEqualToString:@"term-did-appear"]) {
        [self.delegate terminalViewDidLoad:self];
        return NO;
    }

    return YES;
}

- (void)writeTab:(id)sender
{
    [self.delegate terminalView:self didWrite:@"\t"];
}

- (void)writeEsc:(id)sender
{
    [self.delegate terminalView:self didWrite:@"^]"];
}

- (void)ctrlTapAction:(UIBarButtonItem *)button
{
    [button setTitleTextAttributes:@{NSForegroundColorAttributeName:[[[[UIApplication sharedApplication] delegate] window] tintColor]}
                          forState:UIControlStateNormal];
}

#pragma mark - Remove keyboard

- (void)keyboardWillShow:(NSNotification *)note
{
    [self performSelector:@selector(removeBar) withObject:nil afterDelay:0];
}
- (void)removeBar
{
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
    toolbar.items = @[[[UIBarButtonItem alloc] initWithTitle:@"tab" style:UIBarButtonItemStylePlain target:self action:@selector(writeTab:)],
                      [[UIBarButtonItem alloc] initWithTitle:@"esc" style:UIBarButtonItemStylePlain target:self action:@selector(writeEsc:)],
                      [[UIBarButtonItem alloc] initWithTitle:@"ctrl" style:UIBarButtonItemStylePlain target:self action:@selector(ctrlTapAction:)],
                      ];
    [keyboardView addSubview:toolbar];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
