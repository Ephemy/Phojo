//
//  UserListViewController.m
//  Phojo
//
//  Created by Mobile Making on 11/17/14.
//  Copyright (c) 2014 Jonathan Chou. All rights reserved.
//

#import "JVAUserListViewController.h"
#import "Phojer.h"

@interface JVAUserListViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@property NSArray *phojers;

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

    Phojer *currentPhojer = [[PFUser currentUser] objectForKey:@"phojer"];

    // query for phojers current phojer is following
    if (self.showFollowing)
    {

        PFRelation *following = [currentPhojer relationForKey:@"following"];
        PFQuery *followingQuery = [following query];

        [followingQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {

            if (error)
            {
                //TODO: check error
            }
            else
            {
                self.phojers = objects;
                [self.tableView reloadData];
            }

        }];
    }

    // query for phojers following current phojer
    else
    {

        PFQuery *followersQuery = [Phojer query];
        [followersQuery whereKey:@"following" equalTo:currentPhojer];

        [followersQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {

            if (error)
            {
                //TODO: check error
            }
            else
            {
                self.phojers = objects;
                [self.tableView reloadData];
            }

        }];

    }

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

@end
