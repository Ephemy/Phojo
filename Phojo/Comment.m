//
//  Comment.m
//  Phojo
//
//  Created by Mobile Making on 11/18/14.
//  Copyright (c) 2014 Jonathan Chou. All rights reserved.
//

#import "Comment.h"

@implementation Comment

@dynamic timeStamp;
@dynamic author;
@dynamic taggedPhojers;
@dynamic post;
@dynamic commentText;

+ (void)load
{
    [self registerSubclass];
}

+ (NSString *)parseClassName
{
    return @"Comment";
}

@end
