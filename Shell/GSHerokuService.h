//
//  GSHerokuService.h
//  Shell
//
//  Created by Endika Gutiérrez Salas on 1/10/14.
//  Copyright (c) 2014 Endika Gutiérrez Salas. All rights reserved.
//

#import "TZRESTService.h"

@interface GSHerokuService : TZRESTService <TZRESTServiceDelegate>

@property (nonatomic, copy) NSString *authKey;

+ (instancetype)service;

@end

@interface GSHerokuService (DynamicMethod)

- (void)getAccount:(NSDictionary *)params callback:(TZRESTCallback)callback;
- (void)getApps:(NSDictionary *)params callback:(TZRESTCallback)callback;
- (void)getDynos:(NSDictionary *)params callback:(TZRESTCallback)callback;
- (void)postDyno:(NSDictionary *)params callback:(TZRESTCallback)callback;

@end
