//
//  ViewController.m
//  Phojo
//
//  Created by Jonathan Chou on 11/17/14.
//  Copyright (c) 2014 Jonathan Chou. All rights reserved.
//

#import "JVAFeedViewController.h"
#import "JVAPhotoCollectionViewCell.h"
#import "JVAPostDetailCollectionViewCell.h"
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "Post.h"
#import "Photo.h"
#import "Phojer.h"
#import "Comment.h"
@import Social;

@interface JVAFeedViewController () <UICollectionViewDelegate, UICollectionViewDataSource, PFSignUpViewControllerDelegate, PFLogInViewControllerDelegate, UIWebViewDelegate>

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSArray *postArray;
@property (strong, nonatomic) NSArray *followingArray;
@property (strong, nonatomic) NSArray *currentCommentsArray;
@end

@implementation JVAFeedViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //    [PFUser logOut];
    self.currentPhojer = [[PFUser currentUser]objectForKey:@"phojer"];
    
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if([PFUser currentUser] == nil){
        PFLogInViewController *login = [[PFLogInViewController alloc] init];
        login.delegate = self;
        login.signUpController.delegate = self;
        [self presentViewController:login animated:YES completion:nil];
    }
    else{
        //        [self alertViewStuff];
    }
    
    [self queryAndLoad];
    
}

-(void)alertViewStuff
{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Confirmation" message:@"Welcome to Phojo! Here's a Quick Introduction to get you started :)" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *welcomeButton = [UIAlertAction actionWithTitle:@"Great, Let's get started~~~~~" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
    }];
    [alert addAction:welcomeButton];
    //    [alert addAction:cancelButton];
    [self presentViewController:alert animated:YES completion:nil];
    
}

- (void)queryAndLoad
{
    
    //1 - get the array of followers
    PFRelation *followingRelation = [self.currentPhojer relationForKey:@"following"];
    PFQuery *followersQuery = [followingRelation query];
    
    [followersQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error)
        {
            NSLog(@"%@",error.localizedDescription);
        }
        else
        {
            self.followingArray = objects;
            
            
            //2. Find posts where the poster is contained in our following array
            PFQuery *postsQuery = [Post query];
            [postsQuery whereKey:@"poster" containedIn:self.followingArray];
            [postsQuery includeKey:@"photo"];
            
            
            
            [postsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                
                if (error)
                {
                    NSLog(@"error! %@",error.localizedDescription);
                }
                else
                {
                    self.postArray = objects;
                    
                    //for every post in feed, get comments.
                    for(Post *post in self.postArray)
                        [self getCommentsForPost:post];
                    
                }
                
            }];
            
            
            
            
            
            
            
            
        }
    }];
    
}

- (void) getCommentsForPost: (Post *)post
{
    
    
    PFQuery *commentsQuery = [Comment query];
    [commentsQuery whereKey:@"post" equalTo:post];
    [commentsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (error)
         {
             NSLog(@"%@",error.localizedDescription);
         }else{
             self.currentCommentsArray = objects;
             [self.collectionView reloadData];
         }
     }];
}
//





#pragma mark: login controller methods

- (BOOL)logInViewController:(PFLogInViewController *)logInController
shouldBeginLogInWithUsername:(NSString *)username
                   password:(NSString *)password
{
    return ([PFUser currentUser] == nil);
}

///--------------------------------------
/// @name Responding to Actions
///--------------------------------------

/*!
 @abstract Sent to the delegate when a <PFUser> is logged in.
 
 @param logInController The login view controller where login finished.
 @param user <PFUser> object that is a result of the login.
 */
- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user
{
    if(user )
        [self dismissViewControllerAnimated:YES completion:nil];
}

/*!
 @abstract Sent to the delegate when the log in attempt fails.
 
 @param logInController The login view controller where login failed.
 @param error `NSError` object representing the error that occured.
 */
- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error
{
    
}

/*!
 @abstract Sent to the delegate when the log in screen is cancelled.
 
 @param logInController The login view controller where login was cancelled.
 */
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController
{
    
    
    
    
}




#pragma mark: sign up controller methods


- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info
{
    BOOL informationComplete = YES;
    
    // loop through all of the submitted data
    for (id key in info) {
        NSString *field = [info objectForKey:key];
        if (!field || field.length == 0) { // check completion
            informationComplete = NO;
            break;
        }
    }
    
    // Display an alert if a field wasn't completed
    if (!informationComplete) {
        [[[UIAlertView alloc] initWithTitle:@"Missing Information"
                                    message:@"Make sure you fill out all of the information!"
                                   delegate:nil
                          cancelButtonTitle:@"ok"
                          otherButtonTitles:nil] show];
    }
    
    return informationComplete;
}

///--------------------------------------
/// @name Responding to Actions
///--------------------------------------

/*!
 @abstract Sent to the delegate when a <PFUser> is signed up.
 
 @param signUpController The signup view controller where signup finished.
 @param user <PFUser> object that is a result of the sign up.
 */
- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user
{
    [self dismissModalViewControllerAnimated:YES];}

/*!
 @abstract Sent to the delegate when the sign up attempt fails.
 
 @param signUpController The signup view controller where signup failed.
 @param error `NSError` object representing the error that occured.
 */
- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error
{
    
}







#pragma mark: Collection View Methods



- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.postArray.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
    return self.postArray.count;
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    Post *post = self.postArray[indexPath.row];
    Photo *photo = post.photo;
    PFFile *imageFile = photo.image;
    
    if (indexPath.row == 0)
    {
        JVAPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"photoCell" forIndexPath:indexPath];
        [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
         {
             if (error)
             {
                 NSLog(@"Error! %@",error.localizedDescription);
             }
             else
             {
                 cell.photoImageView.image = [UIImage imageWithData:data];
             }
         }];
        return cell;
        
        
        
    }
    else
    {
        
        
        
        JVAPostDetailCollectionViewCell *detailCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"detailCell" forIndexPath:indexPath];
        //        detailCell.commentWebView loadHTMLString:<#(NSString *)#> baseURL:<#(NSURL *)#>
                for (Comment *comment in self.currentCommentsArray) {
                    NSLog(@"%@",comment.commentText);
                }
        
        return detailCell;
    }
    
    
}


- (IBAction)unwindFromCommentVC:(UIStoryboardSegue *)sender
{
    
}

@end


















