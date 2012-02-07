//
//  REEventDetailView.m
//  RSSEventReaderV02
//
//  Created by Seals, Shawn on 2/5/12.
//  Copyright (c) 2012 __MSU__. All rights reserved.
//

#import "REEventDetailView.h"
#import "Event.h"
#import <EventKit/EventKit.h>
#import "REWebEventView.h"

@implementation REEventDetailView

@synthesize backButton;
@synthesize eventEDV;
@synthesize addToCalendarButton;
@synthesize gotoEventWebPageButton;
@synthesize titleField;
@synthesize dateField;
@synthesize timeField;
@synthesize locationField;

- (IBAction)backButtonPressed:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)gotoEventWebPage:(id)sender {
    // Launch eventWebLink in Safari browser.  Does not work with mobile site override.
    //[[UIApplication sharedApplication] openURL:eventEDV.eventWebLink];
    
    // Launch eventWebLink in UIWebView.
    REWebEventView *webEventView = [[REWebEventView alloc] initWithNibName:@"REWebEventView" bundle:nil];
    
    webEventView.webURL = eventEDV.eventWebLink;
    
    [self presentModalViewController:webEventView animated:YES];
}

- (IBAction)addEventToCalendar:(id)sender {
    EKEventStore *eventStore = [[EKEventStore alloc] init];
    
    EKEvent *eventEK = [EKEvent eventWithEventStore:eventStore];
    eventEK.title = eventEDV.title;
    eventEK.startDate = eventEDV.localStartDate;
    eventEK.endDate = eventEDV.localEndDate;
    
    [eventEK setCalendar:[eventStore defaultCalendarForNewEvents]];
    NSError *err;
    [eventStore saveEvent:eventEK span:EKSpanThisEvent error:&err];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Event added to calendar." 
                                                    message:nil
                                                   delegate:nil 
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    
    [alert show];
    
    /*
    UIActionSheet *addToCalendarAS = [[UIActionSheet alloc] initWithTitle:@"Event added to Calendar"
                                                                 delegate:nil 
                                                        cancelButtonTitle:nil 
                                                   destructiveButtonTitle:@"Return to Event" 
                                                        otherButtonTitles:nil, nil];
    
    [addToCalendarAS showInView:self.view];
     */    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    titleField.text = eventEDV.title;
    locationField.text = eventEDV.location;
        
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEE, MMM d, yyyy"];
    NSString *startDateString = nil;
    startDateString = [dateFormatter stringFromDate:eventEDV.localStartDate];
    dateField.text = startDateString;
    
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    NSString *startTimeString = nil;
    startTimeString = [dateFormatter stringFromDate:eventEDV.localStartDate];
    timeField.text = startTimeString;

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
