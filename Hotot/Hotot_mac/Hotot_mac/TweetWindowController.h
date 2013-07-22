//
//  TweetWindowController.h
//  Hotot_mac
//
//  Created by geos on 22.07.13.
//  Created by @Kee_Kun on 11/09/24.
//  Hotot For Mac is licensed under LGPL version 3.
//

#import <Cocoa/Cocoa.h>

@interface TweetSheetWindow : NSWindow

- (BOOL)canBecomeKeyWindow;

@end


@interface TweetWindowController : NSWindowController
{
    IBOutlet TweetSheetWindow *tweetWindow;
}
- (IBAction)onClose:(id)sender;
- (IBAction)onEdit:(id)sender;

@end

