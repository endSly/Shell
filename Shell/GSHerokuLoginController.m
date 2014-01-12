//
//  GSHerokuLoginController.m
//  Shell
//
//  Created by Endika Gutiérrez Salas on 1/12/14.
//  Copyright (c) 2014 Endika Gutiérrez Salas. All rights reserved.
//

#import "GSHerokuLoginController.h"

#import <TenzingCore/TenzingCore.h>
#import <TenzingCore/TenzingCore-RESTService.h>

static NSString * const kGSHerokuClientId = @"c07e2cb2-9ec6-4330-a846-d89e1398eaa4";
static NSString * const kGSHerokuClientSecret = @"53b4e5ae-6bd2-4fdd-9d36-e30398324424";
static NSString * const kGSHerokuCallbackHost = @"heroku-oauth-cb.local";

@interface GSHerokuLoginController ()

@end

@implementation GSHerokuLoginController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Heroku";

    self.webView.delegate = self;

    NSString *url = [NSString stringWithFormat:@"https://id.heroku.com/oauth/authorize?client_id=%@&response_type=code&scope=global&state=token", kGSHerokuClientId];
    NSURL *requestURL = [NSURL URLWithString:url];
    [self.webView loadRequest:[NSURLRequest requestWithURL:requestURL]];
}

- (void)loginWithCode:(NSString *)code
{
    NSDictionary *params = @{@"grant_type": @"authorization_code",
                             @"code": code,
                             @"client_secret": kGSHerokuClientSecret};
}

#pragma mark - Web view delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([request.URL.host isEqualToString:kGSHerokuCallbackHost]) {
        NSDictionary *query = [NSDictionary dictionaryWithQueryString:request.URL.query];
        NSString *code = query[@"code"];
        [self loginWithCode:code];
        return NO;
    }
    return YES;
}

@end
