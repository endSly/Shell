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

#import "GSProgressHUD.h"

@implementation GSProgressHUD {
    BOOL _visible;
}

@synthesize window, spinner, iconLabel, label;

+ (instancetype)shared
{
	static dispatch_once_t once = 0;
	static GSProgressHUD *progressHUD;

    dispatch_once(&once, ^{ progressHUD = [[self alloc] init]; });

    return progressHUD;
}

+ (void)dismiss
{
	[[self shared] dismiss];
}

+ (void)show:(NSString *)status
{
	[[self shared] show:status];
}

+ (void)showSuccess:(NSString *)status
{
	[[self shared] showSuccess:status];
}

+ (void)showError:(NSString *)status
{
	[[self shared] showError:status];
}

+ (void)show:(NSString *)status icon:(NSString *)icon spin:(BOOL)spin hide:(BOOL)hide
{
    [[self shared] show:status icon:icon spin:spin hide:hide];
}

- (void)dismiss
{
	[self hudHide];
}

- (void)show:(NSString *)status
{
	[self show:status icon:nil spin:YES hide:NO];
}

- (void)showSuccess:(NSString *)status
{
	[self show:status icon:HUD_SUCCESS_ICON spin:NO hide:YES];
}

- (void)showError:(NSString *)status
{
	[self show:status icon:HUD_ERROR_ICON spin:NO hide:YES];
}

- (id)init
{
	self = [self initWithFrame:[[UIScreen mainScreen] bounds]];
    id<UIApplicationDelegate> delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate respondsToSelector:@selector(window)])
        window = [delegate performSelector:@selector(window)];
	else
        window = [[UIApplication sharedApplication] keyWindow];

    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

    if (self) {
        self.barTintColor = HUD_BACKGROUND_COLOR;

		self.translucent = YES;
		self.layer.cornerRadius = 10;
		self.layer.masksToBounds = YES;
        
        self.layer.opacity = 0;
    }
    return self;
}

- (void)show:(NSString *)status icon:(NSString *)icon spin:(BOOL)spin hide:(BOOL)hide
{
	[self hudCreate];
    label.text = status;
	label.hidden = !(status);

    iconLabel.text = icon;
	iconLabel.hidden = !(icon);

    if (spin)
        [spinner startAnimating];
    else
        [spinner stopAnimating];

    [self hudOrient];
	[self hudSize];
	[self hudShow];

    if (hide)
        [NSThread detachNewThreadSelector:@selector(timedHide) toTarget:self withObject:nil];
}

- (void)hudCreate
{
	if (self.superview == nil)
        [window addSubview:self];

    if (spinner == nil) {
		spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		spinner.color = HUD_SPINNER_COLOR;
		spinner.hidesWhenStopped = YES;
	}
	if (spinner.superview == nil)
        [self addSubview:spinner];

    if (iconLabel == nil) {
		iconLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        iconLabel.textAlignment = NSTextAlignmentCenter;
        iconLabel.font = [UIFont iconicFontOfSize:36];
    }

	if (iconLabel.superview == nil)
        [self addSubview:iconLabel];

    if (label == nil) {
		label = [[UILabel alloc] initWithFrame:CGRectZero];
		label.font = HUD_STATUS_FONT;
		label.textColor = HUD_STATUS_COLOR;
		label.backgroundColor = [UIColor clearColor];
		label.textAlignment = NSTextAlignmentCenter;
		label.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
		label.numberOfLines = 0;
	}
	if (label.superview == nil) [self addSubview:label];
}

- (void)hudDestroy
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [label removeFromSuperview];	label = nil;
	[iconLabel removeFromSuperview]; iconLabel = nil;
	[spinner removeFromSuperview];	spinner = nil;
}

- (void)rotate:(NSNotification *)notification
{
	[self hudOrient];
}

- (void)hudOrient
{
	CGFloat rotate;
    UIInterfaceOrientation orient = [[UIApplication sharedApplication] statusBarOrientation];
    if (orient == UIInterfaceOrientationPortrait)			rotate = 0.0;
	if (orient == UIInterfaceOrientationPortraitUpsideDown)	rotate = M_PI;
	if (orient == UIInterfaceOrientationLandscapeLeft)		rotate = - M_PI_2;
	if (orient == UIInterfaceOrientationLandscapeRight)		rotate = + M_PI_2;
    self.transform = CGAffineTransformMakeRotation(rotate);
}

- (void)hudSize
{
	CGRect labelRect = CGRectZero;
	CGFloat hudWidth = 100, hudHeight = 100;

    if (label.text != nil)
	{
		NSDictionary *attributes = @{NSFontAttributeName:label.font};
		NSInteger options = NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin;
		labelRect = [label.text boundingRectWithSize:CGSizeMake(200, 300) options:options attributes:attributes context:NULL];
       
		labelRect.origin.x = 12;
		labelRect.origin.y = 66;

		hudWidth = labelRect.size.width + 24;
		hudHeight = labelRect.size.height + 80;

		if (hudWidth < 100)
		{
			hudWidth = 100;
			labelRect.origin.x = 0;
			labelRect.size.width = 100;
		}
	}
    
    
	    CGSize superviewSize;
    if (self.superview) {
        superviewSize = self.superview.bounds.size;
    } else {
        superviewSize = [UIScreen mainScreen].bounds.size;
    }

    self.center = CGPointMake(superviewSize.width/2, superviewSize.height/2);
	self.bounds = CGRectMake(0, 0, hudWidth, hudHeight);

    CGFloat imagex = hudWidth/2;
	CGFloat imagey = (label.text == nil) ? hudHeight/2 : 36;
	iconLabel.center = spinner.center = CGPointMake(imagex, imagey);
    label.frame = labelRect;
}

- (void)hudShow
{
	if (!_visible) {
        _visible = YES;

		self.layer.opacity = 0;
		self.transform = CGAffineTransformScale(self.transform, 1.4, 1.4);

		NSUInteger options = UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveEaseOut;

		[UIView animateWithDuration:0.15 delay:0 options:options animations:^{
			self.transform = CGAffineTransformScale(self.transform, 1/1.4, 1/1.4);
			self.layer.opacity = .8;
		}
		completion:nil];
	}
}

- (void)hudHide
{
	if (_visible) {
        _visible = NO;
        
		NSUInteger options = UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveEaseIn;

		[UIView animateWithDuration:0.15 delay:0 options:options animations:^{
			self.transform = CGAffineTransformScale(self.transform, 0.7, 0.7);
			self.layer.opacity = 0;

		} completion:^(BOOL finished) {
			[self hudDestroy];
			self.layer.opacity = 0;
		}];
	}
}

- (void)timedHide
{
	@autoreleasepool
	{
		double length = label.text.length;
		NSTimeInterval sleep = length * 0.04 + 0.5;
		
		[NSThread sleepForTimeInterval:sleep];
		[self hudHide];
	}
}

@end
