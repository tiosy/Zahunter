//
//  PizzaLocation.h
//  ZaHunter
//
//  Created by tim on 3/25/15.
//  Copyright (c) 2015 Timothy Yeh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@protocol PizzaDelegate <NSObject>

-(void)pizza:(NSArray *)pizzasArray;

@end


@interface PizzaLocation : NSObject

@property id<PizzaDelegate>delegate;

@property NSString *placemarkName;
@property MKMapItem *mapItem;
@property double latitude;
@property double longitude;

-(instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end



