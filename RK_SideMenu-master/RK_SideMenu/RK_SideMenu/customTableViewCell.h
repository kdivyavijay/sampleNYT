//
//  customTableViewCell.h
//  RK_SideMenu
//
//  Created by Divya K on 10/17/18.
//  Copyright © 2018 Raj Kadam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface customTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *imgView;
@property (strong, nonatomic) IBOutlet UILabel *titleLbl;
@property (strong, nonatomic) IBOutlet UILabel *detailLbl;
@property (strong, nonatomic) IBOutlet UILabel *timLbl;

@end
