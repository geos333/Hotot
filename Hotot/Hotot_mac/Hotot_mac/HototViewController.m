//
//  HototViewController.m
//  Hotot_mac
//
//  Created by geos on 22.07.13.
//  Created by @Kee_Kun on 11/09/24.
//  Hotot For Mac is licensed under LGPL version 3.
//

#import "HototViewController.h"

@implementation HototViewController

- (NSString *)_url_decode:(NSString *)string {
    NSString *data = [string stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    data = [data stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return data;
}

- (void)doPaste {
    [webView doCommandBySelector:@selector(pasteAsPlainText:)];
}

- (void)doCopy {
    [webView doCommandBySelector:@selector(copy:)];
}

- (void)copyText:(NSString *)text {
    NSPasteboard *clipboard = [NSPasteboard generalPasteboard];
    [clipboard declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:nil];
    [clipboard setString:text forType:NSStringPboardType];
    [clipboard release];
}

- (NSDictionary *) registrationDictionaryForGrowl {
    NSArray *array = [NSArray arrayWithObjects:@"notify", nil];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithInt:1],
                          @"TicketVersion",
                          array,
                          @"AllNotifications",
                          array,
                          @"DefaultNotifications",
                          nil];
    return dict;
}

- (void) growlMessage:(NSString *)message title:(NSString *)title avatar:(NSURL *)avatar type:(NSString *)type clickContext:(NSString *)clickContext {
    dispatch_async( dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0 ), ^(void) {
        NSData *image = [[[NSData alloc] initWithContentsOfURL:avatar] autorelease];
        dispatch_async( dispatch_get_main_queue(), ^(void){
            [GrowlApplicationBridge notifyWithTitle:title
                                        description:message
                                   notificationName:type
                                           iconData:image ? image : nil
                                           priority:0
                                           isSticky:NO
                                       clickContext:clickContext];
        });
    });
    
}

