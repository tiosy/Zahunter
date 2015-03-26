//
//  ViewController.m
//  ZaHunter
//
//  Created by tim on 3/25/15.
//  Copyright (c) 2015 Timothy Yeh. All rights reserved.
//

#import "RootViewController.h"
#import "DetailViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "PizzaLocation.h"

@interface RootViewController () <UITableViewDelegate,UITableViewDataSource,CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableview;

@property CLLocationManager *locationManager;

@property NSMutableArray *tableviewArray;

@property NSMutableArray *pizzaArray; //each element is a PizzaLocation obj
@property NSMutableArray *stepsArray; //each Pizza's steps from current loc

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.locationManager = [CLLocationManager new];
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager startUpdatingLocation];

    self.locationManager.delegate = self;


    self.pizzaArray = [NSMutableArray new];
    self.tableviewArray = [NSMutableArray new]; //store only 4 or less pizza locations
}








#pragma mark - CLLocationManagerDelegate>

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    NSLog(@"%@",locations);

    for (CLLocation *location in locations) {
        if(location.verticalAccuracy < 1000 && location.horizontalAccuracy < 1000)
        {
            //self.textfield.text = [NSString stringWithFormat:@"%@===%ld", location,locations.count];

            [self reverseGeocodeLocation:location];

            [self.locationManager stopUpdatingLocation];
        }

    }

}


#pragma mark - helper methods
//use location to find placemark
-(void) reverseGeocodeLocation:(CLLocation *) location
{
    CLGeocoder *geocoder = [CLGeocoder new];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {

        CLPlacemark *placemark = [placemarks objectAtIndex:0];
        NSLog(@"PLACEMARK thoroughfare %@, locality %@",placemark.thoroughfare,placemark.locality);

        //now find locations
        [self findPizzaLocationsNear:location naturalLanguageQuery:@"pizza"];

    }];
}

//within ~5miles (10,000 meters)
-(void) findPizzaLocationsNear:(CLLocation *) location naturalLanguageQuery: (NSString *) naturalLanguageQueryString
{

    MKLocalSearchRequest *request = [MKLocalSearchRequest new];
    request.naturalLanguageQuery = naturalLanguageQueryString;
    request.region = MKCoordinateRegionMake(location.coordinate, MKCoordinateSpanMake(0.07,0.07)); //5miles
    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {

        //MKMapItem *mapItem = [response.mapItems objectAtIndex:0];


        for (MKMapItem *mapItem in response.mapItems) {

            [self getDirectionsFromCurrentToMapItem:mapItem];

            PizzaLocation *pizzaLoc =[PizzaLocation new];
            pizzaLoc.placemarkName = mapItem.placemark.name;
            pizzaLoc.latitude = mapItem.placemark.location.coordinate.latitude;
            pizzaLoc.longitude = mapItem.placemark.location.coordinate.longitude;
            pizzaLoc.mapItem = mapItem;

            [self.pizzaArray addObject:pizzaLoc];
            if(self.tableviewArray.count <4)
            {
                [self.tableviewArray addObject:pizzaLoc];
            }
        }

        for (PizzaLocation *pL in self.pizzaArray) {
            NSLog(@"===%@",pL.placemarkName);
        }

         NSLog(@"===%ld===%ld",self.tableviewArray.count, self.pizzaArray.count);

        //in block...async process...need reload data
        [self.tableview reloadData];

    }];
    
   }



-(void) getDirectionsFromCurrentToMapItem:(MKMapItem *) mapItem
{

    MKDirectionsRequest *request = [MKDirectionsRequest new];
    request.source = [MKMapItem mapItemForCurrentLocation];
    request.destination = mapItem;

    MKDirections *direction =[[MKDirections alloc] initWithRequest:request];
    [direction calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error)
     {

        NSArray *routes = response.routes;
        MKRoute *theRoute = [routes objectAtIndex:0];

        int stepCount =1;
         NSMutableString *stepsString =[NSMutableString new];
        for(MKRouteStep *step in theRoute.steps)
        {
            [stepsString appendFormat:@"%i. %@\n", stepCount++ ,step.instructions];

        }


         [self.stepsArray addObject:stepsString];
       // NSLog(@"stepsString %@", stepsString);



     }
    ];


}

#pragma mark - segue to detail VC
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //SET THE DESTINATION VIEW CONTROLLER
    DetailViewController *detailVC = segue.destinationViewController;
    detailVC.pizzaArray = self.tableviewArray; //pass only 4 pizza locations

    
}



#pragma mark - UITableViewDataSource, UITableViewDelegate Protocols
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    PizzaLocation *pL = [self.tableviewArray objectAtIndex:indexPath.row];
    cell.textLabel.text = pL.placemarkName;

    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tableviewArray.count;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}



@end
