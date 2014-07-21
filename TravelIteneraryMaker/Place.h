//
//  Place.h
//  TravelIteneraryMaker
//
//  Created by TJ Lindsley on 7/6/14.
//  Copyright (c) 2014 TJ Lindsley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Destination;

@interface Place : NSManagedObject

@property (nonatomic, retain) NSString * descriptionOfPlace;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSNumber * rank;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * savedArticle;
@property (nonatomic, retain) Destination *destination;

@end
