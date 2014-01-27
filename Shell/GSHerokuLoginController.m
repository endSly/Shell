//
//  GSHerokuLoginController.m
//  Shell
//
//  Created by Endika Gutiérrez Salas on 1/12/14.
//  Copyright (c) 2014 Endika Gutiérrez Salas. All rights reserved.
//

#import "GSHerokuLoginController.h"

#import <ObjectiveRecord/ObjectiveRecord.h>
#import <TenzingCore/TenzingCore.h>
#import <TenzingCore/TenzingCore-RESTService.h>

#import "GSHerokuService.h"
#import "GSHerokuAccount.h"
#import "GSHerokuOAuth.h"

#import "GSProgressHUD.h"

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
    [GSProgressHUD show:nil];

    [[GSHerokuOAuth sharedInstance] loginWithAuthToken:code callback:^(NSDictionary *accountDict) {

        GSHerokuAccount *account = [GSHerokuAccount findOrCreate:@{@"userId": accountDict[@"user_id"]}];
        [account update:accountDict];

        [account.service getAccount:nil callback:^(id accountInfo, NSURLResponse *resp, NSError *error) {
            [account update:accountInfo];
            [account save];

            [[NSNotificationCenter defaultCenter] postNotificationName:kGSConnectionsListUpdated object:nil];

            dispatch_async(dispatch_get_main_queue(), ^{
                [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
                [GSProgressHUD dismiss];
            });
        }];

    }];
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

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [GSProgressHUD show:nil];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [GSProgressHUD dismiss];
}

@end
