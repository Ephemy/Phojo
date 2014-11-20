//
//  UserListViewController.m
//  Phojo
//
//  Created by Mobile Making on 11/17/14.
//  Copyright (c) 2014 Jonathan Chou. All rights reserved.
//

#import "JVAUserListViewController.h"
#import "JVAProfileViewController.h"
#import "Phojer.h"

@interface JVAUserListViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UITabBarControllerDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@property Phojer *currentPhojer;
@property NSMutableArray *phojers;
@property NSArray *phojersFollowed;

@end

@implementation JVAUserListViewController


/*
 If this scene is presented from the search tab, it should toggle between collection view for searching tags and list view for searching users.
 If it is presented from tapping on a user's followers, it should only show the list view, and hide search bar.
 Tapping on a table cell should take you to the users profile page.
 Tapping on a collection view cell should take you to single post detail view (feed scene).
 */

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);

    self.tabBarController.delegate = self;

    self.currentPhojer = [[PFUser currentUser] objectForKey:@"phojer"];

    // query for phojers current phojer is following
    if (self.showFollowing)
    {

        PFRelation *following = [self.passedPhojer relationForKey:@"following"];
        PFQuery *followingQuery = [following query];

        [followingQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {

            if (error)
            {
                //TODO: check error
            }
            else
            {
                self.phojers = [objects mutableCopy];
                self.phojersFollowed = self.phojers;
                [self.tableView reloadData];
            }

        }];
    }

    // query for phojers following current phojer
    else if (self.passedPhojer)
    {

        PFQuery *followersQuery = [Phojer query];

        [followersQuery whereKey:@"following" equalTo:self.passedPhojer];

        [followersQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {

            if (error)
            {
                //TODO: check error
            }
            else
            {
                self.phojers = [objects mutableCopy];
                [self.tableView reloadData];
            }

        }];

    }

}

- (void)viewWillAppear:(BOOL)animated
{

    if (!self.passedPhojer)
    {
        [self.view addSubview:self.searchBar];
        CGFloat offsetFromTop = self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
        self.searchBar.frame = CGRectMake(0, offsetFromTop, [UIScreen mainScreen].bounds.size.width, self.searchBar.frame.size.height);

        self.tableView.contentInset = UIEdgeInsetsMake(self.searchBar.frame.size.height, 0, 0, 0);

        self.showFollowing = YES;
    }

}

#pragma mark - table view methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.phojers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];

    Phojer *phojer = self.phojers[indexPath.row];
    cell.textLabel.text = phojer.name;
    cell.detailTextLabel.text = phojer.username;

    return cell;
}

#pragma mark - seach bar delegates

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{

    if ([searchText isEqualToString:@""])
    {
        self.phojers = [self.phojersFollowed mutableCopy];
        [self.tableView reloadData];
    }
    else
    {

        PFQuery *nameQuery = [Phojer query];
        [nameQuery whereKey:@"name" containsString:searchText];

        PFQuery *usernameQuery = [Phojer query];
        [usernameQuery whereKey:@"username" containsString:searchText];

        PFQuery *query = [PFQuery orQueryWithSubqueries:@[nameQuery, usernameQuery]];

        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (error)
            {
                //TODO: error check
            }
            else
            {
                self.phojers = [objects mutableCopy];
                [self.tableView reloadData];
            }
        }];

    }

}

#pragma mark - tab bar methods

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
//    JVAProfileViewController *vc = viewController.childViewControllers.firstObject;
//
//    if ([vc isEqual:self])
//    {
//        [self.view addSubview:self.searchBar];
//        CGFloat offsetFromTop = self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
//        self.searchBar.frame = CGRectMake(0, offsetFromTop, [UIScreen mainScreen].bounds.size.width, self.searchBar.frame.size.height);
//        self.tableView.contentInset = UIEdgeInsetsMake(self.searchBar.frame.size.height, 0, 0, 0);
//
//        self.showFollowing = YES;
//    }
//
}

#pragma mark - helper methods

- (void)returnSearchResults
{

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

    UINavigationController *navVC = segue.destinationViewController;

    JVAProfileViewController *vc = navVC.childViewControllers.firstObject;

    Phojer *selectedPhojer = [Phojer object];

    if ([self.searchBar.text isEqualToString:@""] && [self.passedPhojer isEqual:self.currentPhojer])
    {
        selectedPhojer = self.phojersFollowed[[self.tableView indexPathForSelectedRow].row];
    }
    else
    {
        selectedPhojer = self.phojers[[self.tableView indexPathForSelectedRow].row];
    }

    vc.passedPhojer = selectedPhojer;

}

@end
