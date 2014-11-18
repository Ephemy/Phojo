//
//  UserListViewController.m
//  Phojo
//
//  Created by Mobile Making on 11/17/14.
//  Copyright (c) 2014 Jonathan Chou. All rights reserved.
//

#import "JVAUserListViewController.h"

@interface JVAUserListViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation JVAUserListViewController


/*
 If this scene is presented from the search tab, it should toggle between collection view for searching tags and list view for searching users.
 If it is presented from tapping on a user's followers, it should only show the list view, and hide search bar.
 Tapping on a table cell should take you to the users profile page.
 Tapping on a collection view cell should take you to single post detail view (feed scene).
 */

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
