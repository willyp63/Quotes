//
//  QuotesTableView.m
//  Quotes
//
//  Created by Wil Pirino on 10/14/16.
//  Copyright © 2016 Wil Pirino. All rights reserved.
//

#import "QuotesTableView.h"
#import "QuoteView.h"
#import "constants.h"
#import "QuoteTableViewCell.h"

static CGFloat const TABLE_CELL_PADDING = 8.0f;
static CGFloat const HEARD_BY_LABEL_WIDTH = 92.0f;
static CGFloat const IMAGE_WIDTH_RATIO = 1.0f/8.0f;

static CGFloat const QUOTE_FONT_SIZE = 20.0f;
static CGFloat const HEARD_BY_FONT_SIZE = 18.0f;

@interface QuotesTableView ()

@property (strong, nonatomic) UIActivityIndicatorView *spinner;

@end

@implementation QuotesTableView

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
    self.dataSource = self;
    self.delegate = self;
    
    // setup spinner
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.spinner.color = [UIColor colorWithRed:MAIN_COLOR_RED green:MAIN_COLOR_GREEN blue:MAIN_COLOR_BLUE alpha:1.0f];
    self.spinner.center = self.center;
}

- (void)setShowingLoader:(BOOL)showingLoader {
    _showingLoader = showingLoader;
    
    if (self.showingLoader) {
        [[self superview] addSubview:self.spinner];
        self.hidden = YES;
        self.spinner.hidden = NO;
        [self.spinner startAnimating];
        [self setUserInteractionEnabled:NO];
    } else {
        [self.spinner removeFromSuperview];
        self.hidden = NO;
        self.spinner.hidden = YES;
        [self.spinner stopAnimating];
        [self setUserInteractionEnabled:YES];
    }
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
    
    // calc quote text height
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat quoteWidth =  screenWidth - (IMAGE_WIDTH_RATIO * screenWidth) - (TABLE_CELL_PADDING * 7);
    CGFloat quoteHeight = [QuoteView heightOfText:quote.text withFont:[UIFont fontWithName:MAIN_FONT_NON_BOLD size:QUOTE_FONT_SIZE] width:quoteWidth];
    
    // calc heard by text height
    CGFloat heardByWidth =  quoteWidth - HEARD_BY_LABEL_WIDTH;
    CGFloat heardByHeight = [[quote heardByFullNameList] boundingRectWithSize:CGSizeMake(heardByWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: [UIFont fontWithName:MAIN_FONT size:HEARD_BY_FONT_SIZE]} context:nil].size.height;
    
    return quoteHeight + heardByHeight + (IMAGE_WIDTH_RATIO * screenWidth) + (TABLE_CELL_PADDING * 7);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Quote *quote = self.quotes[indexPath.row];
    QuoteTableViewCell *cell = (QuoteTableViewCell *)[[[NSBundle mainBundle] loadNibNamed:@"QuoteTableViewCell" owner:self options:nil] objectAtIndex:0];
    
    // set text of quote cell
    cell.saidByLabel.text = quote.saidBy.fullName;
    cell.heardByLabel.text = [quote heardByFullNameList];
    cell.heardByLabel.font = [UIFont fontWithName:MAIN_FONT size:HEARD_BY_FONT_SIZE];
    cell.saidAtLabel.text = quote.saidAt;
    cell.quoteView.font = [UIFont fontWithName:MAIN_FONT_NON_BOLD size:QUOTE_FONT_SIZE];
    cell.quoteView.textColor = [UIColor blackColor];
    cell.quoteView.text = quote.text;
    
    // round quote cell image
    cell.saidByImageView.layer.cornerRadius = ([UIScreen mainScreen].bounds.size.width * IMAGE_WIDTH_RATIO) / 2.0f;
    cell.saidByImageView.layer.masksToBounds = YES;
    
    // attempt to set image to said by's profile image
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
    
    // give image a gray border if we could not find an image
    if (!cell.saidByImageView.image) {
        cell.saidByImageView.layer.borderWidth = 2.0f;
        cell.saidByImageView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    }
    
    return cell;
}

@end
