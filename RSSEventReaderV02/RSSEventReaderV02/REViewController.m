//
//  REViewController.m
//  RSSEventReaderV02
//
//  Created by Seals, Shawn on 2/3/12.
//  Copyright (c) 2012 __MSU__. All rights reserved.
//

#import "REViewController.h"
#import "REEventView.h"
#import "Event.h"

// this framework was imported so we could use the kCFURLErrorNotConnectedToInternet error code
#import <CFNetwork/CFNetwork.h>

@interface REViewController () <NSXMLParserDelegate>
@property (nonatomic, strong) Event *currentEventObject;
@property (nonatomic, strong) NSMutableArray *currentParseBatch;
@property (nonatomic, strong) NSMutableString *currentParsedCharacterData;
@end


@implementation REViewController

@synthesize requestButton = requestButton_;
@synthesize eventFeedConnection;
@synthesize eventData;
@synthesize currentEventObject;
@synthesize currentParseBatch;
@synthesize currentParsedCharacterData;

- (IBAction)requestButtonPressed:(id)sender {
    
    // Use NSURLConnection to asynchronously download the data. This means the main thread will not
    // be blocked - the application will remain responsive to the user. 
    //
    // IMPORTANT! The main thread of the application should never be blocked!
    // Also, avoid synchronous network access on any thread.
    //
    static NSString *feedURLString = @"http://msumustangs.com/services/calendar.ashx/calendar.rss?sport_id=&han=";
    //static NSString *feedURLString = @"http://cs.mwsu.edu/MustangsRss/short.rss";
    NSURLRequest *eventsURLRequest =
    [NSURLRequest requestWithURL:[NSURL URLWithString:feedURLString]];
    
    self.eventFeedConnection = 
    [[NSURLConnection alloc] initWithRequest:eventsURLRequest delegate:self];
    
    // Test the validity of the connection object. The most likely reason for the connection object
    // to be nil is a malformed URL, which is a programmatic error easily detected during development.
    // If the URL is more dynamic, then you should implement a more flexible validation technique,
    // and be able to both recover from errors and communicate problems to the user in an
    // unobtrusive manner.
    NSAssert(self.eventFeedConnection != nil, @"Failure to create URL connection.");
    
    // Start the status bar network activity indicator. We'll turn it off when the connection
    // finishes or experiences an error.
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}



#pragma mark - NSURLConnection delegate methods

// The following are delegate methods for NSURLConnection. Similar to callback functions, this is how the connection object, which is working in the background, can asynchronously communicate back to its delegate on the thread from which it was started - in this case, the main thread.
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // check for HTTP status code for proxy authentication failures anything in the 200 to 299 range is considered successful, also make sure the MIMEType is correct:
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    if ((([httpResponse statusCode]/100) == 2) && [[response MIMEType] isEqual:@"application/rss+xml"]) {
        self.eventData = [NSMutableData data];
    } 
    else {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:
                                  NSLocalizedString(@"HTTP Error",
                                                    @"Error message displayed when receving a connection error.")
                                                             forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:@"HTTP" code:[httpResponse statusCode] userInfo:userInfo];
        [self handleError:error];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [eventData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;   
    if ([error code] == kCFURLErrorNotConnectedToInternet) {
        // if we can identify the error, we can present a more precise message to the user.
        NSDictionary *userInfo =
        [NSDictionary dictionaryWithObject:
         NSLocalizedString(@"No Connection Error",
                           @"Error message displayed when not connected to the Internet.")
                                    forKey:NSLocalizedDescriptionKey];
        NSError *noConnectionError = [NSError errorWithDomain:NSCocoaErrorDomain
                                                         code:kCFURLErrorNotConnectedToInternet
                                                     userInfo:userInfo];
        [self handleError:noConnectionError];
    } else {
        // otherwise handle the error generically
        [self handleError:error];
    }
    self.eventFeedConnection = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    self.eventFeedConnection = nil;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;  
    
    // Print rss source to console.
    //NSString *dataString = [[NSString alloc] initWithData:eventData encoding:NSUTF8StringEncoding];
    //NSLog(@"%@", dataString);
    
    self.currentParseBatch = [NSMutableArray array];
    self.currentParsedCharacterData = [NSMutableString string];
    
    NSXMLParser *xmlParser = [[NSXMLParser alloc]initWithData:eventData];
    [xmlParser setDelegate:self];
    [xmlParser parse];
    
    // The following code is to perform parsing in another thread.
    // Spawn an NSOperation to parse the event data so that the UI is not blocked while the
    // application parses the XML data.
    //
    // IMPORTANT! - Don't access or affect UIKit objects on secondary threads.
    //
    
    /*
     ParseOperation *parseOperation = [[ParseOperation alloc] initWithData:self.eventData];
     [self.parseQueue addOperation:parseOperation];
     [parseOperation release];   // once added to the NSOperationQueue it's retained, we don't need it anymore
     */
    
    // earthquakeData will be retained by the NSOperation until it has finished executing, so we no longer need a reference to it in the main thread.
    self.eventData = nil;
    
    REEventView *eventView = [[REEventView alloc] initWithNibName:@"REEventView" bundle:nil];
    
    // Send the UREventsTableViewController a copy of the array of events.
    NSArray *tempEventsArray = [[NSArray alloc] initWithArray:self.currentParseBatch];
    eventView.events = tempEventsArray;
    
    [self presentModalViewController:eventView animated:YES];    
}


