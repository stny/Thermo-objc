//
//  SMCManager.m
//  Thermo
//
//  Created by Naoya Sato on 5/7/14.
//  Copyright (c) 2014 Naoya Sato. All rights reserved.
//

#import "SMCManager.h"
#import "smc.h"

#define CPUKEY "TC0F"

@interface SMCManager()
// Private Variables
//@property (nonatomic, assign) io_connect_t conn;
@end

@implementation SMCManager

io_connect_t conn;

+ (instancetype)sharedManager
{
    static SMCManager *sharedSMCManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedSMCManager = [[self alloc] init];
    });
    return sharedSMCManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        SMCOpen(&conn);
    }
    return self;
}

- (void) dealloc
{
    SMCClose(conn);
}

- (float) getTemperature
{
    SMCVal_t val;
    SMCReadKey2(CPUKEY, &val, conn);
    return ((val.bytes[0] * 256 + val.bytes[1]) >> 2)/64;
}

@end
