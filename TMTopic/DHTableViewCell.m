//
//  DHTableViewCell.m
//  TMTopic
//
//  Created by Derrick Ho on 6/7/14.
//  Copyright (c) 2014 Derrick Ho. All rights reserved.
//

#import "DHTableViewCell.h"

@implementation DHTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
