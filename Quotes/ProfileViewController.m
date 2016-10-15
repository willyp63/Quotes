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
#import "QuotesTableView.h"
#import "QuotesStore.h"

@interface ProfileViewController ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;

@property (weak, nonatomic) IBOutlet UITabBar *feedTabs;

@property (weak, nonatomic) IBOutlet QuotesTableView *quotesTableView;
@property (strong, nonatomic) QuotesStore *quotesStore;
@property (nonatomic) BOOL saidByQuotesNeedsRefreshing;
@property (nonatomic) BOOL heardByQuotesNeedsRefreshing;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // create store and flag both tables as needing refreshing
    self.quotesStore = [[QuotesStore alloc] init];
    _saidByQuotesNeedsRefreshing = _heardByQuotesNeedsRefreshing = YES;
    
    [self setUpView];
}

- (void)setUpView {
    // Configure SaidBy/HeardBy Tabs
    self.feedTabs.tintColor = [UIColor colorWithRed:MAIN_COLOR_RED green:MAIN_COLOR_GREEN blue:MAIN_COLOR_BLUE alpha:1.0];
    self.feedTabs.selectedItem = self.feedTabs.items[0]; // select first tab (said by)
    
    // move tab bar text up to center of bar
    for (UITabBarItem *item in self.feedTabs.items) {
        [item setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:MAIN_FONT size:18.0f]} forState:UIControlStateNormal];
        [item setTitlePositionAdjustment:UIOffsetMake(0, -12)];
    }
    
    
    // Set Name Label from UserDefaults
    NSString *firstName = [[NSUserDefaults standardUserDefaults] objectForKey:FIRST_NAME_KEY];
    NSString *lastName = [[NSUserDefaults standardUserDefaults] objectForKey:LAST_NAME_KEY];
    self.nameLabel.text = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    
    
    // Load Profile Image from documents
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *imageName = [NSString stringWithFormat:@"%@.jpg", [[NSUserDefaults standardUserDefaults] objectForKey:PHONE_NUMBER_KEY]];
    NSString *imagePath = [documentsDirectory stringByAppendingPathComponent:imageName];
    
    // make profile image circular
    self.profileImage.layer.cornerRadius = self.profileImage.frame.size.height / 2.0f;
    self.profileImage.layer.masksToBounds = YES;
    
    // attempt to set image
    if (imagePath) {
        NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
        if (imageData) {
            self.profileImage.image = [UIImage imageWithData:[NSData dataWithContentsOfFile:imagePath]];
        }
    }
    
    // give image a gray border if we could not find an image
    if (!self.profileImage.image){
        self.profileImage.layer.borderWidth = 2.0f;
        self.profileImage.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    }
    
    // give quotes table a top border
    UIView *topBorderView = [[UIView alloc] initWithFrame:CGRectMake(self.quotesTableView.frame.origin.x,
                                                                        self.quotesTableView.frame.origin.y,
                                                                        self.quotesTableView.frame.size.width,
                                                                        0.5f)];
    topBorderView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:topBorderView];
    self.quotesTableView.frame = CGRectMake(self.quotesTableView.frame.origin.x,
                                            self.quotesTableView.frame.origin.y + 0.5f,
                                            self.quotesTableView.frame.size.width,
                                            self.quotesTableView.frame.size.height - 0.5f);
}

- (void)viewWillAppear:(BOOL)animated {
    // flag both tables as needing refreshing
    _saidByQuotesNeedsRefreshing = _heardByQuotesNeedsRefreshing = YES;
    
    [self fetchQuotesForSelectedTab];
}


// Logout Actions
- (IBAction)logout:(id)sender {
    // remove token from keychain
    [[A0SimpleKeychain keychain] setString:@"" forKey:JWT_KEY];
    
    [self performSegueWithIdentifier:@"logout" sender:self];
}

#pragma mark UITabBarDelegate
- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    [self fetchQuotesForSelectedTab];
}

- (void)fetchQuotesForSelectedTab {
    if (self.feedTabs.selectedItem == self.feedTabs.items[0]) {
        [self fetchSaidQuotesWithForceRequest:_saidByQuotesNeedsRefreshing];
    } else {
        [self fetchHeardQuotesWithForceRequest:_heardByQuotesNeedsRefreshing];
    }
}

- (void)fetchSaidQuotesWithForceRequest:(BOOL)forceRequest {
    // flag table as no longer needing refreshing
    _saidByQuotesNeedsRefreshing = NO;
    
    // hide quotes table if there are no quotes currently in the table
    if (!self.quotesTableView.quotes.count) {
        [self.quotesTableView setShowingLoader:YES];
    }
    
    // fetch quotes from store
    [self.quotesStore fetchMySaidQuotesWithForceRequest:forceRequest completionHandler:^(NSArray<Quote *> *quotes, NSError *error) {
        if (!error) {
            // display quotes
            dispatch_async(dispatch_get_main_queue(), ^{
                self.quotesTableView.quotes = quotes;
                [self.quotesTableView setShowingLoader:NO];
                [self.quotesTableView reloadData];
            });
        } else {
            NSLog(@"Error loading quotes!");
        }
    }];
}

- (void)fetchHeardQuotesWithForceRequest:(BOOL)forceRequest {
    // flag table as no longer needing refreshing
    _heardByQuotesNeedsRefreshing = NO;
    
    // hide quotes table if there are no quotes currently in the table
    if (!self.quotesTableView.quotes.count) {
        [self.quotesTableView setShowingLoader:YES];
    }
    
    // fetch quotes from store
    [self.quotesStore fetchMyHeardQuotesWithForceRequest:forceRequest completionHandler:^(NSArray<Quote *> *quotes, NSError *error) {
        if (!error) {
            // display quotes
            dispatch_async(dispatch_get_main_queue(), ^{
                self.quotesTableView.quotes = quotes;
                [self.quotesTableView setShowingLoader:NO];
                [self.quotesTableView reloadData];
            });
        } else {
            NSLog(@"Error loading quotes!");
        }
    }];
}

@end
