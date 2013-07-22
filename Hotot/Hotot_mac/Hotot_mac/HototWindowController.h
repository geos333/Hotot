//
//  HototWindowController.h
//  Hotot_mac
//
//  Created by geos on 22.07.13.
//  Created by @Kee_Kun on 11/09/24.
//  Hotot For Mac is licensed under LGPL version 3.
//

#import <Cocoa/Cocoa.h>
#import "HototViewController.h"

@interface HototWindowController : NSWindowController
{
    HototViewController *hototViewController;
    IBOutlet NSView *hototView;
}

@property (nonatomic, readonly) HototViewController *hototViewController;

@end
