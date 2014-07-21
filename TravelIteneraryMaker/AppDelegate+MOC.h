//
//  AppDelegate+MOC.h
//  TravelIteneraryMaker
//
//  Created by TJ Lindsley on 6/25/14.
//  Copyright (c) 2014 TJ Lindsley. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate (MOC)

- (void)saveContext:(NSManagedObjectContext *)managedObjectContext;

- (NSManagedObjectContext *)createMainQueueManagedObjectContext;

@end
