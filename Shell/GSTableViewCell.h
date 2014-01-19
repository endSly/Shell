//
//  GSTableViewCell.h
//  Shell
//
//  Created by Endika Gutiérrez Salas on 1/10/14.
//  Copyright (c) 2014 Endika Gutiérrez Salas. All rights reserved.
//

#import <SWTableViewCell/SWTableViewCell.h>

@interface GSTableViewCell : SWTableViewCell

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *detailLabel;

@property (nonatomic) BOOL removeButtonVisible;
@property (nonatomic) BOOL editButtonVisible;
@property (nonatomic) BOOL rebootButtonVisible;

@end
