//
//  FeedViewController.m
//  Quotes
//
//  Created by Wil Pirino on 10/9/16.
//  Copyright © 2016 Wil Pirino. All rights reserved.
//

#import "FeedViewController.h"
#import "SearchButton.h"
#import "Quote.h"
#import "constants.h"
#import "QuotesApiUtil.h"
#import "QuoteTableViewCell.h"
#import "ContactBook.h"

static CGFloat const ANIMATION_TIME = 0.5f;
static CGFloat const UI_PADDING = 20.0f;
static CGFloat const SEARCH_VIEW_HEIGHT = 40.0f;

static CGFloat const TABLE_CELL_EXTRA_HIEGHT = 100.0f;
static CGFloat const HEARD_BY_LABEL_WIDTH = 90.0f;
static CGFloat const QUOTE_WIDTH_RATIO = 0.95f;

static CGFloat const QUOTE_FONT_SIZE = 20.0f;
static CGFloat const HEARD_BY_FONT_SIZE = 18.0f;

@interface FeedViewController ()

@property (weak, nonatomic) IBOutlet UIView *titleView;
@property (weak, nonatomic) IBOutlet SearchButton *searchButton;

@property (strong, nonatomic) UIView *searchView;
@property (strong, nonatomic) UITextField *searchField;
@property (strong, nonatomic) UIButton *cancelSearchButton;

@property (weak, nonatomic) IBOutlet UITableView *quotesTableView;
@property (strong, nonatomic) NSMutableArray<Quote *> *quotes;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@end

@implementation FeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [self fetchQuotes];
}

- (IBAction)showSearchField:(id)sender {
    [self slideTitleViewLeft];
    [self animateInSearchView];
}

- (void)animateInSearchView {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    CGFloat searchButtonWidth = self.searchButton.frame.size.width;
    
    CGRect startAnimationFrame = CGRectMake(screenWidth + UI_PADDING, statusBarHeight, screenWidth - searchButtonWidth - (UI_PADDING * 2), SEARCH_VIEW_HEIGHT);
    CGRect endAnimationFrame = CGRectMake(searchButtonWidth + UI_PADDING, statusBarHeight, startAnimationFrame.size.width, SEARCH_VIEW_HEIGHT);
    
    self.searchView = [[UIView alloc] initWithFrame:startAnimationFrame];
    self.searchView.backgroundColor = [UIColor redColor];
    
    [self.view addSubview:self.searchView];
    [UIView animateWithDuration:ANIMATION_TIME animations:^{
        self.searchView.frame = endAnimationFrame;
    }completion:^(BOOL finished){
        
    }];
}

- (void)slideTitleViewLeft {
    CGRect currFrame = self.titleView.frame;
    CGFloat searchButtonWidth = self.searchButton.frame.size.width;
    CGRect endAnimationFrame = CGRectMake(UI_PADDING + searchButtonWidth - currFrame.size.width, currFrame.origin.y, currFrame.size.width, currFrame.size.height);
    
    [UIView animateWithDuration:ANIMATION_TIME animations:^{
        self.titleView.frame = endAnimationFrame;
    }completion:^(BOOL finished){
        
    }];
}

#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.quotes.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    Quote *quote = self.quotes[indexPath.row];
    
    // calc quote height
    UIFont *quoteFont = [UIFont fontWithName:MAIN_FONT_NON_BOLD size:QUOTE_FONT_SIZE];
    CGFloat quoteWidth = [UIScreen mainScreen].bounds.size.width * QUOTE_WIDTH_RATIO;
    CGRect quoteRect = [quote.text boundingRectWithSize:CGSizeMake(quoteWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: quoteFont} context:nil];
    
    // calc heard by height
    UIFont *heardByFont = [UIFont fontWithName:MAIN_FONT size:HEARD_BY_FONT_SIZE];
    CGFloat heardByWidth = quoteWidth - HEARD_BY_LABEL_WIDTH;
    CGRect heardByRect = [quote.text boundingRectWithSize:CGSizeMake(heardByWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: heardByFont} context:nil];
    
    return quoteRect.size.height + heardByRect.size.height + TABLE_CELL_EXTRA_HIEGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Quote *quote = self.quotes[indexPath.row];
    QuoteTableViewCell *cell = (QuoteTableViewCell *)[[[NSBundle mainBundle] loadNibNamed:@"QuoteTableViewCell" owner:self options:nil] objectAtIndex:0];
    
    cell.saidByLabel.text = quote.saidBy.fullName;
    cell.heardByLabel.text = [quote heardByFullNameList];
    cell.heardByLabel.font = [UIFont fontWithName:MAIN_FONT size:HEARD_BY_FONT_SIZE];
    cell.saidAtLabel.text = quote.saidAt;
    cell.quoteView.font = [UIFont fontWithName:MAIN_FONT_NON_BOLD size:QUOTE_FONT_SIZE];
    cell.quoteView.textColor = [UIColor blackColor];
    cell.quoteView.text = quote.text;
    
    NSString *userPhoneNumber = [[NSUserDefaults standardUserDefaults] objectForKey:PHONE_NUMBER_KEY];
    if ([quote.saidBy.phoneNumber isEqualToString:userPhoneNumber]) {
        // load profile image
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *imageName = [NSString stringWithFormat:@"%@.jpg", userPhoneNumber];
        NSString *imagePath = [documentsDirectory stringByAppendingPathComponent:imageName];
        if (imagePath) {
            cell.saidByImageView.image = [UIImage imageWithData:[NSData dataWithContentsOfFile:imagePath]];
            cell.saidByImageView.layer.cornerRadius = 25.0f;
            cell.saidByImageView.layer.masksToBounds = YES;
        }
    }
    
    return cell;
}

- (void)fetchQuotes {
    if (!self.quotes.count) {
        [self hideQuotesTable];
    }
    
    NSLog(@"Loading quotes...");
    [QuotesApiUtil getMyQuotesWithCompletionHandler:^(NSDictionary *jsonData, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSArray *quotes = [jsonData objectForKey:@"quotes"];
            self.quotes = [NSMutableArray arrayWithCapacity:quotes.count];
            for (NSDictionary *quoteDict in quotes) {
                [self.quotes addObject:[[Quote alloc] initWithDictionary:quoteDict]];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
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

#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

@end
