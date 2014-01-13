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
#import <OpenSSL/rsa.h>
#import <OpenSSL/pem.h>

#import "UIButton+IonIcons.h"

#import "GSTableViewCell.h"

#import "GSSSHTerminalViewController.h"
#import "GSHerokuTerminalViewController.h"
#import "GSConnectionFormController.h"

#import "GSConnection.h"
#import "GSApplication.h"
#import "GSDyno.h"
#import "GSHerokuAccount.h"

#import "UIBarButtonItem+IonIcons.h"

#import "GSHerokuService.h"

@interface GSConnectionsTableController () {
    NSArray *_connections;

    NSArray *_herokuAccounts;
    NSMutableDictionary *_herokuApps;
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

    [self reloadConnections];
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

    _herokuApps = [NSMutableDictionary dictionary];
    _herokuAccounts = [GSHerokuAccount all];

    for (GSHerokuAccount *account in _herokuAccounts) {
        [account.service getApps:nil callback:^(NSArray *apps, NSURLResponse *resp, NSError *error) {
            _herokuApps[account.user_id] = apps;
            [self.tableView reloadData];
        }];
    }
}

- (void)reloadConnections
{
    _connections = [GSConnection all];

    [self.tableView reloadData];
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
/*
    GSConnection *newConnection = (GSConnection *) [GSConnection create];

    newConnection.port = @22;

    QRootElement *root = [[QRootElement alloc] initWithJSONFile:@"connection-form" andData:newConnection];

    QAppearance *defaultAppearance = [[QAppearance alloc] init];
    defaultAppearance.labelFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0];
    root.appearance = defaultAppearance;

    UINavigationController *navigation = [QuickDialogController controllerWithNavigationForRoot:root];

    navigation.navigationBar.titleTextAttributes =  @{NSForegroundColorAttributeName: [UIColor whiteColor],
                                                      NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:20.0]};

    navigation.navigationBar.tintColor = [UIColor whiteColor];
    navigation.navigationBar.barTintColor = [UIColor grayColor];

    GSConnectionFormController *formController = (GSConnectionFormController *) navigation.topViewController;
    formController.delegate = self;
    formController.connection = newConnection;

    [self presentViewController:navigation animated:YES completion:nil];
 */
}

- (void)settingsAction:(id)sender
{

}

#pragma mark - Connection Form Delegate

- (void)connectionForm:(GSConnectionFormController *)controller didSave:(GSConnection *)connection
{
    [connection save];

    [self reloadConnections];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1 + _herokuAccounts.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return _connections.count;
    } else /* if ... */ {
        GSHerokuAccount *account = _herokuAccounts[section - 1];
        NSArray *apps = _herokuApps[account.user_id];
        return apps.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GSTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GSTableViewCell" forIndexPath:indexPath];
    [cell setCellHeight:64.0f];
    cell.containingTableView = tableView;
    cell.delegate = self;

    if (indexPath.section == 0) {
        GSConnection *connection = _connections[indexPath.row];
        cell.nameLabel.text = connection.name;
        cell.detailLabel.text = [NSString stringWithFormat:@"%@:%@", connection.host, connection.port];

        UIButton *deleteButton = [UIButton buttonWithIcon:icon_ios7_trash_outline size:32];
        [deleteButton setTitle:icon_ios7_trash forState:UIControlStateHighlighted];
        deleteButton.backgroundColor = [UIColor redColor];

        UIButton *editButton = [UIButton buttonWithIcon:icon_ios7_compose_outline size:32];
        [editButton setTitle:icon_ios7_compose forState:UIControlStateHighlighted];
        editButton.backgroundColor = [UIColor lightGrayColor];

        cell.rightUtilityButtons = @[editButton, deleteButton];

    } else /* if ... */ {
        GSHerokuAccount *account = _herokuAccounts[indexPath.section - 1];
        NSArray *apps = _herokuApps[account.user_id];
        GSApplication *app = apps[indexPath.row];
        cell.nameLabel.text = app.name;
        cell.detailLabel.text = app.buildpack_provided_description;
    }

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return @"SSH CONNECTIONS";
        case 1:
            return @"HEROKU APPS";
    }
    return nil;
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

}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    if (0 == UITableViewCellEditingStyleDelete) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        
        GSConnection *connection = _connections[indexPath.row];
        [connection delete];

        _connections = [_connections mutableCopy];
        [(NSMutableArray *) _connections removeObjectAtIndex:indexPath.row];

        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    }
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
