//
//  CommentViewController.m
//  Phojo
//
//  Created by Mobile Making on 11/17/14.
//  Copyright (c) 2014 Jonathan Chou. All rights reserved.
//

#import "JVACommentViewController.h"
#import "Comment.h"
#import "Phojer.h"
#import "Post.h"

@interface JVACommentViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UIToolbar *toolBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sendButton;
@property (weak, nonatomic) IBOutlet UITextField *commentTextField;
@property (weak, nonatomic) IBOutlet UITableView *commentViewTable;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property (weak, nonatomic) IBOutlet UITableView *userTaggingTableView;
@property NSArray *commentsArray;
@property NSMutableArray *matchingUsersArray;
@property BOOL isUserTaggingModeEnabled;
@property NSArray *phojerArray;
@property int originalStringIndex;
@property NSString *stringToEdit;

@end

@implementation JVACommentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self commentTaggingDetected];
    [self refreshDisplay];
    

    //    Phojer *phojer = [[PFUser currentUser] objectForKey:@"Phojer"];
    PFQuery *phojerQuery = [Phojer query];
    [phojerQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        self.phojerArray = objects;
    }];
}

//-(void)viewDidAppear:(BOOL)animated
//{
//    [super viewDidAppear:animated];
//    [self.view addSubview:self.toolBar];
//    self.toolBar.frame = CGRectMake(0, 84, self.view.frame.size.width, self.toolBar.frame.size.height);
//    
//}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self.view addSubview:self.toolBar];
    self.toolBar.frame = CGRectMake(0, 84, self.view.frame.size.width, self.toolBar.frame.size.height);
}

- (void)refreshDisplay
{
    
    
    //    Post *post = [Post object];
    PFQuery *photoQuery = [Post query];
    [photoQuery whereKey:@"objectId" equalTo:@"vlfTvWMCOe"];
    [photoQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        Post *post = objects.firstObject;
//        self.currentPost = post;
        
        PFQuery *query = [Comment query];
        [query whereKey:@"post" equalTo:post];
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            self.commentsArray = objects;
            [self.commentViewTable reloadData];
        }];
    }];
    
    
    
    //    [photo f]
    //make a mock photo for now.
    
    
    // add save button to nav bar programmatically
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([tableView isEqual:self.commentViewTable])
    {
        
        return self.commentsArray.count;
    }
    else
    {
        return self.matchingUsersArray.count;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([tableView isEqual:self.userTaggingTableView])
    {
        Phojer *phojer = self.matchingUsersArray[indexPath.row];
        self.commentTextField.text = [self.stringToEdit stringByAppendingString:phojer.name];
        self.isUserTaggingModeEnabled = NO;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if([tableView isEqual:self.commentViewTable])
    {
        [self.userTaggingTableView setHidden:YES];
        [self.commentViewTable setHidden:NO];
        cell = [tableView dequeueReusableCellWithIdentifier:@"commentCell" forIndexPath:indexPath];
        Comment *comment = self.commentsArray[indexPath.row];
        
        cell.textLabel.text = comment.commentText;
        
        
    }
    
    
    else
    {
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"matchCell" forIndexPath:indexPath];
        Phojer *phojer = self.matchingUsersArray[indexPath.row];
        cell.textLabel.text = phojer.name;
        
        
    }
    
    return cell;
}
- (IBAction)onButtonPressedSendComment:(UIButton *)sender
{
    
    
    Comment *comment = [Comment object];
    comment.commentText = self.commentTextField.text;
    comment.post = self.currentPost;
    [comment saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        //        [self refreshDisplay];
        [self refreshDisplay];
        self.commentTextField.text = @"";
    }];
    
}





//functionality

-(void)commentTaggingDetected
{
    
    [self.commentTextField addTarget:self
                              action:@selector(textFieldDidChange:)
                    forControlEvents:UIControlEventEditingChanged];
    
    
}


-(void)textFieldDidChange:(UITextField *)textField
{
    
    
    
    NSString *string = textField.text;
    
    if(!self.isUserTaggingModeEnabled)
    {
        NSString *trimmedString=[string substringFromIndex:[string length]-1];
        if([trimmedString isEqualToString: @"@"]) //enter mode
        {
            //enter tableview toggle mode / BOOL value as property
            self.stringToEdit = string;
            
            self.isUserTaggingModeEnabled = YES;
            self.originalStringIndex = (int)[string length]; //probably have to be a property
        }
    }
    
    
    else{
        
        
        [self.commentTextField setHidden:YES];
        
        [self.userTaggingTableView setHidden:NO];
        
        //corner case of multiple @s in a row
        
        
        
        self.stringToEdit = string;
        
        //save previous data before continuing
//        NSString *subString = [string substringToIndex: self.originalStringIndex - 1];

        //maybe I'll also save the index right here.
        
        
        
        //if user backspaces past the @ then exit mode
        
        
        //if user continues typing
        NSString *continuedTypingString = [string substringFromIndex: self.originalStringIndex];
        
        //search user's friends as following/followed
        //        NSMutableArray *arrayOfFriends;
        self.matchingUsersArray = [NSMutableArray array];
        //                for(Phojer *phojer in self.phojer.followed)
        for(Phojer *phojer in self.phojerArray)
        {
            if([phojer.name containsString: continuedTypingString])
                [self.matchingUsersArray addObject: phojer];
            //            [self refreshDisplay];
            [self.userTaggingTableView reloadData];
        }
    }
    //    if(self.matchingUsersArray.count == 0)
    //    {
    //        {
    //            self.isUserTaggingModeEnabled = NO;
    //        }
    //    }
    
    
    
    
    
}






- (IBAction)onSaveButtonPressed:(UIBarButtonItem *)sender
{
    
    // save comment
    
}


@end
