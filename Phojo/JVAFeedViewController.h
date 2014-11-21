//
//  ViewController.h
//  Phojo
//
//  Created by Jonathan Chou on 11/17/14.
//  Copyright (c) 2014 Jonathan Chou. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Phojer;
@class Post;
@interface JVAFeedViewController : UIViewController
@property Post *passedPost;
@property Phojer *passedPhojer;
@property Phojer *currentPhojer;
@end

