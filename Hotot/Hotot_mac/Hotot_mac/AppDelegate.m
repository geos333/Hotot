//
//  AppDelegate.m
//  Hotot_mac
//
//  Created by geos on 22.07.13.
//  Created by @Kee_Kun on 11/09/24.
//  Hotot For Mac is licensed under LGPL version 3.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)setHototStatus:(HototStatus)status {
    hototStatus = status;
}

- (void)setupDatabaseDirectory {
    // Create the directory
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *folder = @"~/Library/Application Support/Hotot/Databases";
    folder = [folder stringByExpandingTildeInPath];
    
    if ([fileManager fileExistsAtPath: folder] == NO) {
        [fileManager createDirectoryAtPath: folder withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    // Retrieve the databases.db
    NSString *toPath = @"~/Library/Application Support/Hotot/Databases/Databases.db";
    toPath = [toPath stringByExpandingTildeInPath];
    DLog(@"%@", toPath);
    if ([fileManager fileExistsAtPath: toPath] == NO) {
        // Copy the database to application support directory.
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Databases" ofType:@"db"];
        NSURL *fileURL = [NSURL fileURLWithPath:filePath];
        [fileManager copyItemAtURL:fileURL toURL:[NSURL fileURLWithPath:toPath] error:nil];
    }
    
    
    
}

- (void)showTweetBox {
    [[tweetWindowController window] setFrame:CGRectMake(0,0,380,200) display:YES animate:YES];
    [NSApp beginSheet:[tweetWindowController window] modalForWindow:[hototWindowController window] modalDelegate:tweetWindowController didEndSelector:@selector(didEndTweetSheet:returnCode:contextInfo:) contextInfo:nil];
}

- (void)closeTweetBox {
    [NSApp endSheet:[tweetWindowController window]];
}

- (void)showHUDImage:(NSURL *)imageURL {
    [hudImageController showImageWithURL:imageURL];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self setupDatabaseDirectory];
    
    if (hototWindowController == NULL) {
        hototWindowController = [[HototWindowController alloc] initWithWindowNibName:@"HototWindow"];
        [hototWindowController showWindow:self];
    }
    if (tweetWindowController == NULL) {
        tweetWindowController = [[TweetWindowController alloc] initWithWindowNibName:@"TweetWindow"];
    }
    if (hudImageController == NULL) {
        hudImageController = [[HUDImageController alloc] initWithWindowNibName:@"HUDImage"];
    }
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag {
    if (flag) {
        [[hototWindowController window] orderFront:self];
        return NO;
    }else{
        [[hototWindowController window] orderFront:self];
        return YES;
    }
}


- (void)didEndSecurityError:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    [NSApp terminate:self];
}

- (void)onSecurityError {
    NSAlert *alert = [[[NSAlert alloc] init] autorelease];
    [alert setMessageText:NSLocalizedString(@"Please reopen Hotot for Mac to apply settings.", @"")];
    [alert beginSheetModalForWindow:[hototWindowController window]
                      modalDelegate:self
                     didEndSelector:@selector(didEndSecurityError:returnCode:contextInfo:)
                        contextInfo:nil];
    
}

- (IBAction)onNewTweet:(id)sender {
    [hototWindowController showTweetWindow];
}
- (IBAction)onPrefWindow:(id)sender {
    [hototWindowController showPrefWindow];
}
- (IBAction)onAboutWindow:(id)sender {
    [hototWindowController showAboutWindow];
    
}




//Hide and Show window by status icon
- (IBAction)HideShowWindow:(id)sender {
    
    if (![hototWindowController.window isKeyWindow]){
        [[hototWindowController window] orderFront:self];
        [[hototWindowController window] makeKeyWindow];
        [[hototWindowController window] orderFrontRegardless];
    }
    else {
        [[hototWindowController window] orderOut:self];
    }
}

- (IBAction)onMarkRead:(id)sender {
}

- (IBAction)copy:(id)sender {
    [hototWindowController.hototViewController doCopy];
}

- (IBAction)paste:(id)sender {
    [hototWindowController.hototViewController doPaste];
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
    if ([menuItem action] == @selector(onNewTweet:)) {
        return hototStatus == HototStatusSignin;
    } else if([menuItem action] == @selector(onMarkRead:)) {
        // TODO
        return NO;
    } else if([menuItem action] == @selector(copy:) || ([menuItem action] == @selector(paste:))) {
        return hototStatus >= HototStatusLoadFinished;
    }
    return YES;
}


- (void)dealloc {
    [tweetWindowController dealloc];
    [hototWindowController dealloc];
    [super dealloc];
}
//status menu

-(void)awakeFromNib{
    statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];
   
    [statusItem setMenu:statusMenu];
    [statusItem setImage:[NSImage imageNamed:@"ic24_hotot.png"]];
    [statusItem setHighlightMode:YES];
    [statusItem setAction:@selector(statusItemClicked:)];

}


@end

