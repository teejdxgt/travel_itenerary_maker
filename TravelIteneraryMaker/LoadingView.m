//
//  LoadingView.m
//  TravelIteneraryMaker
//
//  Created by TJ Lindsley on 6/28/14.
//  Copyright (c) 2014 TJ Lindsley. All rights reserved.
//

#import "LoadingView.h"

@implementation LoadingView


#define LABEL_WIDTH 80
#define LABEL_HEIGHT 20

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectMake(100, 200, 120, 120)];
    if (self) {
        [self setBackgroundColor:[UIColor colorWithWhite:0.5f alpha:0.6f]];
        self.layer.cornerRadius = 15;
        self.opaque = NO;
       
        
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 25, 81, 22)];
        label.text = @"Loading…";
        label.font = [UIFont boldSystemFontOfSize:16.0f];
        label.textColor = [UIColor colorWithWhite:1.0f alpha:1.0f];
        label.backgroundColor = [UIColor clearColor];
        [self addSubview:label];
        
        UIActivityIndicatorView* spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        spinner.frame = CGRectMake(42, 54, 37, 37);
        //spinner.center = self.center;
        //spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        //[spinner setColor:[UIColor colorWithRed:0.6 green:0.8 blue:1.0 alpha:1.0]];
        [spinner startAnimating];
        [self addSubview: spinner];
        
        self.frame = CGRectMake(100, 200, 120, 120);
    }
    return self;
}

@end



