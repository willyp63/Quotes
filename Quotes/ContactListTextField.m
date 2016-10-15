//
//  ContactListTextField.m
//  Quotes
//
//  Created by Wil Pirino on 10/9/16.
//  Copyright © 2016 Wil Pirino. All rights reserved.
//

#import "ContactListTextField.h"
#import "ContactBook.h"
#import "constants.h"

static NSString *const REUSE_CELL_ID = @"suggestion";
static CGFloat const TABLE_CELL_HIEGHT = 60.0f;
static int const MAX_NUM_CELLS = 4;
static CGFloat const FIELD_HIEGHT = 45.0f;
static CGFloat const DROP_DOWN_LEFT_OFFSET = 4.0f;


@interface ContactListTextField ()

@property (strong, nonatomic) UITableView *suggestionsView;
@property (strong, nonatomic) NSArray<Contact *> *suggestions;

@end


@implementation ContactListTextField

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self customSetup];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self customSetup];
    }
    return self;
}

-(void)customSetup {
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, FIELD_HIEGHT);
    self.borderStyle = UITextBorderStyleNone;
    self.backgroundColor = [UIColor whiteColor];
    self.font = [UIFont fontWithName:@"Helvetica" size:18];
    
    // add left padding unless text is centered
    if (self.textAlignment != NSTextAlignmentCenter) {
        UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, FIELD_HIEGHT)];
        self.leftView = paddingView;
        self.leftViewMode = UITextFieldViewModeAlways;
    }
    
    // ContactListTextField setup
    // make self delegate
    self.delegate = self;
    
    // setup suggestions table right below text field
    CGFloat tableHieght = [self.suggestions count] * TABLE_CELL_HIEGHT;
    CGRect suggestionsFrame = CGRectMake(DROP_DOWN_LEFT_OFFSET * 2, self.frame.size.height - DROP_DOWN_LEFT_OFFSET, self.frame.size.width, tableHieght);
    self.suggestionsView = [[UITableView alloc] initWithFrame:suggestionsFrame style:UITableViewStylePlain];
    self.suggestionsView.delegate = self;
    self.suggestionsView.dataSource = self;
    self.suggestionsView.scrollEnabled = NO;
    [self hideSuggestions];
    [self addSubview:self.suggestionsView];
    
    // init contacts
    self.contacts = [NSMutableArray arrayWithCapacity:32];
    self.blackListContacts = [NSMutableArray arrayWithCapacity:32];
    self.contactRanges = [NSMutableArray arrayWithCapacity:32];
}


#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // limit number of rows
    return MIN([self.suggestions count], MAX_NUM_CELLS);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return TABLE_CELL_HIEGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Contact *contact = self.suggestions[indexPath.row];
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"suggestion"];
    
    // set textLabel to contact's full name
    cell.textLabel.text = contact.fullName;
    cell.textLabel.font = [UIFont fontWithName:MAIN_FONT size:18.0f];
    cell.textLabel.textColor = [UIColor grayColor];
    
    //style cell
    cell.layer.borderWidth = 1.0f;
    cell.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    cell.backgroundColor = [UIColor whiteColor];
    
    return cell;
}

#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Contact *selectedContact = self.suggestions[indexPath.row];
    [self addContact:selectedContact];
}

# pragma mark UITextFieldDelegate
- (void) textFieldDidEndEditing:(UITextField *)textField {
    [self hideSuggestions];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)showSuggestions {
    // resize table
    CGFloat tableHieght = MIN([self.suggestions count], MAX_NUM_CELLS) * TABLE_CELL_HIEGHT;
    CGRect suggestionsFrame = CGRectMake(DROP_DOWN_LEFT_OFFSET * 2, self.frame.size.height - DROP_DOWN_LEFT_OFFSET, self.frame.size.width, tableHieght);
    self.suggestionsView.frame = suggestionsFrame;
    
    // show and reload data
    self.suggestionsView.hidden = NO;
    [self.suggestionsView reloadData];
}

- (void)hideSuggestions {
    self.suggestionsView.hidden = YES;
}

