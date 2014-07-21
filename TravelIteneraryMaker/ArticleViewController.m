//
//  ArticleViewController.m
//  TravelIteneraryMaker
//
//  Created by TJ Lindsley on 6/26/14.
//  Copyright (c) 2014 TJ Lindsley. All rights reserved.
//

#import "ArticleViewController.h"
#import "LoadingView.h"

@interface ArticleViewController () <UIScrollViewDelegate, UISplitViewControllerDelegate, UIWebViewDelegate>
@property (nonatomic, strong) IBOutlet UIWebView *articleView;
@end

@implementation ArticleViewController

- (void)viewDidLoad
{
    self.articleView.delegate = self;
    [super viewDidLoad];
    [self startDownloadingArticle];
    
}

- (void) startDownloadingArticle
{
    
    NSString *urlAdress = [self.articleURL stringByReplacingOccurrencesOfString:@"www" withString:@"mobile"];
    NSURL *url = [NSURL URLWithString:urlAdress];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    
    /*NSData *data=[NSURLConnection sendSynchronousRequest:requestObj returningResponse:nil error:nil];
    NSLog(@"This is the article data:%@", data);*/
    [self.articleView loadRequest:requestObj];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {

    [[self.view.subviews lastObject] removeFromSuperview];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {

    [self.view addSubview:[[LoadingView alloc] initWithFrame:self.view.bounds]];
    
}

#pragma mark - UISplitViewControllerDelegate

- (void)awakeFromNib
{
    self.splitViewController.delegate = self;
}

- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation
{
    return UIInterfaceOrientationIsPortrait(orientation);
}

- (void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc
{
    barButtonItem.title = aViewController.title;
    self.navigationItem.leftBarButtonItem = barButtonItem;
}

- (void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    self.navigationItem.leftBarButtonItem = nil;
}


@end
