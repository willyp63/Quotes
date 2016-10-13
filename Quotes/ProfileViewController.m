//
//  ProfileViewController.m
//  Quotes
//
//  Created by Wil Pirino on 10/9/16.
//  Copyright © 2016 Wil Pirino. All rights reserved.
//

#import "ProfileViewController.h"
#import "A0SimpleKeychain.h"
#import "AuthApiUtil.h"
#import "constants.h"
#import "Quote.h"
#import "QuotesApiUtil.h"
#import "QuoteTableViewCell.h"

static CGFloat const TABLE_CELL_PADDING = 8.0f;
static CGFloat const HEARD_BY_LABEL_WIDTH = 92.0f;
static CGFloat const IMAGE_WIDTH_RATIO = 1.0f/8.0f;

static CGFloat const QUOTE_FONT_SIZE = 20.0f;
static CGFloat const HEARD_BY_FONT_SIZE = 18.0f;

@interface ProfileViewController ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;

@property (weak, nonatomic) IBOutlet UITabBar *feedTabs;

@property (weak, nonatomic) IBOutlet UITableView *quotesTableView;
@property (strong, nonatomic) NSMutableArray<Quote *> *saidQuotes;
@property (strong, nonatomic) NSMutableArray<Quote *> *heardQuotes;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // config saidBy/heardBy tabs
    self.feedTabs.tintColor = [UIColor colorWithRed:MAIN_COLOR_RED green:MAIN_COLOR_GREEN blue:MAIN_COLOR_BLUE alpha:1.0];
    self.feedTabs.selectedItem = self.feedTabs.items[0];
    for (UITabBarItem *item in self.feedTabs.items) {
        [item setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:MAIN_FONT size:18.0f]} forState:UIControlStateNormal];
        [item setTitlePositionAdjustment:UIOffsetMake(0, -12)];
    }
    
    // set name label from user defaults
    NSString *firstName = [[NSUserDefaults standardUserDefaults] objectForKey:FIRST_NAME_KEY];
    NSString *lastName = [[NSUserDefaults standardUserDefaults] objectForKey:LAST_NAME_KEY];
    self.nameLabel.text = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    
    // load profile image
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *imageName = [NSString stringWithFormat:@"%@.jpg", [[NSUserDefaults standardUserDefaults] objectForKey:PHONE_NUMBER_KEY]];
    NSString *imagePath = [documentsDirectory stringByAppendingPathComponent:imageName];
    
    self.profileImage.layer.cornerRadius = self.profileImage.frame.size.height / 2.0f;
    self.profileImage.layer.masksToBounds = YES;
    if (imagePath) {
        self.profileImage.image = [UIImage imageWithData:[NSData dataWithContentsOfFile:imagePath]];
    } else {
        self.profileImage.layer.borderWidth = 2.0f;
        self.profileImage.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    if (self.feedTabs.selectedItem == self.feedTabs.items[0]) {
        [self fetchSaidQuotes];
    } else {
        [self fetchHeardQuotes];
    }
}

- (IBAction)logout:(id)sender {
    // remove token from keychain
    [[A0SimpleKeychain keychain] setString:@"" forKey:JWT_KEY];
    
    [self performSegueWithIdentifier:@"logout" sender:self];
}