- (Boolean)on_hotot_action:(NSString *)message {
    if ([message length]>6) {
        NSString *command = [message substringFromIndex:6];
        DLog(@"hotot:%@", command);
        NSArray *params = [command componentsSeparatedByString:@"/"];
        if([params count]>1){
            NSString *type = [NSString stringWithString: [params objectAtIndex:0]];
            if([type isEqualToString:@"action"]){                              //   /action
                NSString *action = [NSString stringWithString: [params objectAtIndex:1]];
                if ([action isEqualToString:@"search"]) {                      //   /action/search
                    // TODO: search
                } else if([action isEqualToString:@"choose_file"]) {           //   /action/choose_file
                    NSString *callback = [NSString stringWithString: [params objectAtIndex:2]];
                    
                    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
                    [openDlg setAllowedFileTypes: [NSArray arrayWithObjects:@"jpg",@"jpeg",@"gif",@"png",nil]];
                    [openDlg setCanChooseFiles:YES];
                    [openDlg setAllowsMultipleSelection:NO];
                    [openDlg setCanChooseDirectories:NO];
                    
                    if ( [openDlg runModal] == NSOKButton ) {
                        NSArray *filenames = [openDlg URLs];
                        if ([filenames count]>0) {
                            // FIXME
                            NSString *filename = [NSString stringWithString:[[filenames objectAtIndex:0] path]];
                            //filename = [self _url_decode:filename];
                            [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@('%@');",callback, filename]];
                            DLog(@"%@('%@');",callback, filename);
                        }
                    }
                    
                    //}else if([action isEqualToString:@"save_avatar"]){             //   /action/save_avatar
                    // TODO: save avatar
                } else if([action isEqualToString:@"log"]) {                     //   /action/log
                    NSString *method = [NSString stringWithString: [params objectAtIndex:2]];
                    NSString *data   = [NSString stringWithString: [params objectAtIndex:3]];
                    method = [self _url_decode:method];
                    data   = [self _url_decode:data];
                    if ([method isEqualToString:@"init"]) {
                        if ([data isEqualToString:@"overlay_variables()"]) {
                            [[NSApp delegate] setHototStatus:HototStatusLoadFinished];
                        }
                    }
                } else if([action isEqualToString:@"paste_clipboard_text"]) {    //   /action/paste_clipboard_text
                    // paste clipboard_text
                    [self doPaste];
                } else if([action isEqualToString:@"set_clipboard_text"]) {      //   /action/set_clipborad_text
                    // set clipboard_text
                    NSString *copied = [command substringFromIndex:[@"action/set_clipboard_text/" length]];
                    [self copyText:copied];
                }
            } else if ([type isEqualToString:@"system"]) {                      //   /system
                NSString *method = [NSString stringWithString: [params objectAtIndex:1]];
                if ([method isEqualToString:@"quit"]) {                        //   /system/quit
                    [NSApp terminate];
                } else if ([method isEqualToString:@"notify"]) {
                    NSString *notifyType = [self _url_decode:[NSString stringWithString: [params objectAtIndex:2]]];
                    NSString *body       = [self _url_decode:[NSString stringWithString: [params objectAtIndex:3]]];
                    NSString *summary    = [self _url_decode:[NSString stringWithString: [params objectAtIndex:4]]];
                    NSURL *avatar        = [NSURL URLWithString:[self _url_decode:[NSString stringWithString: [params objectAtIndex:5]]]];
                    if ([notifyType isEqualToString:@"content"]) {
                        [self growlMessage:summary title:body avatar:avatar type:@"notify" clickContext:nil];
                    }else if([notifyType isEqualToString:@"count"]){
                        // TODO: count it
                    }
                } else if ([method isEqualToString:@"unread_alert"]) {
                    NSString *count = [self _url_decode:[NSString stringWithString: [params objectAtIndex:2]]];
                    if (![count isEqualToString:@"0"]) {
                        [[NSApp dockTile] setBadgeLabel:count];
                    } else {
                        [[NSApp dockTile] setBadgeLabel:nil];
                    }
                } else if ([method isEqualToString:@"sign_in"]) {
                    [[NSApp delegate] setHototStatus:HototStatusSignin];
                }
            }
        }
    }
    return TRUE;
}

/*
 *   Handle all request
 */
- (Boolean)handle_uri:(NSURLRequest *)request {
    NSString *scheme = [[request URL] scheme];
    NSString *url    = [[request URL] absoluteString];
    NSString *ext    = [[url pathExtension] lowercaseString];
    
    if ([scheme isEqualToString:@"file"]) {
        return FALSE;
    } else if ([scheme isEqualToString:@"hotot"]) {
        [self on_hotot_action:url];
        return TRUE;
    } else if ([scheme isEqualToString:@"about"]) {
        return TRUE;
    } else if ([scheme isEqualToString:@"http"] || [scheme isEqualToString:@"https"]) {
        
        if ([[[request URL] host] isEqualToString:@"stat.hotot.org"]) {
            return FALSE;
        } else if ( [ext isEqualToString:@"jpg"]  ||
                   [ext isEqualToString:@"jpeg"] ||
                   [ext isEqualToString:@"gif"]  ||
                   [ext isEqualToString:@"bmp"]  ||
                   [ext isEqualToString:@"tiff"] ||
                   [ext isEqualToString:@"png"]  ){
            [[NSApp delegate] showHUDImage:[request URL]];
        } else {
            [[NSWorkspace sharedWorkspace] openURL:[request URL]];
            return TRUE;
        }
    }
    return TRUE;
}

/*
 * On Navigation Requested
 */
- (void)webView:(WebView *)webView decidePolicyForNavigationAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id<WebPolicyDecisionListener>)listener {
    if ([self handle_uri:request]) {
        [listener ignore];
    } else {
        [listener use];
    }
}


/*
 * On New Window
 */
- (void)webView:(WebView *)webView decidePolicyForNewWindowAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request newFrameName:(NSString *)frameName decisionListener:(id<WebPolicyDecisionListener>)listener {
    if ([self handle_uri:request]) {
        [listener ignore];
    } else {
        [listener use];
    }
}

/*
 * On Alert
 */
- (void)webView:(WebView *)sender runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WebFrame *)frame {
    [self on_hotot_action:message];
}

/*
 * On Confirm
 */
- (BOOL)webView:(WebView *)sender runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WebFrame *)frame {
    NSInteger result = NSRunInformationalAlertPanel(
                                                    NSLocalizedString(@"Please Confirm", @""),
                                                    message,
                                                    NSLocalizedString(@"OK", @""),
                                                    NSLocalizedString(@"Cancel", @""),
                                                    nil
                                                    );
    return NSAlertDefaultReturn == result;
}

