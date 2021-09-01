#import "NBPRootTableViewController.h"
#import <Cephei/HBPreferences.h>

@interface NBPRootTableViewController ()
@property NSMutableArray *filterList;
@end

@implementation NBPRootTableViewController

- (void)loadView {
    [super loadView];
    [self load];

    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"com.greg0109.forwardnotifierprefs"];
    [defaults setInteger:5 forKey:@"filters"];

    if(self.filterList == nil) {
        self.filterList = [[NSMutableArray alloc] init];
    }
    self.title = @"Notification Filters";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonTapped:)];
}

- (void)addButtonTapped:(id)sender {
    NBPAddViewController *one = [[NBPAddViewController alloc] init];
    one.delegate = self;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:one];
    if(@available(iOS 13.0, *)) {
        navController.modalInPresentation = YES;
    }

    [self presentViewController:navController animated:YES completion:nil];
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filterList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    cell.textLabel.text = ((FNNotificationFilter *)self.filterList[indexPath.row]).filterName;
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.filterList removeObjectAtIndex:indexPath.row];
    [tableView deleteRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self save];
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NBPAddViewController *one = [[NBPAddViewController alloc] init];
    one.delegate = self;
    one.currentFilter = [self.filterList objectAtIndex:indexPath.row];

    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:one];
    if(@available(iOS 13.0, *)) {
        navController.modalInPresentation = YES;
    }

    [self presentViewController:navController animated:YES completion:nil];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)save {
    NSMutableArray *dictFilterarray = [[NSMutableArray alloc] init];
    for(FNNotificationFilter *filter in self.filterList) {
        [dictFilterarray addObject:[filter encodeToDictionary]];
    }
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dictFilterarray];
    NSString *path = @"/User/Library/Preferences/com.greg0109.forwardnotifierprefs.plist";
    NSMutableDictionary *settings = [NSMutableDictionary dictionary];
    [settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:path]];
    [settings setObject:data forKey:@"filter_array"];
    [settings writeToFile:path atomically:YES];
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (__bridge CFStringRef) @"com.greg0109.forwardnotifierprefs.settingschanged", NULL, NULL, YES);
}

- (void)load {
    NSString *path = @"/User/Library/Preferences/com.greg0109.forwardnotifierprefs.plist";
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:path];
    NSData *data = [prefs objectForKey:@"filter_array"];
    NSArray *dictFilterarray = (NSArray *)[NSKeyedUnarchiver unarchiveObjectWithData:data];

    self.filterList = [[NSMutableArray alloc] init];
    for(NSDictionary *dict in dictFilterarray) {
        [self.filterList addObject:[[FNNotificationFilter alloc] initWithDictionary:dict]];
    }
}

//just save everything check if in array and if so replace otherwise add at end
- (void)newFilter:(FNNotificationFilter *)filter {
    if(![self.filterList containsObject:filter]) {
        [self.filterList addObject:filter];
        [self.tableView insertRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:self.filterList.count - 1 inSection:0] ] withRowAnimation:UITableViewRowAnimationAutomatic];
    } else {
        [self.tableView reloadData];
    }
    [self save];
}

@end
