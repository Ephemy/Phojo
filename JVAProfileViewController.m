//
//  ProfileViewController.m
//  Phojo
//
//  Created by Mobile Making on 11/17/14.
//  Copyright (c) 2014 Jonathan Chou. All rights reserved.
//

#import "JVAProfileViewController.h"
#import "JVAThumbnailCollectionViewCell.h"
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
@property NSArray *posts;


@end

@implementation JVAProfileViewController

- (void)viewDidLoad
{

    [super viewDidLoad];

    //TODO: need to subclass PFObject and set properties for following code to work

    [self.currentPhojer.profileImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (error)
        {
            //TODO: error check
        }
        else
        {
            self.profileImageView.image = [UIImage imageWithData:data];
        }

    }];

    self.nameLabel.text = self.currentPhojer.name;
    self.usernameLabel.text = self.currentPhojer.username;

    //TODO: syntax from Core Data. Update with Parse syntax

    PFQuery *query = [Post query];

    [query includeKey:@"photo"];

    [query whereKey:@"poster" equalTo:self.currentPhojer];
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

- (IBAction)onFollowingButtonPressed:(UIButton *)sender
{
    // show list of followed users
    [self performSegueWithIdentifier:@"userListSegue" sender:sender];
}

- (IBAction)onFollowersButtonPressed:(UIButton *)sender
{
    // show list of followers
    [self performSegueWithIdentifier:@"userListSegue" sender:sender];

}

@end
