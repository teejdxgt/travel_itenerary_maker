//
//  DestinationsCDTVC.m
//  TravelIteneraryMaker
//
//  Created by TJ Lindsley on 6/25/14.
//  Copyright (c) 2014 TJ Lindsley. All rights reserved.
//

#import "DestinationsCDTVC.h"
#import "Destination.h"
#import "DestinationDatabaseAvailability.h"
#import "ArticleViewController.h"
#import "LoadingView.h"
#import "Destination+NYTimes.h"
#import "Place.h"

@interface DestinationsCDTVC ()
@property (nonatomic,strong) UISearchDisplayController *destinationsSearchDisplayController;

@property (nonatomic,strong) NSFetchedResultsController *searchFetchedResultsController;
@property (nonatomic,strong) NSFetchedResultsController *fetchedResultsController;
@end

@implementation DestinationsCDTVC

#pragma mark - Loading

- (void) awakeFromNib
{
    [[NSNotificationCenter defaultCenter] addObserverForName:DestinationDatabaseAvailabilityNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        self.managedObjectContext = note.userInfo
        [DestinationDatabaseAvailabilityContext];
    }];
    
}

-(void)loadView
{
    [super loadView];
    
    UIView *loadingView = [[LoadingView alloc] initWithFrame: CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    
    [self.navigationController.view addSubview:loadingView];
    [self.navigationController.view bringSubviewToFront:loadingView];
    
    [UIView animateWithDuration:3.0
                     animations:^{loadingView.alpha = 0.0;}
                     completion:^(BOOL finished){ [loadingView removeFromSuperview]; }];
    
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44.0)];
    searchBar.autoresizingMask = (UIViewAutoresizingFlexibleWidth);
    searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    self.tableView.tableHeaderView = searchBar;
    
    self.destinationsSearchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    self.destinationsSearchDisplayController.delegate = self;
    self.destinationsSearchDisplayController.searchResultsDataSource = self;
    self.destinationsSearchDisplayController.searchResultsDelegate = self;
    
        // restore search settings if they were saved in didReceiveMemoryWarning.
        if (self.savedSearchTerm)
        {
            [self.searchDisplayController setActive:self.searchWasActive];
            [self.searchDisplayController.searchBar setSelectedScopeButtonIndex:self.savedScopeButtonIndex];
            [self.searchDisplayController.searchBar setText:self.savedSearchTerm];
            
            self.savedSearchTerm = nil;
            
        }
    
    NSLog(@"Delegate should be %@", self.searchDisplayController.delegate);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"Delegate is %@", self.searchDisplayController.delegate);
    });
    
}
 
- (void)didReceiveMemoryWarning
{
    self.searchWasActive = [self.searchDisplayController isActive];
    self.savedSearchTerm = [self.searchDisplayController.searchBar text];
    self.savedScopeButtonIndex = [self.searchDisplayController.searchBar selectedScopeButtonIndex];

    
    _fetchedResultsController.delegate = nil;
    _fetchedResultsController = nil;
    _searchFetchedResultsController.delegate = nil;
    _searchFetchedResultsController = nil;
    
    [super didReceiveMemoryWarning];
}

- (void)viewDidDisappear:(BOOL)animated
{
    // save the state of the search UI so that it can be restored if the view is re-created
    self.searchWasActive = [self.searchDisplayController isActive];
    self.savedSearchTerm = [self.searchDisplayController.searchBar text];
    self.savedScopeButtonIndex = [self.searchDisplayController.searchBar selectedScopeButtonIndex];
}

#pragma mark - Search Functionality

- (NSFetchedResultsController *)fetchedResultsControllerForTableView:(UITableView *)tableView
{
    //NSLog(@"Are we using self.tableView? %d",(tableView == self.tableView));
    return tableView == self.tableView ? self.fetchedResultsController : self.searchFetchedResultsController;
}

- (UITableView *)determineTableView:(UITableView *)tableView
{
    return tableView == self.tableView ? self.tableView : tableView;
}

#pragma mark  - Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSInteger)scope
{
    NSLog(@"Filter content for search has been called");
    // update the filter, in this case just blow away the FRC and let lazy evaluation create another with the relevant search info
    self.searchFetchedResultsController.delegate = nil;
    self.searchFetchedResultsController = nil;
    // if you care about the scope save off the index to be used by the serchFetchedResultsController
    //self.savedScopeButtonIndex = scope;
}

#pragma mark  - Search Bar

