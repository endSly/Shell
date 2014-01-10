//
//  GSApplication.h
//  Shell
//
//  Created by Endika Gutiérrez Salas on 1/10/14.
//  Copyright (c) 2014 Endika Gutiérrez Salas. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GSApplication : NSObject

@property (nonatomic, strong) NSString * id;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * buildpack_provided_description;

@end