#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.feedTabs.selectedItem == self.feedTabs.items[0]) {
        return self.saidQuotes.count;
    } else {
        return self.heardQuotes.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    Quote *quote;
    if (self.feedTabs.selectedItem == self.feedTabs.items[0]) {
        quote = self.saidQuotes[indexPath.row];
    } else {
        quote = self.heardQuotes[indexPath.row];
    }
    
    // calc quote height
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat quoteWidth =  screenWidth - (IMAGE_WIDTH_RATIO * screenWidth) - (TABLE_CELL_PADDING * 3);
    CGFloat quoteHeight = [QuoteView heightOfText:quote.text withFont:[UIFont fontWithName:MAIN_FONT_NON_BOLD size:QUOTE_FONT_SIZE] width:quoteWidth];
    
    // calc heard by height
    CGFloat heardByWidth =  quoteWidth - HEARD_BY_LABEL_WIDTH;
    CGFloat heardByHeight = [[quote heardByFullNameList] boundingRectWithSize:CGSizeMake(heardByWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: [UIFont fontWithName:MAIN_FONT size:HEARD_BY_FONT_SIZE]} context:nil].size.height;
    
    return quoteHeight + heardByHeight + (IMAGE_WIDTH_RATIO * screenWidth) + (TABLE_CELL_PADDING * 7);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Quote *quote;
    if (self.feedTabs.selectedItem == self.feedTabs.items[0]) {
        quote = self.saidQuotes[indexPath.row];
    } else {
        quote = self.heardQuotes[indexPath.row];
    }
    
    QuoteTableViewCell *cell = (QuoteTableViewCell *)[[[NSBundle mainBundle] loadNibNamed:@"QuoteTableViewCell" owner:self options:nil] objectAtIndex:0];
    
    cell.saidByLabel.text = quote.saidBy.fullName;
    cell.heardByLabel.text = [quote heardByFullNameList];
    cell.heardByLabel.font = [UIFont fontWithName:MAIN_FONT size:HEARD_BY_FONT_SIZE];
    cell.saidAtLabel.text = quote.saidAt;
    cell.quoteView.font = [UIFont fontWithName:MAIN_FONT_NON_BOLD size:QUOTE_FONT_SIZE];
    cell.quoteView.textColor = [UIColor blackColor];
    cell.quoteView.text = quote.text;
    
    cell.saidByImageView.layer.cornerRadius = ([UIScreen mainScreen].bounds.size.width * IMAGE_WIDTH_RATIO) / 2.0f;
    cell.saidByImageView.layer.masksToBounds = YES;
    
    NSString *userPhoneNumber = [[NSUserDefaults standardUserDefaults] objectForKey:PHONE_NUMBER_KEY];
    if ([quote.saidBy.phoneNumber isEqualToString:userPhoneNumber]) {
        // load profile image
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *imageName = [NSString stringWithFormat:@"%@.jpg", userPhoneNumber];
        NSString *imagePath = [documentsDirectory stringByAppendingPathComponent:imageName];
        if (imagePath) {
            cell.saidByImageView.image = [UIImage imageWithData:[NSData dataWithContentsOfFile:imagePath]];
        }
    }
    
    if (!cell.saidByImageView.image) {
        cell.saidByImageView.layer.borderWidth = 2.0f;
        cell.saidByImageView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    }
    
    return cell;
}

- (void)fetchSaidQuotes {
    if (!self.saidQuotes.count) {
        [self hideQuotesTable];
    }
    
    NSLog(@"Loading quotes...");
    [QuotesApiUtil getMySaidQuotesWithCompletionHandler:^(NSDictionary *jsonData, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSArray *quotes = [jsonData objectForKey:@"quotes"];
            NSMutableArray *saidQuotes = [NSMutableArray arrayWithCapacity:quotes.count];
            for (NSDictionary *quoteDict in quotes) {
                [saidQuotes addObject:[[Quote alloc] initWithDictionary:quoteDict]];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.saidQuotes = saidQuotes;
                [self showQuotesTable];
            });
        } else {
            NSLog(@"Error loading quotes!");
        }
    }];
}

- (void)fetchHeardQuotes {
    if (!self.heardQuotes.count) {
        [self hideQuotesTable];
    }
    
    NSLog(@"Loading quotes...");
    [QuotesApiUtil getMyHeardQuotesWithCompletionHandler:^(NSDictionary *jsonData, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSArray *quotes = [jsonData objectForKey:@"quotes"];
            NSMutableArray *heardQuotes = [NSMutableArray arrayWithCapacity:quotes.count];
            for (NSDictionary *quoteDict in quotes) {
                [heardQuotes addObject:[[Quote alloc] initWithDictionary:quoteDict]];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.heardQuotes = heardQuotes;
                [self showQuotesTable];
            });
        } else {
            NSLog(@"Error loading quotes!");
        }
    }];
}

- (void)hideQuotesTable {
    // show spinner
    self.spinner.hidden = NO;
    [self.spinner startAnimating];
    [self.view setUserInteractionEnabled:NO];
    
    self.quotesTableView.hidden = YES;
}


- (void)showQuotesTable {
    // hide spinner
    self.spinner.hidden = YES;
    [self.spinner stopAnimating];
    [self.view setUserInteractionEnabled:YES];
    
    self.quotesTableView.hidden = NO;
    [self.quotesTableView reloadData];
}

#pragma mark UITabBarDelegate
- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    if (item == self.feedTabs.items[0]) {
        [self fetchSaidQuotes];
    } else {
        [self fetchHeardQuotes];
    }
}

@end
