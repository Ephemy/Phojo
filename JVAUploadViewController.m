//
//  UploadViewController.m
//  Phojo
//
//  Created by Mobile Making on 11/17/14.
//  Copyright (c) 2014 Jonathan Chou. All rights reserved.
//

#import "JVAUploadViewController.h"
#import <Parse/Parse.h>
#import "Phojer.h"
#import "Post.h"
#import "Photo.h"
#import "JVAProfileViewController.h"
@interface JVAUploadViewController () <UIImagePickerControllerDelegate, UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (strong, nonatomic) IBOutlet UIButton *uploadButton;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UITextView *captionTextView;
@property BOOL imageHasBeenSelected;
@property Phojer *currentPhojer;
@end

@implementation JVAUploadViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                              message:@"Device has no camera"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles: nil];
        
        [myAlertView show];
        
    }
    self.captionTextView.delegate = self;
    self.currentPhojer = [[PFUser currentUser] objectForKey:@"phojer"];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.imageHasBeenSelected == NO)
    {
        [self choosePhotoFromLibrary];
    }
    
    
    
    
//    if (!self.appeared || [self isMovingToParentViewController] || [self isBeingPresented])
//    {
//        self.appeared = YES;
//        [self choosePhotoFromLibrary];
//        self.captionTextView.text = [NSString stringWithFormat:@" "];
//        self.tabBarController.selectedIndex = 1;
//    }
//    else
//    {
//
//        self.appeared = NO;
//        self.tabBarController.selectedIndex = 0;
//        
//    }
//        
    
}

- (BOOL) textView: (UITextView*) textView shouldChangeTextInRange: (NSRange) range replacementText: (NSString*) text
{
    if ([text isEqualToString:@"\n"]) {
        [self.captionTextView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (IBAction)onUploadButtonPressed:(UIButton *)sender
{

    NSData* data = UIImageJPEGRepresentation(self.imageView.image, 0.5f);
    PFFile *imageFile = [PFFile fileWithName:@"image.jpg" data:data];
    
    //Save this image to parse
    
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            
            // The image has now been uploaded to Parse. Associate it with a new object
            Photo *newPhotoObject = [Photo object];
            newPhotoObject.image = imageFile;
            
            Post *newPost = [Post object];
            newPost.caption = self.captionTextView.text;
            newPost.poster = self.currentPhojer;
            newPost.photo = newPhotoObject;
            
            [newPost saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    NSLog(@"Saved");
                }
                else
                {
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                }
            }];
            self.imageHasBeenSelected = NO;
            self.tabBarController.selectedIndex = 3;
            
            
        }
    }];
//    JVAProfileViewController *vc = [[JVAProfileViewController alloc]init];
//    [self pushViewController:vc animated:YES];
}

-(void)takePhotoAppears

{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    
    //Be sure to update when testing on iPhone
    
//    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:NULL];
}



-(void)choosePhotoFromLibrary
{
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.imageView.image = chosenImage;
    self.imageHasBeenSelected = YES;
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    
    [picker dismissViewControllerAnimated:NO completion:NULL];
    self.tabBarController.selectedIndex = 0;

}
@end
