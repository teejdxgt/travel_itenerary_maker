//
//  TestTimesTVC.m
//  TravelIteneraryMaker
//
//  Created by TJ Lindsley on 6/23/14.
//  Copyright (c) 2014 TJ Lindsley. All rights reserved.
//

#import "TestTimesTVC.h"
#import "NYTimesArticleFetcher.h"

@interface TestTimesTVC ()

@end

@implementation TestTimesTVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"About to go fetch some Articles");
    [self fetchArticles];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)setDestinations:(NSArray *)destinations
{
    _destinations = destinations;
    [self.tableView reloadData];
}

- (IBAction)fetchArticles
{
    [self.refreshControl beginRefreshing];
    NSURL *url = [NYTimesArticleFetcher URLforArticles:0];
    NSLog(@"This is the url that we're going to try to search with: %@", url);
    
    dispatch_queue_t fetchQ = dispatch_queue_create("nytimes fetcher",NULL);
    dispatch_async(fetchQ, ^{
    NSData *jsonResults = [NSData dataWithContentsOfURL:url];
    NSDictionary *articleListResults = [NSJSONSerialization JSONObjectWithData:jsonResults options:0 error:NULL];
    NSArray *articles = [articleListResults valueForKey:@"response"];
    NSArray *articleData = [articles valueForKey:@"docs"];
    NSArray *destinations = [articleData valueForKey:@"keywords"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.refreshControl endRefreshing];
            self.destinations = destinations;
        });
    });
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.destinations count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Destination" forIndexPath:indexPath];
    
    NSDictionary *destination = self.destinations[indexPath.row];
    NSMutableArray *destinationArray = [destination valueForKeyPath:NYTIMES_ARTICLE_GEO_LOCATION];
    NSString *tempString = [NYTimesArticleFetcher sortfromArray:destinationArray].firstObject;
    
    cell.textLabel.text = [NYTimesArticleFetcher pullCityName:tempString];
    cell.detailTextLabel.text = [NYTimesArticleFetcher pullCountryName:tempString];
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
