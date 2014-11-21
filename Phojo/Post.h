//
//  Post.h
//  Phojo
//
//  Created by Mobile Making on 11/18/14.
//  Copyright (c) 2014 Jonathan Chou. All rights reserved.
//

#import <Parse/Parse.h>
#import <Parse/PFObject+Subclass.h>

@class Photo;
@class Phojer;

@interface Post : PFObject

@property NSString *caption;
@property NSDate *timeStamp;
@property PFGeoPoint *location;
@property Photo *photo;
@property Phojer *poster;
@property NSArray *tags;

@end
