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

NSString *const kName = @"name";
NSString *const kMinValue = @"min_value";
NSString *const kMaxValue = @"max_value";

NSString *const kHost = @"tmtimer328";

@interface DHViewController ()

@property (strong, nonatomic) NSMutableDictionary *url_args;
@property (strong, nonatomic) NSArray *arrOfTopics;

@property (weak, nonatomic) IBOutlet UILabel *tableTopicLabel;
@property (weak, nonatomic) IBOutlet UIButton *launchTMTimerAppButton;
@property (weak, nonatomic) IBOutlet UIButton *buttonNewTopic;

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
    [self loadLabelWithTopic];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self launchAsyncURLCall];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadLabelWithTopic {
    int i = arc4random() % self.arrOfTopics.count;
    [[self tableTopicLabel] setText:self.arrOfTopics[i]];
    
    [self.url_args setObject:self.arrOfTopics[i] forKey:kName];
}

#pragma mark - asyncronous calls

- (void)loadTableTopicsFromOnline {
    #warning needs implementing
    NSError *err = nil;
    NSString *str = [NSString stringWithContentsOfURL:nil encoding:NSUTF8StringEncoding error:&err];
    //Check if there was an error or not  if no error then compare the new array to the one you currently have
    //If it is a different size, then you should update the persistent version
}

- (void)launchAsyncURLCall {
    [NSThread detachNewThreadSelector:@selector(loadTableTopicsFromOnline) toTarget:self withObject:nil];
}


#pragma mark - Buttons

- (IBAction)tappedLaunchToastmasterTimerButton:(id)sender {

    NSData *json_data = [NSJSONSerialization dataWithJSONObject:self.url_args options:0 error:nil];
    NSString *json_str = [[NSString alloc] initWithData:json_data encoding:NSUTF8StringEncoding];
    json_str = [NSString stringWithFormat:@"%@:%@", kHost, json_str];
    NSURL *url = [NSURL URLWithString:[json_str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
#if DEBUG
        NSLog(@"About to open TMTimer via url with query: %@", self.url_args);
#endif
        [[UIApplication sharedApplication] openURL:url];
    } else {
#if DEBUG
        NSLog(@"Could not open TMTimer");
#endif
    }
}

- (IBAction)tappedButtonNewTopic:(id)sender {
    [self loadLabelWithTopic];
}


@end
