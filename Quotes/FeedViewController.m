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
#import "QuoteView.h"

static CGFloat const ANIMATION_TIME = 0.5f;
static CGFloat const UI_PADDING = 20.0f;
static CGFloat const SEARCH_VIEW_HEIGHT = 40.0f;

static CGFloat const TABLE_CELL_PADDING = 8.0f;
static CGFloat const HEARD_BY_LABEL_WIDTH = 92.0f;
static CGFloat const IMAGE_WIDTH_RATIO = 1.0f/8.0f;

static CGFloat const QUOTE_FONT_SIZE = 20.0f;
static CGFloat const HEARD_BY_FONT_SIZE = 18.0f;

@interface FeedViewController ()

@property (weak, nonatomic) IBOutlet UIView *titleView;
@property (weak, nonatomic) IBOutlet SearchButton *searchButton;

@property (strong, nonatomic) SearchView *searchView;
@property (nonatomic) CGRect titleViewInitialFrame;
@property (nonatomic) CGRect searchViewInitialFrame;

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
    [self animateInSearchView];
}

- (void)animateInSearchView {
    // make search button inactive
    [self.searchButton setUserInteractionEnabled:NO];
    
    // slide title view left
    CGRect currFrame = self.titleView.frame;
    CGFloat searchButtonWidth = self.searchButton.frame.size.width;
    self.titleViewInitialFrame = self.titleView.frame;
    CGRect endAnimationFrame = CGRectMake(UI_PADDING + searchButtonWidth - currFrame.size.width, currFrame.origin.y, currFrame.size.width, currFrame.size.height);
    
    [UIView animateWithDuration:ANIMATION_TIME animations:^{
        self.titleView.frame = endAnimationFrame;
    }completion:nil];
    
    // animate in search view
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    
    self.searchViewInitialFrame = CGRectMake(screenWidth + UI_PADDING, statusBarHeight, screenWidth - searchButtonWidth - (UI_PADDING * 2), SEARCH_VIEW_HEIGHT);
    endAnimationFrame = CGRectMake(searchButtonWidth + UI_PADDING, statusBarHeight, self.searchViewInitialFrame.size.width, SEARCH_VIEW_HEIGHT);
    
    self.searchView = [[SearchView alloc] initWithFrame:self.searchViewInitialFrame];
    self.searchView.delegate = self;
    
    [self.view addSubview:self.searchView];
    [UIView animateWithDuration:ANIMATION_TIME animations:^{
        self.searchView.frame = endAnimationFrame;
    }completion:nil];
}

- (void)animateOutSearchView {
    // slide title view right
    [UIView animateWithDuration:ANIMATION_TIME animations:^{
        self.titleView.frame = self.titleViewInitialFrame;
    }completion:nil];
    
    // animate out search view
    [UIView animateWithDuration:ANIMATION_TIME animations:^{
        self.searchView.frame = self.searchViewInitialFrame;
    }completion:^(BOOL finished){
        [self.searchView removeFromSuperview];
        
        // make search button active
        [self.searchButton setUserInteractionEnabled:YES];
    }];
}

#pragma mark SearchViewDelegate
- (void)searchView:(id)searchView didCancelWithText:(NSString *)text {
    [self animateOutSearchView];
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
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat quoteWidth =  screenWidth - (IMAGE_WIDTH_RATIO * screenWidth) - (TABLE_CELL_PADDING * 6);
    CGFloat quoteHeight = [QuoteView heightOfText:quote.text withFont:[UIFont fontWithName:MAIN_FONT_NON_BOLD size:QUOTE_FONT_SIZE] width:quoteWidth];
    
    // calc heard by height
    CGFloat heardByWidth =  quoteWidth - HEARD_BY_LABEL_WIDTH;
    CGFloat heardByHeight = [[quote heardByFullNameList] boundingRectWithSize:CGSizeMake(heardByWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: [UIFont fontWithName:MAIN_FONT size:HEARD_BY_FONT_SIZE]} context:nil].size.height;
    
    return quoteHeight + heardByHeight + (IMAGE_WIDTH_RATIO * screenWidth) + (TABLE_CELL_PADDING * 7);
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
