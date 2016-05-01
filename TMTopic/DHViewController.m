//
//  DHViewController.m
//  TMTopic
//
//  Created by Derrick Ho on 5/10/14.
//  Copyright (c) 2014 Derrick Ho. All rights reserved.
//


/**
 Everyone will start with a Default Array of topics.
 A secondary array will get downloaded from the server.
 
 The combination of the two arrays will be the array of which the next table topic will draw from.
 
 The secondary array will be loaded asyncronously.  If it the array that was download is larger than the secondary array, then it will replace the secondary array.  
 
 The secondary array should persist in memory.
 */

#import "DHViewController.h"
#import "DHAppDelegate.h"
#import "DHTableViewCell.h"

NSString *const kName = @"name";
NSString *const kMinValue = @"min_value";
NSString *const kMaxValue = @"max_value";

NSString *const kHost = @"tmtimer328";

NSString *const kOnlineTopicsURL = @"https://raw.githubusercontent.com/wh1pch81n/ToastMasterTopics/master/TMTopic/BigListOfTableTopics";
NSString *const kOnlineSourcesURL =  @"https://raw.githubusercontent.com/wh1pch81n/ToastMasterTopics/master/TMTopic/BigListOfSources";

NSString *const kTopicNumberTotal = @"currArrOfTopicsIndex";
NSString *const kTopicArray = @"arrOfTopics";

NSString *const kTMTimerURL = @"https://itunes.apple.com/us/app/toastmaster-timer/id837916943?ls=1&mt=8";

@interface DHViewController () <NSXMLParserDelegate>

@property (strong, nonatomic) NSMutableDictionary *url_args;
@property (strong, nonatomic) NSArray *arrOfTopics;
@property (strong, nonatomic) NSNumber *currArrOfTopicsIndex;

@property (weak, nonatomic) IBOutlet UILabel *tableTopicLabel;
@property (weak, nonatomic) IBOutlet UIButton *launchTMTimerAppButton;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingGear;

@property (strong, nonatomic) NSArray *arrOfSources;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UILabel *topicNumberOutOfTotal;

@property (weak, nonatomic) IBOutlet UIButton *sourceButton;
@property (weak, nonatomic) IBOutlet UILabel *lastUpdatedLabel;

@end

@implementation DHViewController {
    NSMutableArray *tempArrayOfTopics;
    BOOL canTakeTopic;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	NSDate *date = [[NSUserDefaults standardUserDefaults] objectForKey:kUDLastUpdatedArray];
	if (date) {
		NSDateFormatter *df = [NSDateFormatter new];
		df.dateStyle = NSDateFormatterMediumStyle;
		self.lastUpdatedLabel.text = [NSString stringWithFormat:@"Last Updated: %@", [df stringFromDate:date]];
	} else {
		self.lastUpdatedLabel.text = @"";
	}
	// Do any additional setup after loading the view, typically from a nib.
    self.canDisplayBannerAds = YES;
    
    self.url_args = [@{
                       kName: @"Hello world",
                       kMinValue: @1,
                       kMaxValue: @2
                       } mutableCopy];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [self setArrOfTopics:[NSArray arrayWithArray:[ud objectForKey:kUDPersistentArrOfTopics]]];
	[self setCurrArrOfTopicsIndex:[NSNumber new]];
	
	
	int total = (int)self.arrOfTopics.count;
	int topicNum = [self.currArrOfTopicsIndex intValue];
	[self.topicNumberOutOfTotal setText:[NSString stringWithFormat:@"%d of %d", topicNum + 1, total]];
	[[self tableTopicLabel] setText:self.arrOfTopics[topicNum]];
	[[self url_args] setObject:self.arrOfTopics[topicNum] forKey:kName];
	[self loadLabelWithRandomTopic];
	[self loadSourceListAsync];
	if (self.arrOfTopics.count <= 4) {
		[self launchAsyncURLCall];
	}
	self.tableView.estimatedRowHeight = 44;
	self.tableView.rowHeight = UITableViewAutomaticDimension;
	
}

