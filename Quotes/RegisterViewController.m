//
//  RegisterViewController.m
//  Quotes
//
//  Created by Wil Pirino on 10/9/16.
//  Copyright © 2016 Wil Pirino. All rights reserved.
//

#import "RegisterViewController.h"
#import "A0SimpleKeychain.h"
#import "AuthApiUtil.h"
#import "constants.h"

@interface RegisterViewController ()

@property (weak, nonatomic) IBOutlet UITextField *firstName;
@property (weak, nonatomic) IBOutlet UITextField *lastName;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumber;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self hideLoader];
}

- (IBAction)register:(id)sender {
    [self showLoader];
    
    // request params
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys: _firstName.text, @"fname", _lastName.text, @"lname", _phoneNumber.text, @"phone", _password.text, @"pwd", nil];
    
    // make api request
    [AuthApiUtil registerWithParams:params completionHandler:^(NSDictionary *jsonData, NSURLResponse *response, NSError *error) {
        if (!error) {
            // check for token
            NSString *token = [jsonData objectForKey:@"token"];
            if (token) {
                // Success
                NSLog(@"Registration successful!");
                
                // save user info and token
                [self saveUser:[jsonData objectForKey:@"user"] andToken:token];
                if (self.profileImage.image) {
                    NSString *userPhoneNumber = [[jsonData objectForKey:@"user"] objectForKey:@"phone"];
                    [self saveProfileImage:self.profileImage.image underPhoneNumber:userPhoneNumber];
                }
                
                // segue
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self performSegueWithIdentifier:@"register" sender:self];
                });
            } else {
                // show error
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self failRegisterWithError:[jsonData objectForKey:@"message"]];
                });
            }
        } else {
            // show error
            dispatch_async(dispatch_get_main_queue(), ^{
                [self failRegisterWithError:@"Error Connecting to register endpoint"];
            });
        }
    }];
}

- (IBAction)askForPhoto:(id)sender {
    // show image picker VC
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.allowsEditing = YES;
    [picker setDelegate:self];
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = [info valueForKey:UIImagePickerControllerEditedImage];
    self.profileImage.image = image;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

// dismiss keyboard on view tap
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)saveUser:(NSDictionary *)user andToken:(NSString *)token {
    [[A0SimpleKeychain keychain] setString:token forKey:JWT_KEY];
    [[NSUserDefaults standardUserDefaults] setObject:[user objectForKey:@"fname"] forKey:FIRST_NAME_KEY];
    [[NSUserDefaults standardUserDefaults] setObject:[user objectForKey:@"lname"] forKey:LAST_NAME_KEY];
    [[NSUserDefaults standardUserDefaults] setObject:[user objectForKey:@"phone"] forKey:PHONE_NUMBER_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)saveProfileImage:(UIImage *)image underPhoneNumber:(NSString *)phoneNumber {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *imageName = [NSString stringWithFormat:@"%@.jpg", phoneNumber];
    NSString *imagePath = [documentsDirectory stringByAppendingPathComponent:imageName];
    NSData *imageData = UIImageJPEGRepresentation(image, 1);
    [imageData writeToFile:imagePath atomically:YES];
}

- (void)clearFields {
    _firstName.text = @"";
    _lastName.text = @"";
    _phoneNumber.text = @"";
    _password.text = @"";
    _profileImage.image = nil;
}

- (void)showLoader {
    self.spinner.hidden = NO;
    [self.spinner startAnimating];
    [self.view setUserInteractionEnabled:NO];
}

- (void)hideLoader {
    self.spinner.hidden = YES;
    [self.spinner stopAnimating];
    [self.view setUserInteractionEnabled:YES];
}

- (void)failRegisterWithError:(NSString *)error {
    [self hideLoader];
    [self clearFields];
    
    // show alert for error message
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Register Failed"
                                                                             message:error
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"Ok"
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];
    [alertController addAction:actionOk];
    [self presentViewController:alertController animated:YES completion:nil];
}

@end