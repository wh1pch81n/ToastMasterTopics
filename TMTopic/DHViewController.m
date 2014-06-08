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

@interface DHViewController ()

@property (strong, nonatomic) NSMutableDictionary *url_args;
@property (strong, nonatomic) NSArray *arrOfTopics;
@property (strong, nonatomic) NSNumber *currArrOfTopicsIndex;

@property (weak, nonatomic) IBOutlet UILabel *tableTopicLabel;
@property (weak, nonatomic) IBOutlet UIButton *launchTMTimerAppButton;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingGear;

@property (strong, nonatomic) NSArray *arrOfSources;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UILabel *topicNumberOutOfTotal;

@end

@implementation DHViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
   
    self.url_args = [@{
                       kName: @"Hello world",
                       kMinValue: @1,
                       kMaxValue: @2
                       } mutableCopy];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [self setArrOfTopics:[NSArray arrayWithArray:[ud objectForKey:kUDPersistentArrOfTopics]]];
    [self addObserver:self forKeyPath:kTopicArray
                          options:NSKeyValueObservingOptionNew context:nil];
    [self setCurrArrOfTopicsIndex:[NSNumber new]];
    [self addObserver:self forKeyPath:kTopicNumberTotal
                                   options:NSKeyValueObservingOptionNew context:nil];
    
    
    [self loadLabelWithRandomTopic];
    
    if ([[UIApplication sharedApplication] canOpenURL:[self generateTMTimer328URLScheme]] == NO) {
        [[self launchTMTimerAppButton] setHidden:YES];
    } else {
        [[self launchTMTimerAppButton] setHidden:NO];
    }
    
    [self loadSourceListAsync];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:kTopicNumberTotal] || [keyPath isEqualToString:kTopicArray]) {
        int total = (int)self.arrOfTopics.count;
        int topicNum = [self.currArrOfTopicsIndex intValue];
        [self.topicNumberOutOfTotal setText:[NSString stringWithFormat:@"%d of %d", topicNum + 1, total]];
        [[self tableTopicLabel] setText:self.arrOfTopics[topicNum]];
        [[self url_args] setObject:self.arrOfTopics[topicNum] forKey:kName];
    }
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
        i = arc4random() % self.arrOfTopics.count;
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
        prev = self.arrOfTopics.count -1;
    }
    self.currArrOfTopicsIndex = @(prev);
}

#pragma mark - asyncronous calls

- (void)loadSourceListAsync {
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
        });
    });
}



- (void)loadTableTopicsFromOnline {
    
    
    NSError *err = nil;
    
    NSURL *url = [NSURL URLWithString:kOnlineTopicsURL];
    NSString *str = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&err];
    //Check if there was an error or not  if no error then compare the new array to the one you currently have
    if (err || !str) {
        //something wrong happened... try again on next launch.
        return;
    }
    //If it is a different size, then you should update the persistent version
    
#if DEBUG
    NSLog(@"String from URL: \n%@ ", str);
#endif
    
    NSArray *newList = [self parseTextForTopics:str];
    if (newList) {
        NSArray *currentList = [[NSUserDefaults standardUserDefaults] objectForKey:kUDPersistentArrOfTopics];
        if ([self isArrayOfStrings:currentList equalToArrayOfStrings:newList] == NO) {
            [[NSUserDefaults standardUserDefaults] setObject:newList forKey:kUDPersistentArrOfTopics];
            [self setArrOfTopics:newList];
        }
    }
    
    [self.loadingGear performSelectorOnMainThread:@selector(stopAnimating)
                                       withObject:nil
                                    waitUntilDone:NO];
}

- (void)launchAsyncURLCall {
    [self.loadingGear startAnimating];
    [NSThread detachNewThreadSelector:@selector(loadTableTopicsFromOnline) toTarget:self withObject:nil];
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
        //TODO: Should launch the app store webpage.  Do it later.
#endif
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
    DHTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"sourceCell" forIndexPath:indexPath];
    
    [cell.sourceURLTextView setText:self.arrOfSources[indexPath.row]];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrOfSources.count;
}

@end
