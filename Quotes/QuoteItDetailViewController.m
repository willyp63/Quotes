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

@property (weak, nonatomic) IBOutlet QuoteView *quoteText;

@property (weak, nonatomic) IBOutlet UIButton *doneButton;

@end

@implementation QuoteItDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // hide tabs
    self.tabBarController.tabBar.hidden = YES;
    
    // set quote text
    self.quoteText.text = self.quote;
    
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
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // show tabs
    self.tabBarController.tabBar.hidden = NO;
}

// actions
- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)submit:(id)sender {
    // check for valid date
    NSString *dateAsString = [NSString stringWithFormat:@"%@/%@/%@", self.monthField.text, self.dayField.text, self.yearField.text];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    NSDate * date = [dateFormatter dateFromString:dateAsString];
    if (date) {
        // request body
        NSDictionary *body;
        
        // make api request
        [QuotesApiUtil postQuoteWithBody:body completionHandler:^(NSDictionary *jsonData, NSURLResponse *response, NSError *error) {
            if (!error) {
                
            } else {
                
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
    // get new string
    NSString *newString = [NSString stringWithString:textField.text];
    newString = [newString stringByReplacingCharactersInRange:range withString:string];
    
    // dont allow more chars then plac holder
    if (newString.length > textField.placeholder.length) {
        return NO;
    }
    
    textField.text = newString;
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

//check if form is complete
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
