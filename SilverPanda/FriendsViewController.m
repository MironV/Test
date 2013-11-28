//
//  FriendsViewController.m
//  SilverPanda
//
//  Created by Miron Vranjes on 11/16/13.
//  Copyright (c) 2013 Miron Vranjes. All rights reserved.
//

#import "FriendsViewController.h"
#import "Friend.h"

@interface FriendsViewController ()

@end

@implementation FriendsViewController

@synthesize friends;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    
    return self;
}

- (void)reloadTable:(NSNotification *)notif {
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadTable:)
                                                 name:@"UpdateFriends"
                                               object:nil];
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    
    [refresh setTintColor:[UIColor colorWithRed:0.000 green:0.100 blue:0.830 alpha:1.000]];
    
//    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    
    
    [refresh addTarget:self action:@selector(refreshData)
      forControlEvents:UIControlEventValueChanged];
    
    self.refreshControl = refresh;

    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)refreshData
{
    RKObjectMapping* friendMapping = [RKObjectMapping mappingForClass:[Friend class]];
    [friendMapping addAttributeMappingsFromArray:@[@"first", @"last"]];
    
    NSLog(@"Refreshing!!!!");
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:friendMapping method:RKRequestMethodGET pathPattern:nil keyPath:@"users" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    NSURL *URL = [NSURL URLWithString:@"http://silverpanda.herokuapp.com/userlist"];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    RKObjectRequestOperation *objectRequestOperation = [[RKObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[ responseDescriptor ]];
    [objectRequestOperation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        self.friends = [mappingResult.array mutableCopy];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateFriends"
                                                            object:nil];
        RKLogInfo(@"Load collection of Friends: %@", mappingResult.array);
        [self stopRefresh];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        RKLogError(@"Operation failed with error: %@", error);
    }];
    
    [objectRequestOperation start];
}

- (void)stopRefresh

{
    [self.refreshControl endRefreshing];
}

- (void)viewDidUnload
{
[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    	return [self.friends count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FriendCell"];
	Friend *friend = [self.friends objectAtIndex:indexPath.row];
	cell.textLabel.text = friend.first;
	cell.detailTextLabel.text = friend.last;
    return cell;
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
