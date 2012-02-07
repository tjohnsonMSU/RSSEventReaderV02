//
//  REEventView.h
//  RSSEventReaderV02
//
//  Created by Seals, Shawn on 2/3/12.
//  Copyright (c) 2012 __MSU__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface REEventView : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    NSArray *events;
    UIBarButtonItem *backButton;
}

@property (nonatomic, retain) NSArray *events;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *backButton;

- (IBAction)backButtonPressed:(id)sender;

@end
