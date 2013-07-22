//
//  HototWindowController.m
//  Hotot_mac
//
//  Created by geos on 22.07.13.
//  Created by @Kee_Kun on 11/09/24.
//  Hotot For Mac is licensed under LGPL version 3.
//

#import "HototWindowController.h"


@implementation HototWindowController

@synthesize hototViewController;

- (void)windowDidLoad {
    [super windowDidLoad];
    
    hototViewController = [[HototViewController alloc] initWithNibName:@"HototView" bundle:nil];
    [hototView addSubview:hototViewController.view];
}

- (void)showTweetWindow {
    [(WebView *)hototViewController.view stringByEvaluatingJavaScriptFromString:@"ui.StatusBox.open();"];
}
- (void)showPrefWindow {
    [(WebView *)hototViewController.view stringByEvaluatingJavaScriptFromString:@"globals.prefs_dialog.open();"];
}
- (void)showAboutWindow {
    [(WebView *)hototViewController.view stringByEvaluatingJavaScriptFromString:@"globals.about_dialog.open();"];
}

@end
