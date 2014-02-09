//
//  GSMasterViewController.m
//  Shell
//
//  Created by Endika Gutiérrez Salas on 12/26/13.
//  Copyright (c) 2013 Endika Gutiérrez Salas. All rights reserved.
//

#import "GSConnectionsTableController.h"

#import <ObjectiveRecord/ObjectiveRecord.h>
#import <TenzingCore/TenzingCore.h>
#import <AWSRuntime/AWSRuntime.h>
#import <AWSEC2/AWSEC2.h>
#import <UIAlertView+Blocks/UIAlertView+Blocks.h>

#import "UIButton+IonIcons.h"

#import "GSTableViewCell.h"
#import "GSProgressHUD.h"

#import "GSSSHTerminalViewController.h"
#import "GSHerokuTerminalViewController.h"
#import "GSAddSSHFormController.h"

#import "GSConnection.h"
#import "GSApplication.h"
#import "GSDyno.h"

#import "GSHerokuAccount.h"
#import "GSAWSCredentials.h"
#import "GSKeyPair.h"

#import "UIBarButtonItem+IonIcons.h"

#import "GSHerokuService.h"

#import "GSDatabaseManager.h"

NSString * const kGSConnectionsListUpdated = @"kGSConnectionsListUpdated";

@interface GSConnectionsTableController () {
    NSArray *_sections;
}
@end

@implementation GSConnectionsTableController

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];

    UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithIcon:icon_ios7_gear_outline
                                                                     target:self
                                                                     action:@selector(settingsAction:)];

    self.navigationItem.leftBarButtonItem = settingsButton;

    UIBarButtonItem *addConnectionButton = [[UIBarButtonItem alloc] initWithIcon:icon_ios7_plus_outline
                                                                          target:self
                                                                          action:@selector(addConnectionAction:)];

    self.navigationItem.rightBarButtonItem = addConnectionButton;



    self.detailViewController = (GSTerminalViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadConnections:) name:kGSConnectionsListUpdated object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLoggedIn:) name:kGSUserHasLogged object:nil];

    [self reloadConnections:nil];
}

- (void)userLoggedIn:(id)sender
{
    [self reloadConnections:sender];

    if (_sections.count == 0) {
        [self addConnectionAction:sender];
    }
}

- (void)reloadConnections:(id)sender
{
    NSMutableArray *sections = [NSMutableArray array];
    _sections = sections;

    // Add SSH connections
    NSArray *sshConnection = [GSConnection all];
    if (sshConnection.count) {
        [sections addObject:@{@"items": [sshConnection mutableCopy],
                              @"type": @"ssh",
                              @"title": @"SSH Connections"}];
    }

    // Add Heroku accounts
    NSArray *herokuAccounts = [GSHerokuAccount all];
    for (GSHerokuAccount *account in herokuAccounts) {
        NSMutableDictionary *section = [NSMutableDictionary dictionary];
        section[@"title"] = [NSString stringWithFormat:@"Heroku <%@>", account.email ?: @""];
        section[@"type"] = @"heroku";
        section[@"account"] = account;
        section[@"loading"] = @YES;

        [sections addObject:section];

        [account getApps:^(NSArray *apps, NSError *error) {
            if (apps.count) {
                section[@"items"] = apps;
                section[@"loading"] = @NO;
            } else {
                [sections removeObject:section];
            }
            [self reloadCells];
        }];

    }

    // Add AWS accounts
    NSArray *awsAccounts = [GSAWSCredentials all];
    for (GSAWSCredentials *credentials in awsAccounts) {

        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        [queue addOperationWithBlock:^{
            @try {
                AmazonEC2Client *client = credentials.client;
                EC2DescribeRegionsResponse *response = [client describeRegions:[[EC2DescribeRegionsRequest alloc] init]];

                for (EC2Region *region in response.regions) {


                    AmazonEC2Client *regionClient = [client copy];
                    regionClient.endpoint = [NSString stringWithFormat:@"https://%@", region.endpoint];

                    NSMutableArray *instances = [NSMutableArray array];

                    EC2DescribeInstancesResponse *response = [regionClient describeInstances:[[EC2DescribeInstancesRequest alloc] init]];

                    for (EC2Reservation *reservation in response.reservations) {
                        [instances addObjectsFromArray:reservation.instances];
                    }

                    if (instances.count) {
                        NSMutableDictionary *section = [NSMutableDictionary dictionary];
                        [sections addObject:section];

                        section[@"title"] = [NSString stringWithFormat:@"AWS EC2 %@ <%@>", region.regionName, credentials.accountName];
                        section[@"type"] = @"aws";
                        section[@"credentials"] = credentials;
                        section[@"client"] = regionClient;
                        section[@"items"] = instances;
                        section[@"loading"] = @NO;
                        [self reloadCells];
                    }
                }
            }
            @catch (NSException *exception) {
                NSLog(@"%@", exception);
            }
        }];
    }
    [self reloadCells];
}

