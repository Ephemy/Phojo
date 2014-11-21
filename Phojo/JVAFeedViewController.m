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
#import "JVAProfileViewController.h"
#import "JVACommentViewController.h"
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
@property NSString *stringToPass;
@property Phojer *passedPhojer;

@end

@implementation JVAFeedViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
//        [PFUser logOut];

    self.collectionView.backgroundColor = [UIColor clearColor];

    self.currentPhojer = [[PFUser currentUser]objectForKey:@"phojer"];
    
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];

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

    if (self.passedPost)
    {
        self.postArray = @[self.passedPost];

        //for every post in feed, get comments.
        [self getCommentsForPost:self.passedPost onCompletionHandler:^(NSArray *array) {

            self.currentCommentsArray = array;

            [self.collectionView reloadData];

        }];
    }
    else
    {
        [self queryAndLoad];
    }

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
            [postsQuery includeKey:@"poster"];
            
            
            
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
                        [self getCommentsForPost:post onCompletionHandler:^(NSArray *array) {
                           
                            self.currentCommentsArray = array;
                            
                            [self.collectionView reloadData];
                            
                        }];
                    //- (void)someMethodThatTakesABlock:(returnType (^)(parameterTypes))blockName;
                    
                    
                }
                
            }];
            
            
            
            
            
            
            
            
        }
    }];
    
}

- (void) getCommentsForPost: (Post *)post onCompletionHandler:(void (^)(NSArray *array))complete
{
    
    
    PFQuery *commentsQuery = [Comment query];
    [commentsQuery whereKey:@"post" equalTo:post];
    [commentsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (error)
         {
             NSLog(@"%@",error.localizedDescription);
         }else{
             complete(objects);
         }
     }];
}
//

//
//  ViewController.m
//  TestTagging
//
//  Created by Jonathan Chou on 11/20/14.
//  Copyright (c) 2014 Jonathan Chou. All rights reserved.
//



- (NSString *)createTagsFromTextField:(NSString *)string
//- (void)someMethodThatTakesABlock:(returnType (^)(parameterTypes))blockName;

{
    NSMutableString *theMasterString = [NSMutableString string];
    
    int lastPoint = 0;
    int lastWordLength = 0;
    NSString *lastString = [NSString string];
    
    //    NSString *string = @"hi my name is jon #hashtag ihopethiworks #yolo #swag #nomnom fewfeawfefefefeafew #screwu";
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"@(\\w+)" options:0 error:&error];
    NSArray *matches = [regex matchesInString:string options:0 range:NSMakeRange(0, string.length)];
    if(matches.count == 0)
    {
        return string;
    }
    else
    {
    for (NSTextCheckingResult *match in matches) {
        NSRange wordRange = [match rangeAtIndex:1];
        NSLog(@"%lu", (unsigned long)wordRange.location);
        NSString* word = [string substringWithRange:wordRange];
        NSString *stringURL = [NSString stringWithFormat:@"<a href=\"insta://hashtag/%@\">@%@</a> ",word, word];
        NSString *subString = [string substringWithRange:NSMakeRange(lastPoint + lastWordLength, wordRange.location - lastPoint - 1 - lastWordLength )];
        
        lastString = stringURL;
        //        NSLog(@"Found tag %@", subString);
        NSLog(@"%@", subString);
        
        [theMasterString appendString:subString];
        [theMasterString appendString:stringURL];
        
        lastPoint = (int)wordRange.location;
        lastWordLength = (int)word.length + 1;
        
    }
    NSLog(@"%@", theMasterString );
    return theMasterString;
    }
//    [self.phojoWebView loadHTMLString:theMasterString baseURL:nil];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if(navigationType == UIWebViewNavigationTypeLinkClicked){
        
        NSURL *theURL = request.URL;
        self.stringToPass = [theURL lastPathComponent];
        
        PFQuery *query = [Phojer query];
        [query whereKey:@"username" equalTo:self.stringToPass];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            self.passedPhojer = objects.firstObject;
           
            [self performSegueWithIdentifier:@"userProfilePush" sender:self];

            
        }];
        
        return NO;
    }
    return YES;
}

//-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    SecondVCViewController *sVC = segue.destinationViewController;
//    sVC.string = self.stringToPass;
//}








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
    [self dismissViewControllerAnimated:YES completion:nil];}

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
    
    return 2;
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    Post *post = self.postArray[indexPath.section];
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
        NSMutableString *finalString = [NSMutableString string];
        
        Comment *firstComment = self.currentCommentsArray.firstObject;
        for (Comment *comment in self.currentCommentsArray) {
            NSLog(@"%@",comment.commentText);
            NSString *resultString = [self createTagsFromTextField:comment.commentText];

            [finalString appendString:@"<font face=\"helvetica\">"];
            [finalString appendString:resultString];
            [finalString appendString: @"</br>"];
            [finalString appendFormat:@"–––––"];
            [finalString appendString: @"</br>"];
            [finalString appendString:@"</font>"];

            
//            NSLog(@"%@", comment.post.caption);

        }
       
        [detailCell.commentWebView loadHTMLString:finalString baseURL:nil];
//        NSLog(@"%@", detailCell.postValue.caption);
        detailCell.postValue = firstComment.post;
//        Phojer *poster = firstComment.post.poster;
//        [detailCell.userButton setTitle:firstComment.post.poster.username forState:UIControlStateNormal];
        return detailCell;
    }
    
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UIButton *)button
{
    if([segue.identifier isEqualToString:@"commentPush"]){
    
    JVAPostDetailCollectionViewCell *cell = (JVAPostDetailCollectionViewCell *)[[button superview] superview] ;
    Post *post = cell.postValue;
    JVACommentViewController *JVAcommentVC = segue.destinationViewController;
    JVAcommentVC.currentPost = post;
        
    }
    
    
    if([segue.identifier isEqualToString:@"userProfilePush"])
    {
        UINavigationController *navVC = segue.destinationViewController;

        JVAProfileViewController *JVAprofileVC = navVC.childViewControllers.firstObject;
        JVAprofileVC.passedPhojer = self.passedPhojer;

    }
}

//-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
//{
//    if([segue.identifier isEqualToString:@"userProfilePush"])
//    {
//        
//    }
//}
- (IBAction)unwindFromCommentVC:(UIStoryboardSegue *)sender
{
    
}

@end


















