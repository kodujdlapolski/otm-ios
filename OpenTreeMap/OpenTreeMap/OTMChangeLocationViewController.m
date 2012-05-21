//
//  OTMChangeLocationViewController.m
//  OpenTreeMap
//
//  Created by Justin Walgran on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OTMChangeLocationViewController.h"
#import "OTMTreeDictionaryHelper.h"

@implementation OTMChangeLocationViewController

@synthesize mapView, delegate, mapModeSegmentedControl;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeMapMode:) name:kOTMChangeMapModeNotification object:nil];

    self.mapModeSegmentedControl.selectedSegmentIndex = [(OTMAppDelegate *)[[UIApplication sharedApplication] delegate] mapMode];

    switch ([(OTMAppDelegate *)[[UIApplication sharedApplication] delegate] mapMode]) {
        case 0:
            self.mapView.mapType = MKMapTypeStandard;
            break;
        case 1:
            self.mapView.mapType = MKMapTypeSatellite;
            break;
        default:
            self.mapView.mapType = MKMapTypeHybrid;
            break;
    }

}

- (IBAction)setMapMode:(UISegmentedControl *)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:kOTMChangeMapModeNotification object:[NSNumber numberWithInt:sender.selectedSegmentIndex]];
}

-(void)changeMapMode:(NSNotification *)note {
    switch ([note.object intValue]) {
        case 0:
            self.mapView.mapType = MKMapTypeStandard;
            break;
        case 1:
            self.mapView.mapType = MKMapTypeSatellite;
            break;
        default:
            self.mapView.mapType = MKMapTypeHybrid;
            break;
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)annotateCenter:(CLLocationCoordinate2D)center
{
    if (!treeAnnotation) {
        treeAnnotation = [[MKPointAnnotation alloc] init];
    }
    
    [mapView removeAnnotation:treeAnnotation];
    
    // Set a small latitude delta to zoom the map in close to the point
    [mapView setRegion:MKCoordinateRegionMake(center, MKCoordinateSpanMake(0.001, 0.00)) animated:NO];
    
    treeAnnotation.coordinate = center;
    [mapView addAnnotation:treeAnnotation];
}

#define kOTMChangeLocationViewAnnotationViewReuseIdentifier @"kOTMChangeLocationViewAnnotationViewReuseIdentifier"

- (MKAnnotationView *)mapView:(MKMapView *)mv viewForAnnotation:(id <MKAnnotation>)annotation
{
    if (annotation == treeAnnotation) {
        MKAnnotationView *annotationView = [self.mapView dequeueReusableAnnotationViewWithIdentifier:kOTMChangeLocationViewAnnotationViewReuseIdentifier];
        if (!annotationView) {
            annotationView = [[OTMAddTreeAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:kOTMChangeLocationViewAnnotationViewReuseIdentifier];
            ((OTMAddTreeAnnotationView *)annotationView).delegate = self;
            ((OTMAddTreeAnnotationView *)annotationView).mapView = mv;
        }
        return annotationView;
    } else {
        return nil;
    }
}

- (void)movedAnnotation:(MKPointAnnotation *)annotation
{
    NSMutableDictionary *data = [delegate.data mutableDeepCopy];
    [OTMTreeDictionaryHelper setCoordinate:annotation.coordinate inDictionary:data];
    delegate.data = data;
    [delegate.tableView reloadData];
}

@end