- (void)canDisplayBannerAds:(BOOL)enableAds {
    if ([self respondsToSelector:@selector(canDisplayBannerAds:)]) {
        self.canDisplayBannerAds = enableAds;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (   [keyPath isEqualToString:NSStringFromSelector(@selector(currArrOfTopicsIndex))]
        || [keyPath isEqualToString:NSStringFromSelector(@selector(arrOfTopics))])
      {
        dispatch_async(dispatch_get_main_queue(), ^{
            int total = (int)self.arrOfTopics.count;
            int topicNum = [self.currArrOfTopicsIndex intValue];
            [self.topicNumberOutOfTotal setText:[NSString stringWithFormat:@"%d of %d", topicNum + 1, total]];
            [[self tableTopicLabel] setText:self.arrOfTopics[topicNum]];
            [[self url_args] setObject:self.arrOfTopics[topicNum] forKey:kName];
        });
    }
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self addObserver:self forKeyPath:NSStringFromSelector(@selector(arrOfTopics))
			  options:NSKeyValueObservingOptionNew context:nil];
	[self addObserver:self forKeyPath:NSStringFromSelector(@selector(currArrOfTopicsIndex))
			  options:NSKeyValueObservingOptionNew context:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[self removeObserver:self forKeyPath:NSStringFromSelector(@selector(currArrOfTopicsIndex))];
	[self removeObserver:self forKeyPath:NSStringFromSelector(@selector(arrOfTopics))];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)tappedRandomButtom:(id)sender {[self loadLabelWithRandomTopic];}
- (IBAction)tappedPrevButtom:(id)sender {[self loadLabelwithPrevTopic];}
- (IBAction)tappedNextButtom:(id)sender {[self loadLabelWithNextTopic];}

- (void)loadLabelWithRandomTopic {
    int last_i = self.currArrOfTopicsIndex.intValue;
    int i;
    // To prevent randomly picking that same number as last time
    do {
        i = arc4random_uniform((u_int32_t)self.arrOfTopics.count);
    } while (last_i == i);
    self.currArrOfTopicsIndex = @(i);
}

- (void)loadLabelWithNextTopic {
    int next = self.currArrOfTopicsIndex.intValue + 1;
    if (next >= self.arrOfTopics.count) {
        next = 0;
    }
    self.currArrOfTopicsIndex = @(next);
}

- (void)loadLabelwithPrevTopic {
    int prev = self.currArrOfTopicsIndex.intValue - 1;
    if (prev < 0) {
        prev = (int)self.arrOfTopics.count -1;
    }
    self.currArrOfTopicsIndex = @(prev);
}

#pragma mark - asyncronous calls

- (void)loadSourceListAsync {
    [self.sourceButton setAlpha:0];
    [self.sourceButton setUserInteractionEnabled:NO];
    __weak typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __strong typeof(weakSelf)strongSelf = weakSelf;
        
        NSError *err = nil;
        
        NSURL *url = [NSURL URLWithString:kOnlineSourcesURL];
        NSString *str = [NSString stringWithContentsOfURL:url
                                                 encoding:NSUTF8StringEncoding error:&err];
        //Check if there was an error or not  if no error then compare the new array to the one you currently have
        if (err || !str) {
            //something wrong happened... try again on next launch.
            return;
        }
        //If it is a different size, then you should update the persistent version
        
#if DEBUG
        NSLog(@"String from URL: \n%@ ", str);
#endif
        
        strongSelf.arrOfSources = [strongSelf parseTextForSources:str];
        __weak typeof(strongSelf)weakSelf = strongSelf;
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf)strongSelf = weakSelf;
            [strongSelf.tableView reloadData];
            [UIView animateWithDuration:0.5 animations:^{
                [strongSelf.sourceButton setAlpha:1];
            } completion:^(BOOL finished) {
                [strongSelf.sourceButton setUserInteractionEnabled:YES];
            }];
        });
    });
}



- (void)loadTableTopicsFromOnline {
    
    NSURL *url = [NSURL URLWithString:kOnlineTopicsURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue new]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               if (connectionError) {
                                   [self.loadingGear performSelectorOnMainThread:@selector(stopAnimating)
                                                                      withObject:nil
                                                                   waitUntilDone:NO];
                               }
                               NSXMLParser *xmlparser = [[NSXMLParser alloc] initWithData:data];
                               xmlparser.delegate = self;
                               
                               if (![xmlparser parse]){
                                   return;
                               }
                               
                               NSArray *newList = tempArrayOfTopics;
#if DEBUG
                               NSLog(@"%@", newList);
#endif
                               if (newList) {
                                   NSArray *currentList = [[NSUserDefaults standardUserDefaults] objectForKey:kUDPersistentArrOfTopics];
                                   if ([self isArrayOfStrings:currentList equalToArrayOfStrings:newList] == NO) {
                                       [[NSUserDefaults standardUserDefaults] setObject:newList forKey:kUDPersistentArrOfTopics];
                                       [self setArrOfTopics:newList];
                                   }
                               }
                               {//stop loading when done
                                   [self.loadingGear performSelectorOnMainThread:@selector(stopAnimating)
                                                                      withObject:nil
                                                                   waitUntilDone:NO];
                               }
                           }];
}

/**
 downloads and saves to the nsuser defaults if needed.
 return 1 if got new data
 0 if got same data 
 -1 if there was an error
 */
