//
//  SavedArticleViewController.m
//  TravelIteneraryMaker
//
//  Created by TJ Lindsley on 7/6/14.
//  Copyright (c) 2014 TJ Lindsley. All rights reserved.
//

#import "SavedArticleViewController.h"

@interface SavedArticleViewController ()<UIScrollViewDelegate, UISplitViewControllerDelegate, UIWebViewDelegate>
@property (nonatomic, strong) IBOutlet UIWebView *articleView;

@end

@implementation SavedArticleViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

}

- (void) startDownloadingArticle
{
    NSString *urlAdress = [self.url stringByReplacingOccurrencesOfString:@"www" withString:@"mobile"];
    NSURL *newURL = [NSURL URLWithString:urlAdress];
    [self.articleView loadHTMLString:self.articleURL baseURL:newURL];
}

@end
