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

@interface JVAFeedViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation JVAFeedViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{

    return 2;

}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{

    JVAPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"photoCell" forIndexPath:indexPath];

    return cell;

}

- (IBAction)unwindFromCommentVC:(UIStoryboardSegue *)sender
{
    
}

@end