- (void)searchDisplayController:(UISearchDisplayController *)controller willUnloadSearchResultsTableView:(UITableView *)tableView;
{
    NSLog(@"Search display controller has been called (will unload search results)");
    // search is done so get rid of the search FRC and reclaim memory
    self.searchFetchedResultsController.delegate = nil;
    self.searchFetchedResultsController = nil;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[self.searchDisplayController.searchBar selectedScopeButtonIndex]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    NSLog(@"Search display controller has been called (should reload results)");
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text]
                               scope:[self.searchDisplayController.searchBar selectedScopeButtonIndex]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

#pragma mark - NSFetch Controller Delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    //NSLog(@"Are we in self.fetchedResultsController? %d", (controller == self.fetchedResultsController));
    //NSLog(@"Is it the fetched results controller? %d", (controller == self.fetchedResultsController));
    UITableView *tableView = controller == self.fetchedResultsController ? self.tableView : self.searchDisplayController.searchResultsTableView;
    [tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type
{
    UITableView *tableView = controller == self.fetchedResultsController ? self.tableView : self.searchDisplayController.searchResultsTableView;
    
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)theIndexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = controller == self.fetchedResultsController ? self.tableView : self.searchDisplayController.searchResultsTableView;
    
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:theIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self fetchedResultsController:controller configureCell:[tableView cellForRowAtIndexPath:theIndexPath] atIndexPath:theIndexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:theIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    UITableView *tableView = controller == self.fetchedResultsController ? self.tableView : self.searchDisplayController.searchResultsTableView;
    [tableView endUpdates];
}

#pragma mark - Table Fetch Request Controller setup

- (NSFetchedResultsController *)newFetchedResultsControllerWithSearch:(NSString *)searchString
{
    NSLog(@"Entering fetched results controller with search: %@", searchString);
    
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"country" ascending:YES];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"city" ascending:YES];
    NSSortDescriptor *sortDescriptor3 = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
    
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor1, sortDescriptor2, sortDescriptor3, nil];
    NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:nil];
    

    /*
     Set up the fetched results controller.
     */
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Destination"];
    NSMutableArray *predicateArray = [NSMutableArray array];
    
    if(searchString.length)
    {
        // your search predicate(s) are added to this array
        [predicateArray addObject:[NSPredicate predicateWithFormat:@"city CONTAINS %@", searchString]];
        // finally add the filter predicate for this view
        if(filterPredicate)
        {
            filterPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:filterPredicate, [NSCompoundPredicate orPredicateWithSubpredicates:predicateArray], nil]];
        }
        else
        {
            filterPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:predicateArray];
        }
    }
    [fetchRequest setPredicate:filterPredicate];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Set the batch size to a suitable number.
    //[fetchRequest setFetchBatchSize:20];
    
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                                managedObjectContext:self.managedObjectContext
                                                                                                  sectionNameKeyPath:sortDescriptor1.key
                                                                                                           cacheName:nil];
    aFetchedResultsController.delegate = self;
    fetchRequest = nil;
    
    
    NSError *error = nil;
    if (![aFetchedResultsController performFetch:&error])
    {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return aFetchedResultsController;
}

- (NSFetchedResultsController *)fetchedResultsController
{
    //NSLog(@"Entering fetched results controller");
    if (_fetchedResultsController != nil)
    {
        //NSLog(@"Fetched results controller already existed");
        return _fetchedResultsController;
    }
    NSLog(@"Creating new festched results controller");
    _fetchedResultsController = [self newFetchedResultsControllerWithSearch:nil];
    return _fetchedResultsController;
}

- (NSFetchedResultsController *)searchFetchedResultsController
{
    //NSLog(@"Entering SEARCH fetched results controller");
    if (_searchFetchedResultsController != nil)
    {
        //NSLog(@"Fetched SEARCH results controller already existed");
        return _searchFetchedResultsController;
    }
    NSLog(@"Creating new search fetched results controller");
    _searchFetchedResultsController = [self newFetchedResultsControllerWithSearch:self.searchDisplayController.searchBar.text];
    return _searchFetchedResultsController;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger count = [[[self fetchedResultsControllerForTableView:tableView] sections] count];
    
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    {
        NSInteger rows = 0;
        if ([[[self fetchedResultsControllerForTableView:tableView] sections] count] > 0) {
            id <NSFetchedResultsSectionInfo> sectionInfo = [[[self fetchedResultsControllerForTableView:tableView] sections] objectAtIndex:section];
            rows = [sectionInfo numberOfObjects];
        }
        return rows;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[[[self fetchedResultsControllerForTableView:tableView] sections] objectAtIndex:section] name];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
	return [[self fetchedResultsControllerForTableView:tableView] sectionForSectionIndexTitle:title atIndex:index];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return [[self fetchedResultsControllerForTableView:tableView] sectionIndexTitles];
}


- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Destination"];
    
    if (cell == nil)
    {
        //cell = [self.searchDisplayController.searchResultsTableView dequeueReusableCellWithIdentifier:@"Destination"];
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Destination"];
    }
    
    [self fetchedResultsController:[self fetchedResultsControllerForTableView:tableView] configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)fetchedResultsController:(NSFetchedResultsController *)fetchedResultsController configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)theIndexPath
{
    Destination *destination = [fetchedResultsController objectAtIndexPath:theIndexPath];
    
    UIButton *button = [UIButton buttonWithType: UIButtonTypeCustom];
    [button setTag: destination.hash];
    
    CGRect ButtonFrame = CGRectMake (260, 9, 20, 20);
    [button setFrame: ButtonFrame];
    
    if (destination.saved == NO) {
        [button setImage:[UIImage imageNamed:@"star-128.png"] forState:UIControlStateNormal];
    }else{
        [button setImage:[UIImage imageNamed:@"selectedstar-128.png"] forState:UIControlStateNormal];
    }
    
    NSString *dateString = [destination.date substringToIndex:4];
    
    cell.textLabel.text = destination.city;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ (%@)", destination.title, dateString];
    
    if (destination.thumbnailImage) {
        cell.imageView.image = [UIImage imageWithData:destination.thumbnailImage];
    } else {
        // set default user image while image is being downloaded
        cell.imageView.image = [UIImage imageNamed:@"nytimeslogo1.png"];
        
        // download the image asynchronously
        [self downloadImageWithURL:[NSURL URLWithString:destination.thumbnailImageURL] completionBlock:^(BOOL succeeded, UIImage *image) {
            if (succeeded) {
                // change the image in the cell
                cell.imageView.image = image;
                
                // cache the image for use later (when scrolling up)
                destination.thumbnailImage = UIImagePNGRepresentation(image);
                //[Destination updateDestinationThumbnailImage:destination inManagedObjectContext:self.managedObjectContext];
            }
        }];
    }
    
    [button addTarget:self action:@selector(addFavoriteWithDestination:) forControlEvents:UIControlEventTouchUpInside];
    [cell addSubview:button];
    
    
}

- (void)downloadImageWithURL:(NSURL *)url completionBlock:(void (^)(BOOL succeeded, UIImage *image))completionBlock
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if ( !error )
                               {
                                   UIImage *image = [[UIImage alloc] initWithData:data];
                                   completionBlock(YES,image);
                               } else{
                                   completionBlock(NO,nil);
                               }
                           }];
}

- (void)addFavoriteWithDestination:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    UITableView *tableView = [self.tableView indexPathForCell:sender] ? self.tableView : self.searchDisplayController.searchResultsTableView;
    
    NSUInteger tempId = button.tag;
    
    [Destination updateDestinationIsSaved:tempId inManagedObjectContext:self.managedObjectContext];
    
    [tableView reloadData];
    [self viewWillAppear:YES];
    
}

#pragma mark - Navigation

-(void)prepareArticleViewController:(ArticleViewController *)avc toDisplayDestination:(Destination *)destination
{
    
    //Place *place = destination.places;
    //NSLog(@"This is the place data for what you selected: %@", place);
    
    avc.articleURL = destination.url;
    avc.title = destination.title;
    //NSLog(@"The values being passed in the segue are: %@, %@",avc.articleURL, avc.title);
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //NSLog(@"I am currently a UITableViewCell:%hhd", [sender isKindOfClass:[UITableViewCell class]]);
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([sender isKindOfClass:[UITableViewCell class]])
    {
        //NSLog(@"This is my sender value: %@", sender);
        UITableView *tableView = [self.tableView indexPathForCell:sender] ? self.tableView : self.searchDisplayController.searchResultsTableView;
        NSIndexPath *indexPath = [tableView indexPathForCell:sender];
        //NSLog(@"This is my indexpath value: %@", indexPath);
        if (indexPath)
        {
            Destination *destination = [[self fetchedResultsControllerForTableView:tableView] objectAtIndexPath:indexPath];
             //NSLog(@"This is my destination value: %@", [[self fetchedResultsControllerForTableView:tableView] objectAtIndexPath:indexPath]);
            if ([segue.identifier isEqualToString:@"article"])
            {
                if ([segue.destinationViewController isKindOfClass:[ArticleViewController class]])
                {
                    [self prepareArticleViewController:segue.destinationViewController toDisplayDestination:destination];
                }
            }
        }
    }
    
}

@end

