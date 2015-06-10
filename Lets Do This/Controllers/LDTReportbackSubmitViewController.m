//
//  LDTReportbackSubmitViewController.m
//  Lets Do This
//
//  Created by Aaron Schachter on 6/10/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "LDTReportbackSubmitViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface LDTReportbackSubmitViewController ()
@property (strong, nonatomic) NSString *selectedFilename;
@property (strong, nonatomic) NSString *selectedFilestring;
@property (strong, nonatomic) UIImagePickerController *picker;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *getImageButton;
- (IBAction)getImageTapped:(id)sender;

@end

@implementation LDTReportbackSubmitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Prove it";
    self.picker = [[UIImagePickerController alloc] init];
    self.picker.delegate = self;
    self.picker.allowsEditing = YES;
}

- (IBAction)getImageTapped:(id)sender {
    [self getImageMenu];
}

- (void) getImageMenu {
    UIAlertController *view = [UIAlertController alertControllerWithTitle:@"Prove it"
                                                                  message:@"Pics or it didn't happen!"                                                               preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *camera;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        camera = [UIAlertAction
                  actionWithTitle:@"Take Photo"
                  style:UIAlertActionStyleDefault
                  handler:^(UIAlertAction * action)
                  {
                      self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                      [self presentViewController:self.picker animated:YES completion:NULL];
                  }];
    }
    else {
        camera = [UIAlertAction
                  actionWithTitle:@"(Camera Unavailable)"
                  style:UIAlertActionStyleDefault
                  handler:^(UIAlertAction * action)
                  {
                      [view dismissViewControllerAnimated:YES completion:nil];
                  }];
    }


    UIAlertAction *library = [UIAlertAction
                             actionWithTitle:@"Choose From Library"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 self.picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                 [self presentViewController:self.picker animated:YES completion:NULL];
                             }];
    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [view dismissViewControllerAnimated:YES completion:nil];
                             }];
    [view addAction:camera];
    [view addAction:library];
    [view addAction:cancel];
    [self presentViewController:view animated:YES completion:nil];
}
#pragma mark - Image Picker Controller delegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.imageView.image = chosenImage;
    self.selectedFilestring = [UIImagePNGRepresentation(chosenImage) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];

    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        // Use JPG to preserve the JPG extension (what camera saves file as).
        self.selectedFilename = @"temp.JPG";
        [picker dismissViewControllerAnimated:YES completion:NULL];
        return;
    }


    // Get filename of selected file to preserve its file extension.
    NSURL *refURL = [info valueForKey:UIImagePickerControllerReferenceURL];
    ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *imageAsset)
    {
        ALAssetRepresentation *imageRep = [imageAsset defaultRepresentation];
        self.selectedFilename = [imageRep filename];
    };
    // Get the asset library and fetch the asset based on the ref url (pass in block above).
    ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
    [assetslibrary assetForURL:refURL resultBlock:resultblock failureBlock:nil];
    [picker dismissViewControllerAnimated:YES completion:NULL];

    // @todo: self.selectedFilename is null.. not sure whats going on here.
    NSLog(@"self.selectedFilename %@", self.selectedFilename);

}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}
@end
