//
//  AppDelegate.h
//  Hotot_mac
//
//  Created by geos on 22.07.13.
//  Created by @Kee_Kun on 11/09/24.
//  Hotot For Mac is licensed under LGPL version 3.
//

#import <Cocoa/Cocoa.h>
#import "HototWindowController.h"
#import "TweetWindowController.h"
#import "HUDImageController.h"

#import "hotot.h"


@interface AppDelegate : NSObject <NSApplicationDelegate> {
    HototWindowController *hototWindowController;
    TweetWindowController *tweetWindowController;
    HUDImageController *hudImageController;
    HototStatus hototStatus;
    //status menu
    IBOutlet NSMenu *statusMenu;
    NSStatusItem * statusItem;
   
}

@end