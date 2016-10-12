//
//  ContactListTextField.h
//  Quotes
//
//  Created by Wil Pirino on 10/9/16.
//  Copyright © 2016 Wil Pirino. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Contact.h"

@protocol ContactListTextFieldDelegate

- (void)contactField:(id)contactField didAddContact:(Contact *)contact;
- (void)contactField:(id)contactField didRemoveContact:(Contact *)contact;

@end

@interface ContactListTextField : UITextField <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSMutableArray<Contact *> *contacts;
@property (strong, nonatomic) NSMutableArray<Contact *> *blackListContacts;
@property (strong, nonatomic) NSMutableArray<NSValue *> *contactRanges;

@property (nonatomic) NSInteger maxContacts;

@property (strong, nonatomic) id <ContactListTextFieldDelegate> contactDelegate;

@end
