//
//  Post.m
//  Phojo
//
//  Created by Mobile Making on 11/18/14.
//  Copyright (c) 2014 Jonathan Chou. All rights reserved.
//

#import "Post.h"

@implementation Post

@dynamic caption;
@dynamic timeStamp;
@dynamic location;
@dynamic photo;
@dynamic poster;
@dynamic tags;

+ (void)load
{
    [self registerSubclass];
}

+ (NSString *)parseClassName
{
    return @"Post";
}

@end
