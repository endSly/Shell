//
// Copyright (c) 2013 Related Code - http://relatedcode.com
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "UIFont+IonIcons.h"

#define HUD_STATUS_FONT         [UIFont fontWithName:@"HelveticaNeue" size:13.0f]
#define HUD_STATUS_COLOR        [UIColor blackColor]
#define HUD_SPINNER_COLOR       [UIColor blackColor]
#define HUD_BACKGROUND_COLOR    [UIColor colorWithWhite:0.85 alpha:0.85]
#define HUD_SUCCESS_ICON        icon_ios7_checkmark
#define HUD_ERROR_ICON          icon_ios7_close

@interface GSProgressHUD : UIToolbar

+ (instancetype)shared;

+ (void)dismiss;
+ (void)show:(NSString *)status;
+ (void)showSuccess:(NSString *)status;
+ (void)showError:(NSString *)status;
+ (void)show:(NSString *)status icon:(NSString *)icon spin:(BOOL)spin hide:(BOOL)hide;

@property (atomic, strong) UIWindow *window;
@property (atomic, strong) UIActivityIndicatorView *spinner;
@property (atomic, strong) UILabel *iconLabel;
@property (atomic, strong) UILabel *label;

- (void)dismiss;
- (void)show:(NSString *)status;
- (void)showSuccess:(NSString *)status;
- (void)showError:(NSString *)status;
- (void)show:(NSString *)status icon:(NSString *)icon spin:(BOOL)spin hide:(BOOL)hide;

@end
