//
//  GSTerminalView.m
//  Shell
//
//  Created by Endika Gutiérrez Salas on 12/26/13.
//  Copyright (c) 2013 Endika Gutiérrez Salas. All rights reserved.
//

#import "GSTerminalView.h"

#import <FrameAccessor/FrameAccessor.h>

#import "UIBarButtonItem+IonIcons.h"

@interface GSTerminalView ()

@property (nonatomic, weak) UIWebView *webView;

@property (nonatomic, weak) UIButton *ctrlButton;

@property (nonatomic) BOOL isCtrlPressed;

@end

@implementation GSTerminalView {
    UIToolbar *_terminalToolbar;
}

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
    }
    
    return self;
}

- (void)layoutSubviews
{
    self.webView.frame = self.frame;
    NSURL *htmlURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"terminal" ofType:@"html"] isDirectory:NO];
    [self.webView loadRequest:[NSURLRequest requestWithURL:htmlURL]];
}

- (void)setFontSize:(NSUInteger)fontSize
{
    _fontSize = fontSize;

    NSString *js = [NSString stringWithFormat:@"document.getElementById('terminal').style.fontSize = \"%lupx\";", fontSize];
    [self.webView stringByEvaluatingJavaScriptFromString:js];
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
    });
}

- (void)setCols:(NSUInteger)cols rows:(NSUInteger)rows
{
    [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.term.resize(%lu, %lu);", cols, rows]];
}

- (void)getScreenCols:(NSUInteger *)cols rows:(NSUInteger *)rows
{
    NSString *sizeJSON = [self.webView stringByEvaluatingJavaScriptFromString:@"JSON.stringify(getSize());"];
    NSDictionary *size = [NSJSONSerialization JSONObjectWithData:[sizeJSON dataUsingEncoding:NSUTF8StringEncoding]
                                                         options:0
                                                           error:nil];

    *cols = [size[@"cols"] integerValue];
    *rows = [size[@"rows"] integerValue];
}

- (void)adjustSizeToScreen
{
    [self.webView stringByEvaluatingJavaScriptFromString:@"adjustToWindow();"];
}

- (void)toggleCtrl
{
    self.isCtrlPressed = !self.isCtrlPressed;

    if (self.isCtrlPressed) {
        self.ctrlButton.backgroundColor = [[UIApplication sharedApplication].delegate window].tintColor;
        [self.ctrlButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    } else {
        self.ctrlButton.backgroundColor = [UIColor clearColor];
        [self.ctrlButton setTitleColor:[[UIApplication sharedApplication].delegate window].tintColor forState:UIControlStateNormal];
    }
}

- (void)writeCtrlSequence:(NSString *)value
{
    // See http://en.wikipedia.org/wiki/C0_and_C1_control_codes
    unsigned char controlChar = [value.uppercaseString characterAtIndex:0];
    if (controlChar >= 64 && controlChar < 96) {
        [self.delegate terminalView:self didWrite:[NSString stringWithFormat:@"%c", controlChar - 64]];
    } else {
        [self.delegate terminalView:self didWrite:value];
    }
}

- (UIScrollView *)scrollView
{
    return self.webView.scrollView;
}

- (BOOL)resignFirstResponder
{
    return [self.webView endEditing:YES];
}

#pragma mark - Web view delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([request.URL.scheme isEqualToString:@"term-write"]) {
        NSString *data = [request.URL.fragment stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        if (self.isCtrlPressed) {
            [self toggleCtrl];
            [self writeCtrlSequence:data];
        } else {
            [self.delegate terminalView:self didWrite:data];
        }
        return NO;
    }

    if ([request.URL.scheme isEqualToString:@"term-title"]) {
        NSString *data = [request.URL.fragment stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        if ([self.delegate respondsToSelector:@selector(terminalView:didUpdateTitle:)])
            [self.delegate terminalView:self didUpdateTitle:data];
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
    [self.delegate terminalView:self didWrite:@"\e"];
}

- (void)ctrlTapAction:(UIButton *)button
{
    [self toggleCtrl];
}

- (void)upArrowAction:(id)sender
{
    [self.delegate terminalView:self didWrite:@"\e[A"];
}

- (void)downArrowAction:(id)sender
{
    [self.delegate terminalView:self didWrite:@"\e[B"];
}

- (void)rightArrowAction:(id)sender
{
    [self.delegate terminalView:self didWrite:@"\e[C"];
}

- (void)leftArrowAction:(id)sender
{
    [self.delegate terminalView:self didWrite:@"\e[D"];
}

#pragma mark - Keyboard accesory toolabar

- (void)showAccessoryToolbar
{
    self.webFormToolbar.hidden = YES;
    [self.keyboardView addSubview:self.terminalToolbar];
}

- (void)hideAccesoryToolbar
{
    self.webFormToolbar.hidden = NO;
    [self.terminalToolbar removeFromSuperview];
}

- (UIWindow *)keyboardWindow
{
    for (UIWindow *window in [UIApplication sharedApplication].windows) {
        if (![[window class] isEqual:[UIWindow class]]) {
            return window;
        }
    }
    return nil;
}

- (UIView *)keyboardView
{
    // Locate UIWebFormView.
    for (UIView *formView in [self.keyboardWindow subviews]) {
        // iOS 5 sticks the UIWebFormView inside a UIPeripheralHostView.
        if ([[formView description] rangeOfString:@"UIPeripheralHostView"].location != NSNotFound) {
            return formView;
        }
    }
    return nil;
}

- (UIView *)webFormToolbar
{
    // Locate UIWebFormView.
    for (UIView *subView in [self keyboardView].subviews) {
        if ([subView.description rangeOfString:@"UIWebFormAccessory"].location != NSNotFound) {
            // remove the input accessory view
            return subView;
        }
    }
    return nil;
}

- (UIToolbar *)terminalToolbar
{
    if (!_terminalToolbar) {
        UIButton *ctrlButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [ctrlButton addTarget:self action:@selector(ctrlTapAction:) forControlEvents:UIControlEventTouchUpInside];
        [ctrlButton sizeToFit];
        [ctrlButton setTitle:@"ctrl" forState:UIControlStateNormal];
        [ctrlButton setTitleColor:[[UIApplication sharedApplication].delegate window].tintColor forState:UIControlStateNormal];
        ctrlButton.layer.cornerRadius = 3;
        ctrlButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:18.0f];

        self.ctrlButton = ctrlButton;

        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.width, 44.0f)];
        toolbar.items = @[[[UIBarButtonItem alloc] initWithTitle:@"tab" style:UIBarButtonItemStylePlain target:self action:@selector(writeTab:)],
                          [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                          [[UIBarButtonItem alloc] initWithTitle:@"esc" style:UIBarButtonItemStylePlain target:self action:@selector(writeEsc:)],
                          [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                          [[UIBarButtonItem alloc] initWithCustomView:ctrlButton],
                          [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                          [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                          [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                          [[UIBarButtonItem alloc] initWithIcon:icon_ios7_arrow_thin_left  target:self action:@selector(leftArrowAction:)],
                          [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                          [[UIBarButtonItem alloc] initWithIcon:icon_ios7_arrow_thin_down  target:self action:@selector(downArrowAction:)],
                          [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                          [[UIBarButtonItem alloc] initWithIcon:icon_ios7_arrow_thin_up    target:self action:@selector(upArrowAction:)],
                          [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                          [[UIBarButtonItem alloc] initWithIcon:icon_ios7_arrow_thin_right target:self action:@selector(rightArrowAction:)],
                          ];
        toolbar.backgroundColor = [UIColor clearColor];
        _terminalToolbar = toolbar;
    }
    return _terminalToolbar;
}

@end
