//
//  CommentViewController.m
//  Phojo
//
//  Created by Mobile Making on 11/17/14.
//  Copyright (c) 2014 Jonathan Chou. All rights reserved.
//

#import "JVACommentViewController.h"

@interface JVACommentViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *commentViewTable;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property (weak, nonatomic) IBOutlet UITableView *userMentionedInComment;

@end

@implementation JVACommentViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // add save button to nav bar programmatically
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (IBAction)onSaveButtonPressed:(UIBarButtonItem *)sender
{

    // save comment

}


@end
