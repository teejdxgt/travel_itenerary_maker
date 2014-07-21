//
//  Place+NYTimes.h
//  TravelIteneraryMaker
//
//  Created by TJ Lindsley on 7/6/14.
//  Copyright (c) 2014 TJ Lindsley. All rights reserved.
//

#import "Place.h"

@interface Place (NYTimes)

+ (Place *)placeWithURL:(NSString *)url inManagedObjectContext:(NSManagedObjectContext *)context;

+ (Place *)removePlaceWithURL:(NSString *)url inManagedObjectContext:(NSManagedObjectContext *)context;

@end
