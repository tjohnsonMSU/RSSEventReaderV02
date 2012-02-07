//
//  REWebEventView.h
//  RSSEventReaderV02
//
//  Created by Jackson, Jacob on 2/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface REWebEventView : UIViewController {
    UIBarButtonItem *backButton;
    UIWebView * eventWebView;
    NSURL *webURL;
}

@property (nonatomic, strong) IBOutlet UIBarButtonItem *backButton;
@property (nonatomic, strong) IBOutlet UIWebView *eventWebView;
@property (nonatomic, strong) NSURL *webURL;

- (IBAction)backButtonPressed:(id)sender;

@end
