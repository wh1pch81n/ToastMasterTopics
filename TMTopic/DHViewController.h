//
//  DHViewController.h
//  TMTopic
//
//  Created by Derrick Ho on 5/10/14.
//  Copyright (c) 2014 Derrick Ho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>

extern NSString *const kName;
extern NSString *const kMinValue;
extern NSString *const kMaxValue;

extern NSString *const kHost;

extern NSString *const kOnlineTopicsURL;

@interface DHViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

- (void)launchAsyncURLCall;
- (int)refreshTableTopicsFromOnline;

@end