- (void)reloadCells
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)newConnectionAction:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    UINavigationController *addServerNavigation = [storyboard instantiateViewControllerWithIdentifier:@"AddServerNavigation"];

    [self presentViewController:addServerNavigation animated:YES completion:nil];
}

- (void)settingsAction:(id)sender
{
    [self performSegueWithIdentifier:@"GSShowSettings" sender:self];
}

- (void)addConnectionAction:(id)sender
{
    [self performSegueWithIdentifier:@"GSAddConnectionSegue" sender:self];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDictionary *sectionInfo = _sections[section];
    if ([sectionInfo[@"loading"] boolValue]) {
        return 1;
    }
    NSArray *items = sectionInfo[@"items"];
    return items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *sectionInfo = _sections[indexPath.section];
    if ([sectionInfo[@"loading"] boolValue]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GSLoadingCell" forIndexPath:indexPath];
        return cell;
    }

    GSTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GSTableViewCell" forIndexPath:indexPath];
    [cell setCellHeight:64.0f];
    cell.containingTableView = tableView;
    cell.delegate = self;

    NSArray *items = sectionInfo[@"items"];
    NSString *sectionType = sectionInfo[@"type"];

    if ([sectionType isEqualToString:@"ssh"]) {
        GSConnection *connection = items[indexPath.row];
        cell.nameLabel.text = connection.name;
        cell.detailLabel.text = [NSString stringWithFormat:@"%@:%@", connection.host, connection.port];

        UIButton *removeButton = [UIButton buttonWithIcon:icon_ios7_trash_outline size:32];
        removeButton.backgroundColor = [UIColor redColor];
        UIButton *editButton = [UIButton buttonWithIcon:icon_ios7_compose_outline size:32];
        editButton.backgroundColor = [UIColor lightGrayColor];
        cell.rightUtilityButtons = @[removeButton, editButton];


    } else if ([sectionType isEqualToString:@"heroku"]) {
        GSApplication *application = items[indexPath.row];
        cell.nameLabel.text = application.name;
        cell.detailLabel.text = application.buildpack_provided_description;

        cell.rightUtilityButtons = nil;

    } else if ([sectionType isEqualToString:@"aws"]) {
        EC2Instance *instance = items[indexPath.row];
        EC2Tag *nameTag = [instance.tags find:^BOOL(EC2Tag *tag) { return [tag.key isEqualToString:@"Name"]; }];
        cell.nameLabel.text = nameTag.value;
        cell.detailLabel.text = instance.publicDnsName;

        UIButton *rebootButton = [UIButton buttonWithIcon:icon_ios7_refresh_outline size:32];
        rebootButton.backgroundColor = [UIColor lightGrayColor];
        cell.rightUtilityButtons = @[rebootButton];
    }

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSDictionary *sectionInfo = _sections[section];
    NSString *title = sectionInfo[@"title"];
    return [title uppercaseString];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        GSConnection *object = _connections[indexPath.row];
        self.detailViewController.connection = object;
    } else {
        [self performSegueWithIdentifier:@"showDetail" sender:indexPath];
    }
     */

    NSDictionary *sectionInfo = _sections[indexPath.section];

    NSArray *items = sectionInfo[@"items"];
    NSString *sectionType = sectionInfo[@"type"];

    if ([sectionType isEqualToString:@"ssh"]) {
        GSConnection *connection = items[indexPath.row];
        [self performSegueWithIdentifier:@"GSSSHConnection" sender:connection];

    } else if ([sectionType isEqualToString:@"heroku"]) {
        GSApplication *application = items[indexPath.row];
        GSHerokuAccount *account = sectionInfo[@"account"];
        [self performSegueWithIdentifier:@"GSHerokuConnection" sender:@{@"app": application,
                                                                        @"service": account.service}];

    } else if ([sectionType isEqualToString:@"aws"]) {
        EC2Instance *instance = items[indexPath.row];
        [self performSegueWithIdentifier:@"GSSSHConnection" sender:instance];
    }

}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSDictionary *sectionInfo = _sections[indexPath.section];

    NSMutableArray *items = sectionInfo[@"items"];
    NSString *sectionType = sectionInfo[@"type"];

    if ([sectionType isEqualToString:@"ssh"]) {
        if (index == 0) { // Remove button
            GSConnection *connection = items[indexPath.row];

            UIAlertView *confirmationAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Confirmation", @"Confirmation")
                                                                        message:NSLocalizedString(@"Are yo sure you want to remove connection?",
                                                                                                  @"Confirmation message")
                                                                       delegate:self
                                                              cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                                              otherButtonTitles:NSLocalizedString(@"Remove", @"Remove"), nil];

            confirmationAlert.tapBlock = ^(UIAlertView *alertView, NSInteger buttonIndex) {
                if (buttonIndex == 1) {
                    [self.tableView beginUpdates];
                    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
                    [items removeObject:connection];
                    [connection delete];
                    [self.tableView endUpdates];

                }
                [cell hideUtilityButtonsAnimated:YES];
            };
            [confirmationAlert show];

        } else if (index == 1) { // Edit button

        }

    } else if ([sectionType isEqualToString:@"heroku"]) {
        // Reboot button pressed
        [cell hideUtilityButtonsAnimated:YES];

    } else if ([sectionType isEqualToString:@"aws"]) {
        UIAlertView *confirmationAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Confirmation", @"Confirmation")
                                                                    message:NSLocalizedString(@"Are yo sure you want to reboot instance?",
                                                                                              @"Confirmation message")
                                                                   delegate:self
                                                          cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                                          otherButtonTitles:NSLocalizedString(@"Reboot", @"Reboot"), nil];

        confirmationAlert.tapBlock = ^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                [GSProgressHUD show:NSLocalizedString(@"Rebooting...", @"")];
                AmazonEC2Client *client = sectionInfo[@"client"];
                EC2Instance *instance = items[indexPath.row];
                @try {
                    [client rebootInstances:[[EC2RebootInstancesRequest alloc]
                                             initWithInstanceIds:[NSMutableArray arrayWithObject:instance.instanceId]]];
                }
                @catch (NSException *exception) {
                    NSLog(@"%@", exception);
                }
                [GSProgressHUD dismiss];
            }
            [cell hideUtilityButtonsAnimated:YES];
        };
        [confirmationAlert show];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)item
{
    if ([segue.identifier isEqualToString:@"GSSSHConnection"]) {
        GSSSHTerminalViewController *sshTerminalController = segue.destinationViewController;

        if ([item isKindOfClass:[EC2Instance class]]) {
            EC2Instance *instance = item;
            EC2Tag *nameTag = [instance.tags find:^BOOL(EC2Tag *tag) { return [tag.key isEqualToString:@"Name"]; }];

            sshTerminalController.title = nameTag.value;
            sshTerminalController.host = instance.publicDnsName;
            sshTerminalController.shouldUSeKeyPair = YES;
            sshTerminalController.keyPair = [[GSKeyPair all] find:^BOOL(GSKeyPair *keyPair) {
                return [keyPair.name isEqualToString:instance.keyName];
            }];

        } else /*if ([item isKindOfClass:[GSConnection class]])*/ {
            GSConnection *connection = item;

            sshTerminalController.title = connection.name;
            sshTerminalController.host = connection.host;
            sshTerminalController.port = connection.port;
            sshTerminalController.username = connection.username;
            sshTerminalController.keyPair = connection.keyPair;
            sshTerminalController.password = connection.savePassword.boolValue ? connection.password : nil;

        }

    } else if ([segue.identifier isEqualToString:@"GSHerokuConnection"]) {
        NSDictionary *params = item;

        [segue.destinationViewController setApplication:params[@"app"]];
        [segue.destinationViewController setHerokuService:params[@"service"]];

    }
}

@end
