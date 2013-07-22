//
//  HototViewController.h
//  Hotot_mac
//
//  Created by geos on 22.07.13.
//  Created by @Kee_Kun on 11/09/24.
//  Hotot For Mac is licensed under LGPL version 3.
//

#import <Cocoa/Cocoa.h>

#import <WebKit/WebKit.h>

#import <WebKit/WebPolicyDelegate.h>
#import <WebKit/WebFrameLoadDelegate.h>
#import <WebKit/WebUIDelegate.h>
#import <WebKit/WebResourceLoadDelegate.h>

#import <WebKit/WebPreferences.h>

#import <Growl/Growl.h>

#import "hotot.h"

@protocol WebPolicyDelegate

- (void)webView:(WebView *)webView decidePolicyForNavigationAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id<WebPolicyDecisionListener>)listener;
- (void)webView:(WebView *)webView decidePolicyForNewWindowAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request newFrameName:(NSString *)frameName decisionListener:(id<WebPolicyDecisionListener>)listener;

@end

@protocol WebFrameLoadDelegate

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame;

@end

@protocol WebUIDelegate

- (BOOL)webView:(WebView *)sender runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WebFrame *)frame;
- (void)webView:(WebView *)sender runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WebFrame *)frame;
- (void)webView:(WebView *)webView addMessageToConsole:(NSDictionary *)dictionary;

@end

@protocol WebResourceLoadDelegate
@end

@interface HototViewController : NSViewController <WebPolicyDelegate, WebFrameLoadDelegate, WebUIDelegate, WebResourceLoadDelegate,GrowlApplicationBridgeDelegate>
{
    IBOutlet WebView *webView;
}

@end

