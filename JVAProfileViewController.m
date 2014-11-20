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
#import "Phojer.h"
#import "Post.h"
#import "Photo.h"

@interface JVAProfileViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UIImageView *profileImageView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;
@property (strong, nonatomic) IBOutlet UIButton *followingButton;
@property (strong, nonatomic) IBOutlet UIButton *followersButton;
@property (strong, nonatomic) IBOutlet UIButton *followButton;
@property Phojer *currentPhojer;
@property NSArray *posts;
@property BOOL isFollowing;


@end

@implementation JVAProfileViewController

- (void)viewDidLoad
{

    [super viewDidLoad];

    self.collectionView.backgroundColor = [UIColor clearColor];

    self.currentPhojer = [[PFUser currentUser] objectForKey:@"phojer"];

    if (self.tabBarController.selectedIndex == 3)
    {
        self.viewedPhojer = self.currentPhojer;

        [self.followButton setHidden:YES];
    }

    if (self.viewedPhojer == self.currentPhojer)
    {
        self.tabBarController.selectedIndex = 3;
    }

    self.followButton.titleLabel.text = @"HHH";
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

            //TODO: need to subclass PFObject and set properties for following code to work

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
            self.usernameLabel.text = self.viewedPhojer.username;

            //TODO: syntax from Core Data. Update with Parse syntax

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

    [self getFollowers:self.viewedPhojer withCompletion:^(NSArray *followers) {

        [self.followersButton setTitle:[NSString stringWithFormat:@"%lu", (unsigned long)followers.count] forState:UIControlStateNormal];

    }];

    [self getFollowing:self.viewedPhojer withCompletion:^(NSArray *following) {

        [self.followingButton setTitle:[NSString stringWithFormat:@"%lu", (unsigned long)following.count] forState:UIControlStateNormal];

    }];


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

#pragma mark - navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

    UINavigationController *navVC = segue.destinationViewController;
    JVAUserListViewController *vc = navVC.childViewControllers.firstObject;

    if ([sender isEqual:self.followingButton])
    {
        vc.showFollowing = YES;
    }
    else
    {
        vc.showFollowing = NO;
    }

}

@end
