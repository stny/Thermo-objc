//
//  SMCManager.h
//  Thermo
//
//  Created by Naoya Sato on 5/7/14.
//  Copyright (c) 2014 Naoya Sato. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SMCManager : NSObject
+ (instancetype)sharedManager;
- (float)getTemperature;
@end
