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

#import "GSTerminalViewController.h"
#import "GSConnectionFormController.h"

#import "GSConnection.h"

#import "UIBarButtonItem+IonIcons.h"

@interface GSConnectionsTableController () {
    NSArray *_connections;
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
    
	// Do any additional setup after loading the view, typically from a nib.
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithIcon:icon_ios7_plus_outline
                                                                 color:[UIColor whiteColor]
                                                                target:self
                                                                action:@selector(newConnectionAction:)];

    UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithIcon:icon_ios7_gear_outline
                                                                      color:[UIColor whiteColor]
                                                                     target:self
                                                                     action:@selector(settingsAction:)];

    self.navigationItem.rightBarButtonItem = addButton;
    self.navigationItem.leftBarButtonItem = settingsButton;

    self.detailViewController = (GSTerminalViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];

    self.navigationController.navigationBar.titleTextAttributes =  @{NSForegroundColorAttributeName: [UIColor whiteColor],
                                                                     NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:20.0]};

    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:52.0/255.0 green:102.0/255.0 blue:176.0/255.0 alpha:1.0];
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
    [self reloadConnections];
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _connections.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    GSConnection *connection = _connections[indexPath.row];
    cell.textLabel.text = connection.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@:%@", connection.host, connection.port];

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return @"SSH CONNECTIONS";
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        GSConnection *connection = _connections[indexPath.row];
        [connection delete];

        _connections = [_connections mutableCopy];
        [(NSMutableArray *) _connections removeObjectAtIndex:indexPath.row];

        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        GSConnection *object = _connections[indexPath.row];
        self.detailViewController.connection = object;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        GSConnection *object = _connections[indexPath.row];
        [[segue destinationViewController] setConnection:object];
    }
}

@end