#pragma mark - 

// Handle errors in the download by showing an alert to the user. This is a very simple way of handling the error, partly because this application does not have any offline functionality for the user. Most real applications should handle the error in a less obtrusive way and provide offline functionality to the user.
- (void)handleError:(NSError *)error {
    NSString *errorMessage = [error localizedDescription];
    UIAlertView *alertView =
    [[UIAlertView alloc] initWithTitle:
     NSLocalizedString(@"Error Title",
                       @"Title for alert displayed when download or parse error occurs.")
                               message:errorMessage
                              delegate:nil
                     cancelButtonTitle:@"OK"
                     otherButtonTitles:nil];
    [alertView show];
}


#pragma mark - Parsing Constants

// Reduce potential parsing errors by using string constants declared in a single place.
static NSString * const kEntryElementName = @"item";
static NSString * const kTitleElementName = @"title";
static NSString * const kDescriptionElementName = @"description";
static NSString * const kLinkElementName = @"link";
static NSString * const kGuidElementName = @"guid";
static NSString * const kEventLocationElementName = @"ev:location";
static NSString * const kEventStartDateElementName = @"ev:startdate";
static NSString * const kEventEndDateElementName = @"ev:enddate";
static NSString * const kLocalStartDateElementName = @"localstartdate";
static NSString * const kLocalEndDateElementName = @"localenddate";


#pragma mark - NSXMLParser delegate methods

