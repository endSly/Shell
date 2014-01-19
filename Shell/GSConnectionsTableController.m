//
//  GSMasterViewController.m
//  Shell
//
//  Created by Endika Gutiérrez Salas on 12/26/13.
//  Copyright (c) 2013 Endika Gutiérrez Salas. All rights reserved.
//

#import "GSConnectionsTableController.h"

#import <QuickDialog/QuickDialog.h>
#import <ObjectiveRecord/ObjectiveRecord.h>
#import <TenzingCore/TenzingCore.h>
#import <OpenSSL/rsa.h>
#import <OpenSSL/pem.h>
#import <AWSRuntime/AWSRuntime.h>
#import <AWSEC2/AWSEC2.h>

#import "UIButton+IonIcons.h"

#import "GSTableViewCell.h"

#import "GSSSHTerminalViewController.h"
#import "GSHerokuTerminalViewController.h"
#import "GSAddSSHFormController.h"

#import "GSConnection.h"
#import "GSApplication.h"
#import "GSDyno.h"

#import "GSHerokuAccount.h"
#import "GSAWSCredentials.h"

#import "UIBarButtonItem+IonIcons.h"

#import "GSHerokuService.h"

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

    UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithIcon:icon_ios7_gear_outline
                                                                      color:[UIColor whiteColor]
                                                                     target:self
                                                                     action:@selector(settingsAction:)];

    self.navigationItem.leftBarButtonItem = settingsButton;

    self.detailViewController = (GSTerminalViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];

/*
    RSA *rsa = RSA_new();
    BIGNUM *e = BN_new();
    BN_set_word(e, 65537);
    int ret;

    ret = RSA_generate_key_ex(rsa, 2048, e, NULL);

    FILE *publicFile = fopen("/Users/endika/Desktop/rsa.pub", "w+");
    ret = PEM_write_RSAPublicKey(publicFile, rsa);
    fclose(publicFile);

    FILE *privateFile = fopen("/Users/endika/Desktop/rsa.pem", "w+");
    unsigned char *password = NULL;

    if (password != NULL)
        ret = PEM_write_RSAPrivateKey(privateFile, rsa, EVP_aes_256_cbc(), password, (int) strlen((char *) password), NULL, NULL);//use given password
    else
        ret = PEM_write_RSAPrivateKey(privateFile, rsa, NULL, NULL, 0, NULL, NULL);//use default passwd callback

    fclose(privateFile);

    BN_free(e);

    RSA_free(rsa);
*/

    NSMutableArray *sections = [NSMutableArray array];
    _sections = sections;

    // Add SSH connections
    NSArray *sshConnection = [GSConnection all];
    if (sshConnection.count) {
        [sections addObject:@{@"items": sshConnection,
                              @"type": @"ssh",
                              @"title": @"SSH Connections"}];
    }

    // Add Heroku accounts
    NSArray *herokuAccounts = [GSHerokuAccount all];
    for (GSHerokuAccount *account in herokuAccounts) {
        NSMutableDictionary *section = [NSMutableDictionary dictionary];
        section[@"title"] = [NSString stringWithFormat:@"Heroku <%@>", account.name];
        section[@"type"] = @"heroku";
        section[@"group"] = account;
        section[@"loading"] = @YES;

        [sections addObject:section];

        [account.service getApps:nil callback:^(NSArray *apps, NSURLResponse *resp, NSError *error) {
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
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    for (GSAWSCredentials *credentials in awsAccounts) {
        NSMutableDictionary *section = [NSMutableDictionary dictionary];

        NSMutableArray *instances = [NSMutableArray array];

        section[@"title"] = [NSString stringWithFormat:@"AWS EC2 <%@>", credentials.accountName];
        section[@"type"] = @"aws";
        section[@"group"] = credentials;
        section[@"loading"] = @YES;
        section[@"items"] = instances;

        [sections addObject:section];

        [queue addOperationWithBlock:^{
            AmazonEC2Client *client = credentials.client;
            EC2DescribeRegionsResponse *response = [client describeRegions:[[EC2DescribeRegionsRequest alloc] init]];

            for (EC2Region *region in response.regions) {
                AmazonEC2Client *regionClient = [client copy];
                regionClient.endpoint = [NSString stringWithFormat:@"https://%@", region.endpoint];

                EC2DescribeInstancesResponse *response = [regionClient describeInstances:[[EC2DescribeInstancesRequest alloc] init]];

                for (EC2Reservation *reservation in response.reservations) {
                    [instances addObjectsFromArray:reservation.instances];
                }
                [self reloadCells];
            }

            section[@"loading"] = @NO;
            [self reloadCells];
        }];
    }
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

}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDictionary *sectionInfo = _sections[section];
    NSArray *items = sectionInfo[@"items"];
    return items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GSTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GSTableViewCell" forIndexPath:indexPath];
    [cell setCellHeight:64.0f];
    cell.containingTableView = tableView;
    cell.delegate = self;

    NSDictionary *sectionInfo = _sections[indexPath.section];

    NSArray *items = sectionInfo[@"items"];
    NSString *sectionType = sectionInfo[@"type"];

    if ([sectionType isEqualToString:@"ssh"]) {
        GSConnection *connection = items[indexPath.row];
        cell.nameLabel.text = connection.name;
        cell.detailLabel.text = [NSString stringWithFormat:@"%@:%@", connection.host, connection.port];
        cell.removeButtonVisible = YES;
        cell.editButtonVisible = YES;
        cell.rebootButtonVisible = NO;

    } else if ([sectionType isEqualToString:@"heroku"]) {
        GSApplication *application = items[indexPath.row];
        cell.nameLabel.text = application.name;
        cell.detailLabel.text = application.buildpack_provided_description;
        cell.removeButtonVisible = NO;
        cell.editButtonVisible = NO;
        cell.rebootButtonVisible = YES;

    } else if ([sectionType isEqualToString:@"aws"]) {
        EC2Instance *instance = items[indexPath.row];
        EC2Tag *nameTag = [instance.tags find:^BOOL(EC2Tag *tag) { return [tag.key isEqualToString:@"Name"]; }];
        cell.nameLabel.text = nameTag.value;
        cell.detailLabel.text = instance.publicDnsName;
        cell.removeButtonVisible = NO;
        cell.editButtonVisible = NO;
        cell.rebootButtonVisible = YES;
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
/*
    switch (indexPath.section) {
        case 0: {
            [self performSegueWithIdentifier:@"GSSSHConnection" sender:_connections[indexPath.row]];
            break;
        }
        case 1: {
            GSHerokuAccount *account = _herokuAccounts[indexPath.section - 1];
            NSArray *apps = _herokuApps[account.user_id];
            [self performSegueWithIdentifier:@"GSHerokuConnection" sender:apps[indexPath.row]];
            break;
        }
    }
 */

}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    /*
    if (0 == UITableViewCellEditingStyleDelete) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        
        GSConnection *connection = _connections[indexPath.row];
        [connection delete];

        _connections = [_connections mutableCopy];
        [(NSMutableArray *) _connections removeObjectAtIndex:indexPath.row];

        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    }
     */
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)item
{
    if ([segue.identifier isEqualToString:@"GSSSHConnection"]) {
        [segue.destinationViewController setConnection:item];

    } else if ([segue.identifier isEqualToString:@"GSHerokuConnection"]) {
        [segue.destinationViewController setApplication:item];

        GSHerokuService *service = [GSHerokuService service];
        service.authKey = @"15ad8f9d-43ea-4e3a-8843-b2e29feba024";
        [segue.destinationViewController setHerokuService:service];

    }
}

@end
