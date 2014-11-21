//
//  ProfileViewController.m
//  Phojo
//
//  Created by Mobile Making on 11/17/14.
//  Copyright (c) 2014 Jonathan Chou. All rights reserved.
//

#import "JVAProfileViewController.h"
#import "JVAThumbnailCollectionViewCell.h"
#import "JVAUserListViewController.h"
#import "JVAFeedViewController.h"
#import "Phojer.h"
#import "Post.h"
#import "Photo.h"

@interface JVAProfileViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UIImageView *profileImageView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;
@property (strong, nonatomic) IBOutlet UIButton *followingButton;
@property (strong, nonatomic) IBOutlet UIButton *followersButton;
@property (strong, nonatomic) IBOutlet UIButton *followButton;
@property (strong, nonatomic) IBOutlet UILongPressGestureRecognizer *longPressRecognizer;
@property Phojer *currentPhojer;
@property Phojer *viewedPhojer;
@property NSArray *posts;
@property BOOL isFollowing;


@end

@implementation JVAProfileViewController

- (void)viewDidLoad
{

    [super viewDidLoad];

    self.collectionView.backgroundColor = [UIColor clearColor];
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    
    self.longPressRecognizer.enabled = NO;

    self.currentPhojer = [[PFUser currentUser] objectForKey:@"phojer"];

    if (self.passedPhojer)
    {
        self.viewedPhojer = self.passedPhojer;
        // check if following

        [self getFollowing:self.currentPhojer withCompletion:^(NSArray *following) {

            for (Phojer *phojer in following)
            {
                if ([phojer.objectId isEqualToString:self.viewedPhojer.objectId])
                {
                    self.isFollowing = YES;
                    [self setFollowButtonText];
                    break;
                }
            }

        }];
    }
    else
    {
        self.viewedPhojer = self.currentPhojer;
    }

    if ([self.viewedPhojer.objectId isEqualToString:self.currentPhojer.objectId])
    {
        [self.followButton setHidden:YES];
        self.longPressRecognizer.enabled = YES;
    }


}

- (void)viewWillAppear:(BOOL)animated
{

    [super viewWillAppear:animated];

    [self.viewedPhojer fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (error)
        {
            //TODO: error check
        }
        else
        {

            // get profile image

            [self.viewedPhojer.profileImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                if (error)
                {
                    //TODO: error check
                }
                else
                {
                    self.profileImageView.image = [UIImage imageWithData:data];
                }

            }];

            self.nameLabel.text = self.viewedPhojer.name;
            self.nameLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:24.0];
            self.usernameLabel.text = self.viewedPhojer.username;
            self.title = self.viewedPhojer.username;

            PFQuery *query = [Post query];

            [query includeKey:@"photo"];

            [query whereKey:@"poster" equalTo:self.viewedPhojer];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {

                if (error)
                {
                    //TODO: error check
                }
                else
                {
                    self.posts = objects;
                    [self.collectionView reloadData];
                }
                
            }];
            
        }
    }];


    // set follow button

    if (![self.currentPhojer.objectId isEqualToString:self.viewedPhojer.objectId])
    {
        [self getFollowers:self.currentPhojer withCompletion:^(NSArray *followers) {
            if ([followers containsObject:self.viewedPhojer])
            {
                self.isFollowing = YES;
            }
            else
            {
                self.isFollowing = NO;
            }

            [self setFollowButtonText];
        }];

    }

    // set follower/following count
    [self getFollowers:self.viewedPhojer withCompletion:^(NSArray *followers) {

        [self.followersButton setTitle:[NSString stringWithFormat:@"%lu", (unsigned long)followers.count] forState:UIControlStateNormal];

    }];

    [self getFollowing:self.viewedPhojer withCompletion:^(NSArray *following) {

        [self.followingButton setTitle:[NSString stringWithFormat:@"%lu", (unsigned long)following.count] forState:UIControlStateNormal];
        
    }];

}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;

}

#pragma mark - collection view methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{

    return self.posts.count;

}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{

    JVAThumbnailCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];

    Post *post = self.posts[indexPath.item];
    Photo *photo = post.photo;
    PFFile *imageFile = photo.image;
    [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (error)
        {
            //TODO: error check
        }
        else
        {
            cell.thumbnailImageView.image = [UIImage imageWithData:data];
        }
    }];

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // pass post and segue to feed view
}

