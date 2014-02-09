//
//  GSKeyPairsFormController.m
//  Shell
//
//  Created by Endika Gutiérrez Salas on 1/25/14.
//  Copyright (c) 2014 Endika Gutiérrez Salas. All rights reserved.
//

#import "GSKeyPairsTableController.h"

#import <UIAlertView+Blocks/UIAlertView+Blocks.h>
#import <UIActionSheet+Blocks/UIActionSheet+Blocks.h>
#import <ObjectiveRecord/ObjectiveRecord.h>
#import "GSKeyPair.h"

#import "GSKeyPairCell.h"

#import "GSProgressHUD.h"

#import "UIBarButtonItem+IonIcons.h"
#import "UIButton+IonIcons.h"

@interface GSKeyPairsTableController ()

@property (nonatomic, strong) NSMutableArray * keyPairs;

@end

@implementation GSKeyPairsTableController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];

    self.title = NSLocalizedString(@"SSH keys", @"SSH keys table title");
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithIcon:icon_ios7_plus_outline
                                                                            target:self
                                                                            action:@selector(addKeyPairAction:)];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.keyPairs = [[GSKeyPair all] mutableCopy];

    [self.tableView reloadData];
}

- (void)addKeyPairAction:(id)sender
{
    [self performSegueWithIdentifier:@"GSAddKeyPairSegue" sender:self];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.keyPairs.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return NSLocalizedString(@"My SSH keys", @"My SSH keys");
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GSKeyPairCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];

    [cell setCellHeight:44.0f];
    cell.containingTableView = tableView;
    cell.delegate = self;

    GSKeyPair *keyPair = self.keyPairs[indexPath.row];
    cell.textLabel.text = keyPair.name;
    cell.passwordIcon.hidden = !keyPair.hasPassword.boolValue;

    UIButton *removeButton = [UIButton buttonWithIcon:icon_ios7_trash_outline size:32];
    removeButton.backgroundColor = [UIColor redColor];
    cell.rightUtilityButtons = @[removeButton];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    GSKeyPair *keyPair = self.keyPairs[indexPath.row];

    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:keyPair.name
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:NSLocalizedString(@"Copy public key", @"Sheet action"), NSLocalizedString(@"Copy private key", @"Sheet action"), NSLocalizedString(@"Send by mail", @"Sheet action"), nil];

    sheet.tapBlock = ^(UIActionSheet *actionSheet, NSInteger index) {
        switch (index) {
            case 0: {
                // Copy public key
                NSError *error;
                NSString *keyfile = [NSString stringWithContentsOfFile:keyPair.publicKeyPath
                                                              encoding:NSUTF8StringEncoding
                                                                 error:&error];

                [[UIPasteboard generalPasteboard] setString:keyfile];

                [GSProgressHUD showSuccess:NSLocalizedString(@"Copied", @"Copied")];
                break;
            }
            case 1: {
                // Copy private key
                NSError *error;
                NSString *keyfile = [NSString stringWithContentsOfFile:keyPair.privateKeyPath
                                                              encoding:NSUTF8StringEncoding
                                                                 error:&error];

                [[UIPasteboard generalPasteboard] setString:keyfile];

                [GSProgressHUD showSuccess:NSLocalizedString(@"Copied", @"Copied")];

                break;
            }
            case 2: {
                // Send by email
                MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];

                [controller setSubject:keyPair.name];
                controller.mailComposeDelegate = self;

                [controller addAttachmentData:[NSData dataWithContentsOfFile:keyPair.privateKeyPath]
                                     mimeType:@"application/x-pem-file"
                                     fileName:[NSString stringWithFormat:@"%@.pem", keyPair.name]];

                [self presentViewController:controller animated:YES completion:nil];

                break;
            }
            case 3:
                // Cancel button
                break;
        }
    };

    [sheet showInView:self.view];
}

#pragma mark - Mail compose delegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Cell delegate

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    UIAlertView *confirmationAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Confirmation", @"Confirmation alert title")
                                                                message:NSLocalizedString(@"Are you sure you want to delete key pair?", @"Confirmation message")
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                                      otherButtonTitles:NSLocalizedString(@"Delete", @"Delete"), nil];

    confirmationAlert.tapBlock = ^(UIAlertView *confirmationAlert, NSInteger buttonIndex) {
        if (buttonIndex == 0)
            return;

        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];

        GSKeyPair *keyPair = self.keyPairs[indexPath.row];

        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        [self.keyPairs removeObject:keyPair];
        [keyPair delete];
        [self.tableView endUpdates];
    };

    [confirmationAlert show];

    [cell hideUtilityButtonsAnimated:YES];
}

@end