// UITextFieldDelegate Methods
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // dont allow typing if max number of contacts is reached
    if (self.maxContacts && self.contacts.count >= self.maxContacts) {
        if (![string isEqualToString:@""]) {
            return NO;
        }
    }
    
    // remove any edited contacts from lists and from text
    NSString *text = [NSString stringWithString:self.text];
    for (int i = 0; i < self.contactRanges.count; i++) {
        NSRange contactRange = self.contactRanges[i].rangeValue;
        
        // check if update is within range
        if (NSLocationInRange(range.location, contactRange)) {
            Contact *contactToRemove = self.contacts[i];
            
            // remove from lists and from text
            text = [text stringByReplacingCharactersInRange:contactRange withString:@""];
            [self.contactRanges removeObjectAtIndex:i];
            [self.contacts removeObjectAtIndex:i];
            
            // notify delegate
            [self.contactDelegate contactField:self didRemoveContact:contactToRemove];
            
            i--;
        }
    }
    
    // a contact was removed, just then update text and return
    if (![text isEqualToString:self.text]) {
        self.text = text;
        return NO;
    }
    
    // get new new text after update
    NSString *newText = [self editingText];
    NSRange offsetRange = NSMakeRange(range.location - [self beginEditingIndex], range.length);
    newText = [newText stringByReplacingCharactersInRange:offsetRange withString:string];
    
    // trim leading space
    if (newText.length && [newText characterAtIndex:0] == ' ') {
        newText = [newText substringFromIndex:1];
    }
    
    // hide if there is no text
    if ([newText isEqualToString:@""]) {
        [self hideSuggestions];
    } else {
        // grab matching contacts
        [ContactBook contactsWith:newText completionHandler:^(NSArray<Contact *> *contacts) {
            //filter to suggestion not added yet
            contacts = [self unaddedContactsWithContacts:contacts];
            
            // update suggestions
            self.suggestions = contacts;
            if ([self.suggestions count] == 0) {
                [self hideSuggestions];
            } else {
                // look for matching contact
                Contact *match = [self suggestionMatchingString:newText];
                if (match) {
                    // add contact
                    [self addContact:match];
                    self.text = [self.text substringToIndex:self.text.length - 1];
                } else {
                    [self showSuggestions];
                }
            }
        }];
    }
    return YES;
}

// helper methods
- (NSArray<Contact *> *)unaddedContactsWithContacts:(NSArray<Contact *> *)contacts {
    NSMutableArray<Contact *> *unaddedContacts = [[NSMutableArray alloc] initWithCapacity:contacts.count];
    for (Contact *contact in contacts) {
        if (![self contact:contact inList:self.contacts] && ![self contact:contact inList:self.blackListContacts]) {
            [unaddedContacts addObject:contact];
        }
    }
    return unaddedContacts;
}

- (BOOL)contact:(Contact *)contact inList:(NSArray<Contact *> *)contactList {
    for (Contact *otherContact in contactList) {
        if ([otherContact.phoneNumber isEqualToString:contact.phoneNumber]) {
            return YES;
        }
    }
    return NO;
}

- (Contact *)suggestionMatchingString:(NSString *)fullName {
    Contact *match = nil;
    for (Contact *contact in self.suggestions) {
        if ([fullName caseInsensitiveCompare:[NSString stringWithFormat:@"%@ ", contact.fullName]] == NSOrderedSame ||
            [fullName caseInsensitiveCompare:[NSString stringWithFormat:@"%@, ", contact.fullName]] == NSOrderedSame) {
            match = contact;
            break;
        }
    }
    return match;
}

- (void)addContact:(Contact *)contact {
    // add to contacts
    [self.contacts addObject:contact];
    
    // add to ranges
    NSInteger length = contact.fullName.length + 2;
    [self.contactRanges addObject:[NSValue valueWithRange:NSMakeRange([self beginEditingIndex], length)]];
    
    // update UI
    [self updateTextAfterContactAddition];
    [self hideSuggestions];
    
    // notify delegate
    [self.contactDelegate contactField:self didAddContact:contact];
}

- (void)updateTextAfterContactAddition {
    NSString *text = @"";
    for (int i = 0; i < self.contacts.count; i++) {
        Contact *contact = self.contacts[i];
        if (self.maxContacts - 1 == i) {
            text = [text stringByAppendingString:[NSString stringWithFormat:@"%@  ", contact.fullName]];
        } else {
            text = [text stringByAppendingString:[NSString stringWithFormat:@"%@, ", contact.fullName]];
        }
    }
    self.text = text;
}

- (NSString *)editingText {
    if (self.contactRanges.count) {
        NSRange lastRange = [[self.contactRanges objectAtIndex:self.contactRanges.count - 1] rangeValue];
        return [self.text substringFromIndex:(lastRange.location + lastRange.length)];
    } else {
        return self.text;
    }
    
}

- (NSInteger)beginEditingIndex {
    if (self.contactRanges.count) {
        NSRange lastRange = [[self.contactRanges objectAtIndex:self.contactRanges.count - 1] rangeValue];
        return lastRange.location + lastRange.length;
    } else {
        return 0;
    }
    
}

// extend hit area to drop down
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    CGPoint pointForTargetView = [self.suggestionsView convertPoint:point fromView:self];
    if (CGRectContainsPoint(self.suggestionsView.bounds, pointForTargetView)) {
        return [self.suggestionsView hitTest:pointForTargetView withEvent:event];
    }
    return [super hitTest:point withEvent:event];
}

@end
