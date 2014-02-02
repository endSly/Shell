//
//  GSKeyPairsFormController.m
//  Shell
//
//  Created by Endika Gutiérrez Salas on 1/25/14.
//  Copyright (c) 2014 Endika Gutiérrez Salas. All rights reserved.
//

#import "GSKeyPairsTableController.h"

#import <UIAlertView+Blocks/UIAlertView+Blocks.h>
#import <ObjectiveRecord/ObjectiveRecord.h>
#import "GSKeyPair.h"

#import "GSKeyPairCell.h"

#import "UIBarButtonItem+IonIcons.h"
#import "UIButton+IonIcons.h"

@interface GSKeyPairsTableController ()

@property (nonatomic, strong) NSMutableArray * keyPairs;

@end

@implementation GSKeyPairsTableController

- (void)viewDidLoad
{
    [super viewDidLoad];

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