#pragma mark - gesture recognizer methods

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([self.viewedPhojer.objectId isEqualToString:self.currentPhojer.objectId])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

#pragma mark - image picker delegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSData *imageData = UIImageJPEGRepresentation(info[UIImagePickerControllerOriginalImage], 0.5f);
    PFFile *imageFile = [PFFile fileWithName:@"profileImage" data:imageData];

    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {

        if (error)
        {
            //TODO: error check
        }
        else
        {
            self.currentPhojer.profileImage = imageFile;
            [self.currentPhojer saveInBackground];
            self.profileImageView.image = info[UIImagePickerControllerOriginalImage];

            [picker dismissViewControllerAnimated:YES completion:nil];
        }

    }];

}

#pragma mark - Action sheet delegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{

    switch (buttonIndex) {

        case 0:
        {
            break;
        }
        case 1:
        {

            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.delegate = self;

            imagePicker.allowsEditing = YES;
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

            [self presentViewController:imagePicker animated:YES completion:nil];

            break;
        }
        case 2:
        {
            [self.currentPhojer removeObjectForKey:@"profileImage"];
            [self.currentPhojer saveInBackground];
            self.profileImageView.image = [UIImage imageNamed:@"default"];

            break;
        }
            
        default:
            break;
    }
    
}


#pragma mark - helper methods

- (void)getFollowers:(Phojer *)phojer withCompletion:(void (^)(NSArray *followers))complete
{

    PFQuery *followersQuery = [Phojer query];
    [followersQuery whereKey:@"following" equalTo:phojer];

    [followersQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {

        if (error)
        {
            //TODO: check error
        }
        else
        {

            complete(objects);

        }

    }];


}

- (void)getFollowing:(Phojer *)phojer withCompletion:(void (^)(NSArray *following))complete
{

    PFRelation *following = [phojer relationForKey:@"following"];
    PFQuery *followingQuery = [following query];
    [followingQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {

        if (error)
        {
            //TODO: error check
        }
        else
        {
            complete(objects);
        }
        
    }];

}

- (void)setFollowButtonText
{

    if (self.isFollowing == YES)
    {
        [self.followButton setTitle:@"UNFOLLOW" forState:UIControlStateNormal];
    }
    else
    {
        [self.followButton setTitle:@"FOLLOW" forState:UIControlStateNormal];
    }

}

#pragma mark - IBActions

- (IBAction)onFollowingButtonPressed:(UIButton *)sender
{
    // show list of followed users
    [self performSegueWithIdentifier:@"userListSegue" sender:sender];
}

//- (IBAction)onFollowersButtonPressed:(UIButton *)sender
//{
//    // show list of followers
//    [self performSegueWithIdentifier:@"userListSegue" sender:sender];
//
//}

- (IBAction)onFollowButtonPressed:(UIButton *)sender
{
    PFRelation *following = [self.currentPhojer relationForKey:@"following"];

    if (self.isFollowing == YES)
    {
        [following removeObject:self.viewedPhojer];
        self.isFollowing = NO;
    }
    else
    {
        [following addObject:self.viewedPhojer];
        self.isFollowing = YES;
    }

    [self.currentPhojer saveInBackground];
    [self setFollowButtonText];

}

- (IBAction)onProfileImageLongPressed:(UILongPressGestureRecognizer *)sender
{

    if (sender.state == UIGestureRecognizerStateBegan)
    {
        UIActionSheet *chooseImageSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take a profile pic", @"Choose a profile pic", @"Remove profile pic", nil];
        chooseImageSheet.destructiveButtonIndex = 2;
        [chooseImageSheet showInView:self.view];
    }

}

#pragma mark - navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

    UINavigationController *navVC = segue.destinationViewController;

    if ([segue.identifier isEqualToString:@"userListSegue"])
    {
        JVAUserListViewController *vc = navVC.childViewControllers.firstObject;

        if ([sender isEqual:self.followingButton])
        {
            vc.showFollowing = YES;
        }
        else
        {
            vc.showFollowing = NO;
        }

        vc.passedPhojer = self.viewedPhojer;
    }
    else
    {
        JVAFeedViewController *vc = navVC.childViewControllers.firstObject;
        NSArray *indexPaths = [self.collectionView indexPathsForSelectedItems];
        NSInteger index = [[indexPaths firstObject] row];

        Post *post = self.posts[index];
        vc.passedPost = post;

    }

}

@end
