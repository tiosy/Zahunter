//
//  DetailViewController.m
//  ZaHunter
//
//  Created by tim on 3/26/15.
//  Copyright (c) 2015 Timothy Yeh. All rights reserved.
//

#import "DetailViewController.h"
#import <MapKit/MapKit.h>
#import "PizzaLocation.h"


@interface DetailViewController () <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapview;




@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self addAnnotaionWithArray:self.pizzaArray];

}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - helper methods: PIN location on MAP
-(void) addAnnotaionWithArray: (NSArray *) array
{

    NSLog(@"in detail:  array count %ld", array.count);
    for(PizzaLocation *pizzaLoc in array)
    {
        [self addAnnotationWithPoint:pizzaLoc];
    }
}




-(void) addAnnotationWithPoint: (PizzaLocation *) pizzaLoc
{

    NSString *name = pizzaLoc.placemarkName;
    double longitude = pizzaLoc.longitude;
    double latitude = pizzaLoc.latitude;


    MKPointAnnotation *oneAnnotation;
    /////POINT: using latitude,longitude to ADD
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude,longitude);
    oneAnnotation = [MKPointAnnotation new];

    oneAnnotation.title = name;
    NSString *str =[NSString stringWithFormat:@"(%f,%f)", latitude,longitude];
    oneAnnotation.subtitle = str;
    oneAnnotation.coordinate = coordinate;
    [self.mapview addAnnotation:oneAnnotation];

    NSLog(@"detail ===== %@", oneAnnotation.title);
}



#pragma mark Mapkit Delegate
-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKPinAnnotationView *pinAnnotation = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier: nil];

    //    if( [annotation isEqual:self.mobileMakersAnnotation]) {
    //
    //        pinAnnotation.image = [UIImage imageNamed:@"mobilemakers"];
    //    } else if ([annotation isEqual:mapView.userLocation]){
    //
    //        return nil;
    //    }

    // show title
    pinAnnotation.canShowCallout = YES;
    pinAnnotation.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];


    // now ZOOM in
    CLLocationCoordinate2D center = annotation.coordinate;
    MKCoordinateSpan span = MKCoordinateSpanMake(0.4, 0.4);
    [mapView setRegion:MKCoordinateRegionMake(center, span) animated:YES];




    return pinAnnotation;

}

//ZOOM in and SPAN out
-(void) mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    CLLocationCoordinate2D center = view.annotation.coordinate;
    MKCoordinateSpan span = MKCoordinateSpanMake(0.1, 0.1);
    [mapView setRegion:MKCoordinateRegionMake(center, span) animated:YES];

    //should be busStop
    [self performSegueWithIdentifier:@"detail" sender:mapView];
}





@end
