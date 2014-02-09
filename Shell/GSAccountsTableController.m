//
//  GSAccountsTableController.m
//  Shell
//
//  Created by Endika Gutiérrez Salas on 2/2/14.
//  Copyright (c) 2014 Endika Gutiérrez Salas. All rights reserved.
//

#import "GSAccountsTableController.h"

#import <ObjectiveRecord/ObjectiveRecord.h>
#import "GSHerokuAccount.h"
#import "GSAWSCredentials.h"

#import <UIAlertView+Blocks/UIAlertView+Blocks.h>

#import "UIButton+IonIcons.h"

@implementation GSAccountsTableController {
    NSMutableArray *_herokuAccounts;
    NSMutableArray *_awsAccounts;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = NSLocalizedString(@"Accounts", @"Navigation title");

    _herokuAccounts = [[GSHerokuAccount all] mutableCopy];
    _awsAccounts = [[GSAWSCredentials all] mutableCopy];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return _herokuAccounts.count;
    }
    return _awsAccounts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    SWTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    [cell setCellHeight:44.0f];
    cell.containingTableView = tableView;
    cell.delegate = self;

    if (indexPath.section == 0) {
        GSHerokuAccount *account = _herokuAccounts[indexPath.row];
        cell.textLabel.text = account.email;

    } else if (indexPath.section == 1) {
        GSAWSCredentials *credentials = _awsAccounts[indexPath.row];
        cell.textLabel.text = credentials.accountName;
    }

    UIButton *removeButton = [UIButton buttonWithIcon:icon_ios7_trash_outline size:32];
    removeButton.backgroundColor = [UIColor redColor];
    cell.rightUtilityButtons = @[removeButton];

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"Heroku accounts";
    }
    return @"AWS Accounts";
}

#pragma mark - Swipeable cell delegate

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    UIAlertView *confirmationAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Confirmation", @"Confirmation alert title")
                                                                message:NSLocalizedString(@"Are you sure you want to delete account?", @"Confirmation message")
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                                      otherButtonTitles:NSLocalizedString(@"Delete", @"Delete"), nil];

    confirmationAlert.tapBlock = ^(UIAlertView *confirmationAlert, NSInteger buttonIndex) {
        if (buttonIndex == 0)
            return;

        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];

        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];

        if (indexPath.section == 0) {
            GSHerokuAccount *account = _herokuAccounts[indexPath.row];
            [account delete];
            [_herokuAccounts removeObject:account];

        } else if (indexPath.section == 1) {
            GSAWSCredentials *credentials = _awsAccounts[indexPath.row];
            [credentials delete];
            [_awsAccounts removeObject:credentials];
        }

        [self.tableView endUpdates];
    };

    [confirmationAlert show];

    [cell hideUtilityButtonsAnimated:YES];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
