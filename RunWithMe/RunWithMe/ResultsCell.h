//
//  ResultsCell.h
//  RunWithMe
//
//  Created by Ethan Yu on 10/5/14.
//  Copyright (c) 2014 HackMIT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResultsCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;

@end
