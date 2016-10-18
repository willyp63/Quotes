//
//  QuoteItDetailViewController.m
//  Quotes
//
//  Created by Wil Pirino on 10/9/16.
//  Copyright © 2016 Wil Pirino. All rights reserved.
//

#import "QuoteItDetailViewController.h"
#import "MyTabsController.h"
#import "QuoteItViewController.h"
#import "QTSTextField.h"
#import "QuoteView.h"
#import "constants.h"
#import "QuotesApiUtil.h"

@interface QuoteItDetailViewController ()

@property (weak, nonatomic) IBOutlet ContactListTextField *saidField;
@property (weak, nonatomic) IBOutlet ContactListTextField *heardField;

@property (weak, nonatomic) IBOutlet QTSTextField *monthField;
@property (weak, nonatomic) IBOutlet QTSTextField *dayField;
@property (weak, nonatomic) IBOutlet QTSTextField *yearField;

@property (weak, nonatomic) IBOutlet QuoteView *quoteView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@property (weak, nonatomic) IBOutlet UIButton *doneButton;

@end

@implementation QuoteItDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // hide tabs
    self.tabBarController.tabBar.hidden = YES;
    
    // set quote text
    self.quoteView.text = self.quoteText;
    
    UIView *borderView = [[UIView alloc] initWithFrame:self.saidField.frame];
    borderView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:borderView];
    self.saidField.frame = CGRectInset(self.saidField.frame, 2.0f, 2.0f);
    
    borderView = [[UIView alloc] initWithFrame:self.heardField.frame];
    borderView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:borderView];
    self.heardField.frame = CGRectInset(self.heardField.frame, 2.0f, 2.0f);
    
    // bring drop down text field views to front
    [self.view bringSubviewToFront:self.heardField];
    [self.view bringSubviewToFront:self.saidField];
    
    // listen to contact fields
    self.saidField.contactDelegate = self;
    self.heardField.contactDelegate = self;
    
    // limit said to one contact
    self.saidField.maxContacts = 1;
    
    //disable done button
    self.doneButton.enabled = NO;
    [self.doneButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    
    [self hideLoader];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // show tabs
    self.tabBarController.tabBar.hidden = NO;
}

// Back Action
- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

// Submit Action
- (IBAction)submit:(id)sender {
    // check for valid date and date being today or in the past
    NSString *dateAsString = [NSString stringWithFormat:@"%@/%@/%@", self.monthField.text, self.dayField.text, self.yearField.text];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    NSDate * saidAtDate = [dateFormatter dateFromString:dateAsString];
    if (saidAtDate && [saidAtDate compare:[NSDate date]] != NSOrderedDescending) {
        [self showLoader];
        
        // format request body
        NSDictionary *saidBy = [self.saidField.contacts[0] dictionaryValue];
        NSMutableArray *heardBy = [NSMutableArray arrayWithCapacity:self.heardField.contacts.count];
        for (Contact *heardContact in self.heardField.contacts) {
            [heardBy addObject:[heardContact dictionaryValue]];
        }
        NSDictionary *body = [NSDictionary dictionaryWithObjectsAndKeys: self.quoteText, @"text", dateAsString, @"saidAt", saidBy, @"saidBy", heardBy, @"heardBy", nil];
        
        // make api request
        [QuotesApiUtil postQuoteWithBody:body completionHandler:^(NSDictionary *jsonData, NSURLResponse *response, NSError *error) {
            if (!error) {
                // return to previously selected tab
                MyTabsController *mtc = (MyTabsController *)self.tabBarController;
                UINavigationController *nvc = self.navigationController;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [nvc popViewControllerAnimated:NO];
                    [(QuoteItViewController *)nvc.viewControllers[0] clearQuoteText]; // clear text in quoteIt VC
                    [mtc setSelectedIndex:mtc.prevSelectedIndex];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self hideLoader];
                    [self notifyUserOfServerErrorWithMessage:[jsonData objectForKey:@"message" ]];
                });
            }
        }];
    } else {
        [self notifyUserOfBadDate];
    }
}

- (void)notifyUserOfBadDate {
    // clear date form
    self.monthField.text = @"";
    self.dayField.text = @"";
    self.yearField.text = @"";
    
    // show alert for error message
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Invalid Date!"
                                                                             message:@"Please enter a valid date."
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"Ok"
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];
    [alertController addAction:actionOk];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)notifyUserOfServerErrorWithMessage:(NSString *)message {
    // show alert for error message
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Server Error!"
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"Ok"
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];
    [alertController addAction:actionOk];
    [self presentViewController:alertController animated:YES completion:nil];
}

// dismiss keyboard
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark UITextFieldDelegate
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // get new text
    NSString *newText = [NSString stringWithString:textField.text];
    newText = [newText stringByReplacingCharactersInRange:range withString:string];
    
    // dont allow more chars then place holder
    if (newText.length > textField.placeholder.length) {
        return NO;
    }
    
    // advance cursor to next date field if completed previous one
    if (newText.length == textField.placeholder.length) {
        if (textField == self.monthField) {
            [self.dayField becomeFirstResponder];
        } else if (textField == self.dayField) {
            [self.yearField becomeFirstResponder];
        }
    }
    
    // update text and check if form is complete
    textField.text = newText;
    [self checkIfFormIsComplete];
    
    return NO;
}

#pragma mark ContactListTextFieldDelegate
-(void)contactField:(id)contactField didAddContact:(Contact *)contact {
    // black list contact in other field
    if (contactField == self.saidField) {
        [self.heardField.blackListContacts addObject:contact];
    } else {
        [self.saidField.blackListContacts addObject:contact];
    }
    
    [self checkIfFormIsComplete];
}

-(void)contactField:(id)contactField didRemoveContact:(Contact *)contact {
    // unblack list contact in other field
    if (contactField == self.saidField) {
        [self.heardField.blackListContacts removeObject:contact];
    } else {
        [self.saidField.blackListContacts removeObject:contact];
    }
    
    [self checkIfFormIsComplete];
}

- (void)showLoader {
    //disable done button
    self.doneButton.enabled = NO;
    [self.doneButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    
    self.spinner.hidden = NO;
    [self.spinner startAnimating];
    [self.view setUserInteractionEnabled:NO];
}

- (void)hideLoader {
    self.spinner.hidden = YES;
    [self.spinner stopAnimating];
    [self.view setUserInteractionEnabled:YES];
    
    [self checkIfFormIsComplete];
}

- (void)checkIfFormIsComplete {
    if (self.saidField.contacts.count >= 1 &&
        self.heardField.contacts.count >= 1 &&
        self.monthField.text.length == 2 &&
        self.dayField.text.length == 2 &&
        self.yearField.text.length == 4){
     
        // enable submition
        self.doneButton.enabled = YES;
        [self.doneButton setTitleColor:[UIColor colorWithRed:MAIN_COLOR_RED green:MAIN_COLOR_GREEN blue:MAIN_COLOR_BLUE alpha:1.0] forState:UIControlStateNormal];
    } else {
        //disable done button
        self.doneButton.enabled = NO;
        [self.doneButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    }
}

@end
