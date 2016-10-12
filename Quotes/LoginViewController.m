//
//  LoginViewController.m
//  Quotes
//
//  Created by Wil Pirino on 10/9/16.
//  Copyright © 2016 Wil Pirino. All rights reserved.
//

#import "LoginViewController.h"
#import "A0SimpleKeychain.h"
#import "AuthApiUtil.h"
#import "constants.h"

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *phoneNumber;
@property (weak, nonatomic) IBOutlet UITextField *password;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self hideLoader];
}

- (IBAction)login:(id)sender {
    [self showLoader];
    
    // request params
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys: _phoneNumber.text, @"phone", _password.text, @"pwd", nil];
    
    // make api request
    [AuthApiUtil loginWithParams:params completionHandler:^(NSDictionary *jsonData, NSURLResponse *response, NSError *error) {
        if (!error) {
            // check for token
            NSString *token = [jsonData objectForKey:@"token"];
            if (token) {
                // Success
                NSLog(@"Login successful!");
                
                // save user info and token
                [self saveUser:[jsonData objectForKey:@"user"] andToken:token];
                
                // segue
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self performSegueWithIdentifier:@"login" sender:self];
                });
            } else {
                // show error
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self failLoginWithError:[jsonData objectForKey:@"message"]];
                });
            }
        } else {
            // show error
            dispatch_async(dispatch_get_main_queue(), ^{
                [self failLoginWithError:@"Error Connecting to login endpoint"];
            });
        }
    }];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

// dismiss keyboard
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

- (void)clearFields {
    _phoneNumber.text = @"";
    _password.text = @"";
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

- (void)failLoginWithError:(NSString *)error {
    [self clearFields];
    [self hideLoader];
    
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
