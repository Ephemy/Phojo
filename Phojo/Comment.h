//
//  Comment.h
//  Phojo
//
//  Created by Mobile Making on 11/18/14.
//  Copyright (c) 2014 Jonathan Chou. All rights reserved.
//

#import <Parse/Parse.h>

@class Phojer;
@class Post;

@interface Comment : PFObject

@property NSDate *timeStamp;
@property Phojer *author;
@property NSArray *taggedPhojers;
@property Post *post;
@property NSString *commentText;

@end