- (int)refreshTableTopicsFromOnline {	
	NSURL *url = [NSURL URLWithString:kOnlineTopicsURL];
	NSData *data = [NSData dataWithContentsOfURL:url];
	if (data == nil) {
		return -1;
	}
	
	NSXMLParser *xmlparser = [[NSXMLParser alloc] initWithData:data];
	xmlparser.delegate = self;
	
	if (![xmlparser parse]){
		return -1;
	}
							   
	NSArray *newList = tempArrayOfTopics;
	if (newList == nil) {
		return -1;
	}
#if DEBUG
	NSLog(@"%@", newList);
#endif
	NSArray *currentList = [[NSUserDefaults standardUserDefaults] objectForKey:kUDPersistentArrOfTopics];
	if ([self isArrayOfStrings:currentList equalToArrayOfStrings:newList] == NO) {
		[[NSUserDefaults standardUserDefaults] setObject:newList forKey:kUDPersistentArrOfTopics];
		[[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kUDLastUpdatedArray];
		return 1;
	}
	return 0;
}

- (void)launchAsyncURLCall {
    [self.loadingGear startAnimating];
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[self loadTableTopicsFromOnline];
	});
}

#pragma mark - regular expression regex

- (NSArray *)parseTextForTopics:(NSString *)text {
    NSString *pattern = @"<topic>.*</topic>";
    NSError *err;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&err];
    if (err) {
        return nil;
    }
    NSMutableArray *mutArrayOfTopics = [NSMutableArray new];
 
    [regex enumerateMatchesInString:text
                            options:0
                              range:NSMakeRange(0, text.length)
                         usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                             //remove xml tags
                             NSRange range = NSMakeRange(result.range.location + @"<topic>".length, result.range.length - @"<topic>".length - @"</topic>".length);
#if DEBUG
                             NSLog(@"block result: &%@&\n", [text substringWithRange:range]);
#endif
                             [mutArrayOfTopics addObject:[text substringWithRange:range]];
                         }];
    return mutArrayOfTopics;
}

- (NSArray *)parseTextForSources:(NSString *)text {
    NSString *pattern = @"<source>.*</source>";
    NSError *err;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                           options:0
                                                                             error:&err];
    if (err) {return nil;}
    NSMutableArray *mutArrayOfSources = [NSMutableArray new];
    [regex enumerateMatchesInString:text options:0 range:NSMakeRange(0, text.length)
                         usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                             NSRange range = NSMakeRange(result.range.location + @"<source>".length, result.range.length - @"<source>".length - @"</source>".length);
#if DEBUG
                             NSLog(@"Block result: $%@$\n", [text substringWithRange:range]);
#endif
                             [mutArrayOfSources addObject:[text substringWithRange:range]];
                         }];
    return mutArrayOfSources;
}

#pragma mark - Buttons

- (NSURL *)generateTMTimer328URLScheme {
    NSData *json_data = [NSJSONSerialization dataWithJSONObject:self.url_args options:0 error:nil];
    NSString *json_str = [[NSString alloc] initWithData:json_data encoding:NSUTF8StringEncoding];
    json_str = [NSString stringWithFormat:@"%@:%@", kHost, json_str];
    NSURL *url = [NSURL URLWithString:[json_str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    return url;
}

- (IBAction)tappedLaunchToastmasterTimerButton:(id)sender {
    NSURL *url = [self generateTMTimer328URLScheme];
    
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
#if DEBUG
        NSLog(@"About to open TMTimer via url with query: %@", self.url_args);
#endif
        [[UIApplication sharedApplication] openURL:url];
    } else {
#if DEBUG
        NSLog(@"Could not open TMTimer");
#endif
        url = [NSURL URLWithString:kTMTimerURL relativeToURL:nil];
        [[UIApplication sharedApplication] openURL:url];
    }
}

#pragma mark - comparing Array of strings 

/**
 checks if the lengths of each aray are equal.
 Then checks the type of each object responds to isequaltostring
*/
- (BOOL)isArrayOfStrings:(NSArray *)arr_A equalToArrayOfStrings:(NSArray *)arr_B {
    if (arr_A.count != arr_B.count) {
        return NO;
    }
    
    for (int i = 0; i < arr_A.count; ++i) {
        id A = arr_A[i];
        id B = arr_B[i];
        if ([A respondsToSelector:@selector(isEqualToString:)] && [B respondsToSelector:@selector(isEqualToString:)]) {
            if ([A isEqualToString:B] == NO) {
                return NO;
            }
        } else {
            return NO;
        }
    }
    return YES;
}

#pragma mark - segue

- (IBAction)unwindSourceViewController:(UIStoryboardSegue *)sender {
    
}

#pragma mark - TableView

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
	cell.textLabel.text = self.arrOfSources[indexPath.row];
	cell.textLabel.numberOfLines = 0;
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrOfSources.count;
}


#pragma mark - NSXMLparser

- (void)parserDidStartDocument:(NSXMLParser *)parser {
    tempArrayOfTopics = [NSMutableArray new];
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    if ([elementName isEqualToString:@"topic"]) {
#if DEBUG
        NSLog(@"%@", elementName);
#endif
        canTakeTopic = YES;
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (canTakeTopic) {
        canTakeTopic = NO;
#if DEBUG
        NSLog(@"%@", string);
#endif
        [tempArrayOfTopics addObject:string];
    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    
}

@end