- (void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName 
   namespaceURI:(NSString *)namespaceURI
  qualifiedName:(NSString *)qualifiedName 
     attributes:(NSDictionary *)attributeDict   {
    
    if ([elementName isEqualToString:kEntryElementName]) {
        Event *event = [[Event alloc] init];
        self.currentEventObject = event;
    } 
    else if ([elementName isEqualToString:kTitleElementName] ||
             [elementName isEqualToString:kDescriptionElementName] ||
             [elementName isEqualToString:kGuidElementName] ||
             [elementName isEqualToString:kLinkElementName] ||
             [elementName isEqualToString:kEventLocationElementName] || 
             [elementName isEqualToString:kLocalStartDateElementName] || 
             [elementName isEqualToString:kLocalEndDateElementName]) {
        // For the 'title', 'description', id, or 'location' element begin accumulating parsed character data.
        // The contents are collected in parser:foundCharacters:.
        accumulatingParsedCharacterData = YES;
        // The mutable string needs to be reset to empty.
        [self.currentParsedCharacterData setString:@""];
    }
}


- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName {
    if ([elementName isEqualToString:kEntryElementName]) {
        [self.currentParseBatch addObject:self.currentEventObject];
    }
    else if ([elementName isEqualToString:kTitleElementName]) {
        
        NSString *tempTitle = [[NSString alloc] initWithString:currentParsedCharacterData];
                
        NSInteger index = 0;
        
        // Used to find space characters in string.
        NSMutableCharacterSet *space = 
        [NSMutableCharacterSet characterSetWithCharactersInString:@" "];

        // Check for date at beginning of title.
        if ([currentParsedCharacterData length] > 5) {
            // If the date is in the format M/D.
            if (isdigit([currentParsedCharacterData characterAtIndex:0]) &&
                [currentParsedCharacterData characterAtIndex:1] == '/' &&
                isdigit([currentParsedCharacterData characterAtIndex:2]) &&
                [space characterIsMember:[currentParsedCharacterData characterAtIndex:3]]) {
                
                index = 4;
            }
            // If the date is in the format M/DD.
            else if (isdigit([currentParsedCharacterData characterAtIndex:0]) &&
                     [currentParsedCharacterData characterAtIndex:1] == '/' &&
                     isdigit([currentParsedCharacterData characterAtIndex:2]) &&
                     isdigit([currentParsedCharacterData characterAtIndex:3]) &&
                     [space characterIsMember:[currentParsedCharacterData characterAtIndex:4]]) {
                
                index = 5;
            }
            // If the date is in the format MM/D.
            else if (isdigit([currentParsedCharacterData characterAtIndex:0]) &&
                     isdigit([currentParsedCharacterData characterAtIndex:1]) &&
                     [currentParsedCharacterData characterAtIndex:2] == '/' &&
                     isdigit([currentParsedCharacterData characterAtIndex:3]) &&
                     [space characterIsMember:[currentParsedCharacterData characterAtIndex:4]]) {
                
                index = 5;
            }
            // If the date is in the format MM/DD.
            else if (isdigit([currentParsedCharacterData characterAtIndex:0]) &&
                     isdigit([currentParsedCharacterData characterAtIndex:1]) &&
                     [currentParsedCharacterData characterAtIndex:2] == '/' &&
                     isdigit([currentParsedCharacterData characterAtIndex:3]) &&
                     isdigit([currentParsedCharacterData characterAtIndex:4]) &&
                     [space characterIsMember:[currentParsedCharacterData characterAtIndex:5]]) {
                
                index = 6;
            }
            // Else there is no date at the beginning of the title string.
        }

        if ([currentParsedCharacterData length] > 13) {
            // If the title contains the time in the format H:MM AP.
            if ((isdigit([currentParsedCharacterData characterAtIndex:index]) && 
                 ([currentParsedCharacterData characterAtIndex:(index + 1)] == ':')) &&
                (isdigit([currentParsedCharacterData characterAtIndex:(index + 2)]))) {

                index = index + 8;  // Index of character after space after time
            }
            // Else If the title contains the time in the format HH:MM AP.
            else if (isdigit([currentParsedCharacterData characterAtIndex:index]) && 
                     (isdigit([currentParsedCharacterData characterAtIndex:(index + 1)])) && 
                     ([currentParsedCharacterData characterAtIndex:(index + 2)] == ':') &&
                     (isdigit([currentParsedCharacterData characterAtIndex:(index + 3)]))) {
                
                index = index + 9;  // Index of character after space after time
            }
            // Else the title does not contain the time, so do nothing.
        }
                
        // The title element contains the title, date, and location in the following format: 
        // <title>1/31 7:30 PM [W] Men's Basketball at Abilene Christian<title/> 
        // Use the scanner along with the index calculated above to scan only the title.
        NSScanner *scanner = [NSScanner scannerWithString:self.currentParsedCharacterData];
        [scanner setScanLocation:index];
                  
        tempTitle = [[scanner string] substringFromIndex:[scanner scanLocation]];
        self.currentEventObject.title = tempTitle;
    } 
    else if ([elementName isEqualToString:kDescriptionElementName]) {
        NSString *tempDescription = [[NSString alloc] initWithString:currentParsedCharacterData];
        self.currentEventObject.description = tempDescription;
    } 
    else if ([elementName isEqualToString:kGuidElementName]) {
        NSString *tempGuid = [[NSString alloc] initWithString:currentParsedCharacterData];
        self.currentEventObject.guid = tempGuid;
    }
    else if ([elementName isEqualToString:kEventLocationElementName]) {
        NSString *tempEventLocation = [[NSString alloc] initWithString:currentParsedCharacterData];
        self.currentEventObject.location = tempEventLocation;
    } 
    else if ([elementName isEqualToString:kLocalStartDateElementName]) {
        NSString *tempStartDateString = [[NSString alloc] initWithString:currentParsedCharacterData];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        // Date is in the format: 2012-02-03T16:00:00.0000000
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'.0000000'"];
        NSDate *dateString = [[NSDate alloc] init];
        dateString = [dateFormatter dateFromString:tempStartDateString];
    
        self.currentEventObject.localStartDate = dateString;
    } 
    else if ([elementName isEqualToString:kLocalEndDateElementName]) {
        NSString *tempEndDateString = [[NSString alloc] initWithString:currentParsedCharacterData];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        // Date is in the format: 2012-02-03T16:00:00.0000000
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'.0000000'"];
        NSDate *dateString = [[NSDate alloc] init];
        dateString = [dateFormatter dateFromString:tempEndDateString];
        
        self.currentEventObject.localEndDate = dateString;
    } 
    else if ([elementName isEqualToString:kLinkElementName]) {
        NSURL *tempWebLink = [[NSURL alloc] initWithString:currentParsedCharacterData];
        self.currentEventObject.eventWebLink = tempWebLink;
    }
    // Stop accumulating parsed character data. We won't start again until specific elements begin.
    accumulatingParsedCharacterData = NO;
}


// This method is called by the parser when it find parsed character data ("PCDATA") in an element. The parser is not guaranteed to deliver all of the parsed character data for an element in a single invocation, so it is necessary to accumulate character data until the end of the element is reached.
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    if (accumulatingParsedCharacterData) {
        // If the current element is one whose content we care about, append 'string' to the property that holds the content of the current element.
        [self.currentParsedCharacterData appendString:string];
    }
    
    // Test code...
    //NSLog(@"the parser just found this text in a tag:%@",string);
}


@end
