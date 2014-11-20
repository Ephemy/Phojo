//
//  UserListViewController.h
//  Phojo
//
//  Created by Mobile Making on 11/17/14.
//  Copyright (c) 2014 Jonathan Chou. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Phojer;

@interface JVAUserListViewController : UIViewController

@property Phojer *passedPhojer;
@property BOOL showFollowing;

@end
