//
//  Photo.m
//  Phojo
//
//  Created by Mobile Making on 11/18/14.
//  Copyright (c) 2014 Jonathan Chou. All rights reserved.
//

#import "Photo.h"

@implementation Photo

@dynamic image;
@dynamic timeStamp;
@dynamic location;
@dynamic taggedPhojers;


+ (void)load
{
    [self registerSubclass];
}

+ (NSString *)parseClassName
{
    return @"Photo";
}

@end
