//
//  TweetWindowController.m
//  Hotot_mac
//
//  Created by geos on 22.07.13.
//  Created by @Kee_Kun on 11/09/24.
//  Hotot For Mac is licensed under LGPL version 3.
//

#import "TweetWindowController.h"

@implementation TweetSheetWindow

- (BOOL)canBecomeKeyWindow
{
    return YES;
}

@end


@implementation TweetWindowController



- (void)windowDidLoad
{
    [super windowDidLoad];
}

- (void)didEndTweetSheet:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    [sheet orderOut:self];
}

- (IBAction)onClose:(id)sender {
    NSLog(@"close");
    [[NSApp delegate] closeTweetBox];
}

- (IBAction)onEdit:(id)sender {
    NSLog(@"Edit");
}
@end
