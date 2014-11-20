//
//  Phojer.m
//  Phojo
//
//  Created by Mobile Making on 11/18/14.
//  Copyright (c) 2014 Jonathan Chou. All rights reserved.
//

#import "Phojer.h"

@implementation Phojer

@dynamic name;
@dynamic username;
@dynamic email;
@dynamic profileImage;
@dynamic following;

+ (void)load
{
    [self registerSubclass];
}

+ (NSString *)parseClassName
{
    return @"Phojer";
}

@end
