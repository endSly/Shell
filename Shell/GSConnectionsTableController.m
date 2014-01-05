//
//  GSMasterViewController.m
//  Shell
//
//  Created by Endika Gutiérrez Salas on 12/26/13.
//  Copyright (c) 2013 Endika Gutiérrez Salas. All rights reserved.
//

#import "GSConnectionsTableController.h"

#import <QuickDialog/QuickDialog.h>

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
    //self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:85.0/255.0 green:143.0/255.0 blue:220.0/255.0 alpha:1.0];
    //self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:18.0/255.0 green:60.0/255.0 blue:132.0/255.0 alpha:1.0];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:52.0/255.0 green:102.0/255.0 blue:176.0/255.0 alpha:1.0];

    [self reloadConnections];
}

- (void)reloadConnections
{
    NSFNanoSearch *search = [NSFNanoSearch searchWithStore:self.nanoStore];
    _connections = ((NSDictionary *) [search searchObjectsWithReturnType:NSFReturnObjects error:nil]).allValues;

    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)newConnectionAction:(id)sender
{
    GSConnection *newConnection = (GSConnection *) [GSConnection nanoObject];

    newConnection.port = @22;

    QRootElement *root = [[QRootElement alloc] initWithJSONFile:@"connection-form" andData:newConnection];

    QAppearance *defaultAppearance = [[QAppearance alloc] init];
    defaultAppearance.labelFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0];
    root.appearance = defaultAppearance;

    UINavigationController *navigation = [QuickDialogController controllerWithNavigationForRoot:root];

    navigation.navigationBar.titleTextAttributes =  @{NSForegroundColorAttributeName: [UIColor whiteColor],
                                                      NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:24.0]};

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
    [self.nanoStore addObject:connection error:nil];

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
    cell.textLabel.text = [connection objectForKey:@"name"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@:%@", [connection objectForKey:@"host"], [connection objectForKey:@"port"]];

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        GSConnection *connection = _connections[indexPath.row];
        [self.nanoStore removeObject:connection error:nil];

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
