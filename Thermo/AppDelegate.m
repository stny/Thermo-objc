//
//  AppDelegate.m
//  Thermo
//
//  Created by Naoya Sato on 7/8/14.
//  Copyright (c) 2014 Naoya Sato. All rights reserved.
//

#import "AppDelegate.h"
#import "SMCManager.h"

#define ACTIVITY_MONITOR @"/Applications/Utilities/Activity Monitor.app"

@interface AppDelegate()
@property (nonatomic, strong) SMCManager *manager;
@end

@implementation AppDelegate {
    dispatch_source_t timer;
    dispatch_source_t timerInMenu;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    _statusItem.title = @"";
    _statusItem.highlightMode = YES;
    _statusItem.image = [NSImage imageNamed:@"Status"];
    
    NSMenu *menu = [[NSMenu alloc] init];
    [menu addItemWithTitle:@"47 \u00b0C" action:nil keyEquivalent:@""];
    [menu addItemWithTitle:@"Open Activity Monitor" action:@selector(launchActivityMonitor:) keyEquivalent:@""];
    [menu addItem:[NSMenuItem separatorItem]];
    [menu addItemWithTitle:@"Quit Thermo" action:@selector(terminate:) keyEquivalent:@""];
    [menu setDelegate:self];
    
    _statusItem.menu = menu;
    _manager = [SMCManager sharedManager];
    
    timer = createDispatchTimer(10ull * NSEC_PER_SEC,
                                0,
                                dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                                ^{
                                    float temperature = [_manager getTemperature];
                                    NSString *temp = [NSString stringWithFormat:@"%@%CC",
                                                      [NSNumber numberWithFloat:temperature],
                                                      (unsigned short)0xb0];
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        if (temperature <= 60) {
                                            _statusItem.image =[NSImage imageNamed:@"Status"];
                                        } else if (temperature <= 70) {
                                            _statusItem.image =[NSImage imageNamed:@"StatusWarm"];
                                        } else {
                                            _statusItem.image =[NSImage imageNamed:@"StatusHot"];
                                        }
                                        
#if DEBUG
                                        NSLog(@"%@", temp);
#endif
                                    });
                                });
    
    timerInMenu = createDispatchTimer(1ull * NSEC_PER_SEC,
                                      0,
                                      dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                                      ^{
                                          [self updateTemperatureItem];
                                      });
    dispatch_suspend(timerInMenu);
    
}

#pragma mark -
#pragma mark Menu methods

- (void)menuWillOpen:(NSMenu *)menu {
    dispatch_resume(timerInMenu);
}

- (void)menuDidClose:(NSMenu *)menu {
    dispatch_suspend(timerInMenu);
}

- (void) updateTemperatureItem {
    float temperature = [_manager getTemperature];
    NSString *temp = [NSString stringWithFormat:@"%@%CC",
                      [NSNumber numberWithFloat:temperature],
                      (unsigned short)0xb0];
    dispatch_async(dispatch_get_main_queue(), ^{
        NSMenuItem *item = [_statusItem.menu itemAtIndex:0];
        [item setTitle:temp];
    });
}

#pragma mark -
#pragma mark Menu actions

- (void)launchActivityMonitor:(id)sender {
    [[NSWorkspace sharedWorkspace] launchApplication:ACTIVITY_MONITOR];
}
- (void)measurement:(id)sender {
    [_manager getTemperature];
}

#pragma mark -
#pragma mark private func

dispatch_source_t createDispatchTimer(uint64_t interval,
                                      uint64_t leeway,
                                      dispatch_queue_t queue,
                                      dispatch_block_t block)
{
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER,
                                                     0, 0, queue);
    if (timer)
    {
        dispatch_source_set_timer(timer, dispatch_walltime(NULL, 0), interval, leeway);
        dispatch_source_set_event_handler(timer, block);
        dispatch_resume(timer);
    }
    return timer;
}

@end