/*
 * On Load Finished
 */
- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame {
    // Get fonts
    NSArray *fontFamilies = [[NSFontManager sharedFontManager] availableFontFamilies];
    NSString *fonts = [fontFamilies count] > 0 ?
    [NSString stringWithFormat:@"[\"%@\"]",[fontFamilies componentsJoinedByString:@"\",\""]] :
    @"''";
    
    // Get locale
    NSString *locale = [[NSLocale currentLocale] localeIdentifier];
    
    // Generate the trigger
    NSString *_trigger_js = @"overlay_variables({platform:'Mac',"
    "conf_dir:'%@'," //Not supported yet
    "cache_dir:'%@'," //Not supported yet
    "avatar_cache_dir:'%@'," //Not supported yet
    "extra_fonts: %@ ,"
    "extra_exts:'%@'," //Not supported yet
    "extra_themes:'%@'," //Not supported yet
    "locale:'%@'});"
    "globals.load_flags=1;";
    
    _trigger_js = [NSString stringWithFormat:_trigger_js,@"",@"",@"",fonts,@"",@"",locale];
    [sender stringByEvaluatingJavaScriptFromString:_trigger_js];
    
}

- (void)webView:(WebView *)webView addMessageToConsole:(NSDictionary *)dictionary; {
    NSString *message = [dictionary objectForKey:@"message"];
    NSString *source  = [dictionary objectForKey:@"sourceURL"];
    NSNumber *line    = [dictionary objectForKey:@"lineNumber"];
    
    if ([message rangeOfString:@"SECURITY_ERR"].location != NSNotFound) {
        [[NSApp delegate] onSecurityError];
    }
    
    DLog(@"HOTOTLOG:%d @ %@ @ %@",[line intValue],message,source);
}


- (void)awakeFromNib {
 	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    // Enable cross-domain XMLHttpRequest
    [defaults setObject:@"YES" forKey:@"WebKitAllowUniversalAccessFromFileURLsPreferenceKey"];
    [defaults setObject:@"YES" forKey:@"WebKitAllowFileAccessFromFileURLs"];
    
    // Enable local database
    // [defaults setObject:@"YES" forKey:@"WebKitDatabasesEnabledPreferenceKey"];
    // Unfortunately, we have to use private method
    WebPreferences* prefs = [webView preferences];
    [prefs setDatabasesEnabled:YES];
    
    // Setup the database directory
    NSString* datadir = @"~/Library/Application Support/Hotot-For-Mac/Databases";
 	[defaults setObject:datadir forKey:@"WebDatabaseDirectory"];
 	[defaults setObject:datadir forKey:@"WebKitLocalStorageDatabasePathPreferenceKey"];
    
    // Other features
    [defaults setObject:@"YES" forKey:@"WebKitUsesPageCachePreferenceKey"];
    [defaults setObject:@"YES" forKey:@"WebKitJavaScriptCanAccessClipboard "];
    
 	[defaults synchronize];
    
    /* avoid to use private method */
    /*
     // Setup Web Preferences
     WebPreferences* prefs = [webView preferences];
     [prefs setUsesPageCache:YES];
     [prefs setJavaScriptCanAccessClipboard:YES]; // private method
     // Enable cross-domain XMLHttpRequest
     [prefs setAllowUniversalAccessFromFileURLs:YES]; // private method
     [prefs setAllowFileAccessFromFileURLs:YES];      // private method
     // Enable local database & storage
     [prefs setDatabasesEnabled:YES];                 // private method
     //[prefs setLocalStorageEnabled:YES];              // private method
     */
    
    // Setup all Delegates
    [webView setPolicyDelegate:self];
    [webView setFrameLoadDelegate:self];
    [webView setUIDelegate:self];
    [webView setResourceLoadDelegate:self];
    
    // Load the page
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html" inDirectory:@"data"];
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    [webView.mainFrame loadRequest:[NSURLRequest requestWithURL:fileURL]];
    
    // Register Growl
    [GrowlApplicationBridge setGrowlDelegate:self];
    
    [self setView:webView];
    
    [[NSApp delegate] setHototStatus: HototStatusInit];
}



@end

