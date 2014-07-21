//
//  Destination.h
//  TravelIteneraryMaker
//
//  Created by TJ Lindsley on 7/6/14.
//  Copyright (c) 2014 TJ Lindsley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Place;

@interface Destination : NSManagedObject

@property (nonatomic, retain) NSString * articleID;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * country;
@property (nonatomic, retain) NSString * date;
@property (nonatomic, retain) NSData * thumbnailImage;
@property (nonatomic, retain) NSString * thumbnailImageURL;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSNumber * saved;
@property (nonatomic, retain) Place *places;

@end
