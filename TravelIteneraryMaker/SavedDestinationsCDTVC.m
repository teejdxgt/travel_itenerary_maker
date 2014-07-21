//
//  SavedDestinationsCDTVC.m
//  TravelIteneraryMaker
//
//  Created by TJ Lindsley on 7/6/14.
//  Copyright (c) 2014 TJ Lindsley. All rights reserved.
//

#import "SavedDestinationsCDTVC.h"
#import "Destination.h"
#import "place.h"
#import "SavedArticleViewController.h"

@interface SavedDestinationsCDTVC ()

@end

@implementation SavedDestinationsCDTVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - Table Fetch Request Controller setup

- (NSFetchedResultsController *)newFetchedResultsControllerWithSearch:(NSString *)searchString
{
    NSLog(@"Entering fetched results controller with search: %@", searchString);
    
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"country" ascending:YES];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"city" ascending:YES];
    NSSortDescriptor *sortDescriptor3 = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
    
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor1, sortDescriptor2, sortDescriptor3, nil];
    NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"saved == %@", [NSNumber numberWithBool:YES]];
    
    
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
        //NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return aFetchedResultsController;
}

#pragma mark - Navigation

-(void)prepareArticleViewController:(SavedArticleViewController *)savc toDisplayDestination:(Destination *)destination
{
    Place *place = destination.places;
    
    savc.articleURL = place.savedArticle;
    savc.url = destination.url;
    savc.title = destination.title;
    NSLog(@"The values being passed in the segue are: %@, %@",savc.articleURL, savc.title);
}


@end
