//
//  Photo.h
//  Phojo
//
//  Created by Mobile Making on 11/18/14.
//  Copyright (c) 2014 Jonathan Chou. All rights reserved.
//

#import <Parse/Parse.h>

@class Phojer;

@interface Photo : PFObject

@property PFFile *image;
@property NSDate *timeStamp;
@property PFGeoPoint *location;
@property Phojer *taggedPhojers;

@end
