//
//  AppDelegate.m
//  TravelIteneraryMaker
//
//  Created by TJ Lindsley on 6/23/14.
//  Copyright (c) 2014 TJ Lindsley. All rights reserved.
//

#import "AppDelegate.h"
#import "NYTimesArticleFetcher.h"
#import "Destination+NYTimes.h"
#import "DestinationDatabaseAvailability.h"
#import "AppDelegate+MOC.h"

@interface AppDelegate() <NSURLSessionDownloadDelegate>
@property (copy, nonatomic) void (^nyTimesDownloadBackgroundURLSessionCompletionHandler)();
@property (strong, nonatomic) NSURLSession *nyTimesDownloadSession;
@property (strong, nonatomic) NSTimer *nyTimesForegroundFetchTimer;
@property (strong, nonatomic) NSManagedObjectContext *destinationDatabaseContext;
@end

//Name of the NYTimes Fetcher background download session
#define NYTIMES_FETCH @"NYTimes just uploaded fetch"

//How often (in seconds) we fetch new destiantions if we are in the foreground
#define FOREGROUND_FETCH_INTERVAL (20*60)

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //NSLog(@"Is did finish launching with options taking so long?");
    // Override point for customization after application launch.
    self.destinationDatabaseContext = [self createMainQueueManagedObjectContext];
    [self startNYTimesFetch];
    return YES;
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler //fetching in the background - must call completion handler
{
    //NSLog(@"Is performFetchWithCompletionHandler taking so long?");
    [self startNYTimesFetch];
    completionHandler(UIBackgroundFetchResultNoData);
}

- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler
{
    //NSLog(@"Is handleEventsForBackgroundURLSession taking so long?");
    self.nyTimesDownloadBackgroundURLSessionCompletionHandler = completionHandler;
}

- (void)setDestinationDatabaseContext:(NSManagedObjectContext *)destinationDatabaseContext //posting
{
    //NSLog(@"Is setDestinationDatabaseContext taking so long?");
    _destinationDatabaseContext = destinationDatabaseContext;
    
    [NSTimer scheduledTimerWithTimeInterval:20*60 target:self selector:@selector(startNYTimesFetch:) userInfo:nil repeats:YES];
    NSDictionary *userInfo = self.destinationDatabaseContext ? @{ DestinationDatabaseAvailabilityContext : self.destinationDatabaseContext } : nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:DestinationDatabaseAvailabilityNotification object:self userInfo:userInfo];
}

- (void)startNYTimesFetch:(NSTimer *)timer
{
    //NSLog(@"Is startNYTimesFetch w/ timer taking so long?");
    [self startNYTimesFetch];
}

- (void)startNYTimesFetch
{
    //NSLog(@"Is startNYTimesFetch taking so long?");
    [self.nyTimesDownloadSession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        if (![downloadTasks count])
        {
            NSInteger count = [self getPaginationCountForURL:[NYTimesArticleFetcher URLforArticles:0]];
            for(int i = 0; i < count; i++)
            {
                NSURLSessionDownloadTask *task = [self.nyTimesDownloadSession downloadTaskWithURL:[NYTimesArticleFetcher URLforArticles:i]];
                task.taskDescription = NYTIMES_FETCH;
                [task resume];
            }
        }
        else
        {
            for(NSURLSessionDownloadTask *task in downloadTasks) [task resume];
        }
    }];
}

- (NSURLSession *)nyTimesDownloadSession //this is the NSURLSession that will be used to fetch flickr data in the background
{
    //NSLog(@"Is nyTimesDownloadSession taking so long?");
    if (!_nyTimesDownloadSession)
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSURLSessionConfiguration *urlSessionConfig = [NSURLSessionConfiguration backgroundSessionConfiguration:NYTIMES_FETCH];
            //NSURLSessionConfiguration *urlSessionConfig = [NSURLSessionConfiguration ephemeralSessionConfiguration];
            urlSessionConfig.allowsCellularAccess = YES; //for example
            _nyTimesDownloadSession = [NSURLSession sessionWithConfiguration:urlSessionConfig delegate:self delegateQueue:nil]; //delegate along with the background session allows fetching to run in the background
        });
    }
    return _nyTimesDownloadSession;
}

- (NSArray *)nyTimesDestinationsAtURL:(NSURL *)url
{
    //NSLog(@"Is nyTimesDestinationsAtURL taking so long?");
    //NSLog(@"This is the article nytimes JSON data: %@", [NSData dataWithContentsOfURL:url]);
    if (![NSData dataWithContentsOfURL:url])
        {
            NSLog(@"Dear lord in heaven we have no fucking data");
            [self nyTimesDownloadSession];
            return nil;
        }
    else
    {
        NSLog(@"We have data!");
        NSData *nyTimesJSONData = [NSData dataWithContentsOfURL:url];
        NSDictionary *articleListResults = [NSJSONSerialization JSONObjectWithData:nyTimesJSONData options:0 error:NULL];
        //NSLog(@"This is the article list results: %@", articleListResults);
        NSArray *articles = [articleListResults valueForKey:@"response"];
        NSArray *articleData = [articles valueForKey:@"docs"];
        return articleData;
    }
}

- (NSInteger) getPaginationCountForURL:(NSURL *)url
{
    NSInteger pages = 0;
    if (![NSData dataWithContentsOfURL:url])
    {
        NSLog(@"Dear lord in heaven we have no fucking data");
        [self nyTimesDownloadSession];
    }
    else
    {
        NSLog(@"Getting the Count!");
        NSData *nyTimesJSONData = [NSData dataWithContentsOfURL:url];
        NSDictionary *articleListResults = [NSJSONSerialization JSONObjectWithData:nyTimesJSONData options:0 error:NULL];
        //NSLog(@"This is the article list results: %@", articleListResults);
        NSArray *articles = [articleListResults valueForKey:@"response"];
        NSArray *metaData = [articles valueForKey:@"meta"];
        NSInteger count = [[metaData valueForKey:@"hits"]integerValue];
        pages = count/10;
        pages = pages-1;
    }
    return pages;
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)localFile
{
    //NSLog(@"Is URLSession taking so long?");
    if ([downloadTask.taskDescription isEqualToString:NYTIMES_FETCH])
    {
        NSManagedObjectContext *context = self.destinationDatabaseContext;
        if (context)
        {
            NSArray *destinations = [self nyTimesDestinationsAtURL:localFile];
            [context performBlock:^{
                [Destination loadDestinationsFromArticleArray:destinations inManagedObjectContext:context];
                [context save:NULL];
            }];
        }
    }
}

//required by the protocol
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
    
}

//required by the protocol
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    
}

- (void)nyTimesDownloadTasksMightBeComplete
{
    if (self.nyTimesDownloadBackgroundURLSessionCompletionHandler)
    {
        [self.nyTimesDownloadSession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
            if (![downloadTasks count]) //no more downloads left?
            {
                void (^completionHandler)() = self.nyTimesDownloadBackgroundURLSessionCompletionHandler;
                self.nyTimesDownloadBackgroundURLSessionCompletionHandler = nil;
                if (completionHandler)
                {
                    completionHandler();
                }
            }
        }];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
