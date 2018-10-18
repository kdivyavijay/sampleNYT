//
//  ViewController.h
//  RK_SideMenu
//
//  Created by Raj on 04/06/15.
//  Copyright (c) 2015 Raj Kadam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "customTableViewCell.h"
@interface ViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,NSURLConnectionDelegate>
{
	NSMutableArray *resultArray,*FinalArray;
	NSMutableData *_responseData;
}

@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
- (IBAction)rightMenuClicked:(id)sender;

@end

