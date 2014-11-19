//
//  Phojer.h
//  Phojo
//
//  Created by Mobile Making on 11/18/14.
//  Copyright (c) 2014 Jonathan Chou. All rights reserved.
//

#import <Parse/Parse.h>
#import <Parse/PFObject+Subclass.h>

@class Photo;

@interface Phojer : PFObject

@property NSString *name;
@property NSString *username;
@property NSString *email;
@property PFFile *profileImage;
@property PFRelation *following;

@end
