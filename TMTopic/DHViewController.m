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

@interface DHViewController ()

@end

@implementation DHViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)loadDefaultTableTopics {
    #warning needs implementing
}

- (void)loadTableTopicsFromOnline {
    #warning needs implementing
    NSError *err = nil;
    NSString *str = [NSString stringWithContentsOfURL:nil encoding:NSUTF8StringEncoding error:&err];
    //Check if there was an error or not  if no error then compare 
}

- (void)updateTableTopic:(NSString *)topic {
    #warning This is where you should update the
}

- (void)launchAsyncURLCall {
    [NSThread detachNewThreadSelector:@selector(loadTableTopicsFromOnline) toTarget:self withObject:nil];
}

- (IBAction)tappedLaunchToastmasterTimerButton:(id)sender {
    NSDictionary *url_args = @{
                               @"name": @"Hello world",
                               @"min_value": @1,
                               @"max_value": @2
                               };
    NSData *json_data = [NSJSONSerialization dataWithJSONObject:url_args options:0 error:nil];
    NSString *json_str = [[NSString alloc] initWithData:json_data encoding:NSUTF8StringEncoding];
    json_str = [NSString stringWithFormat:@"%@:%@", @"tmtimer328", json_str];
    NSURL *url = [NSURL URLWithString:[json_str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
#if DEBUG
        NSLog(@"About to open TMTimer via url");
#endif
        [[UIApplication sharedApplication] openURL:url];
    } else {
#if DEBUG
        NSLog(@"Could not open TMTimer");
#endif
    }
}

@end
