//
//  JVAPostDetailCollectionViewCell.h
//  Phojo
//
//  Created by Mobile Making on 11/17/14.
//  Copyright (c) 2014 Jonathan Chou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JVAPostDetailCollectionViewCell : UICollectionViewCell
@property (strong, nonatomic) IBOutlet UIButton *userButton;
@property (strong, nonatomic) IBOutlet UIButton *flagButton;
@property (strong, nonatomic) IBOutlet UIButton *commentButton;
@property (strong, nonatomic) IBOutlet UIWebView *captionWebView;
@property (strong, nonatomic) IBOutlet UIWebView *commentWebView;

@end
