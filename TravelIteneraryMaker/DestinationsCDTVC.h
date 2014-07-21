//
//  DestinationsCDTVC.h
//  TravelIteneraryMaker
//
//  Created by TJ Lindsley on 6/25/14.
//  Copyright (c) 2014 TJ Lindsley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
//#import "CoreDataTableViewController.h"

@interface DestinationsCDTVC : UITableViewController  <NSFetchedResultsControllerDelegate, UISearchDisplayDelegate, UISearchBarDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong, readonly) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, copy) NSString *savedSearchTerm;
@property (nonatomic) NSInteger savedScopeButtonIndex;
@property (nonatomic) BOOL searchWasActive;
//@property (nonatomic, retain) IBOutlet UIButton *btnStar;

@property BOOL debug;

@end
