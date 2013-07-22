//
//  HUDImageController.m
//  Hotot_mac
//
//  Created by geos on 22.07.13.
//  Created by @Kee_Kun on 11/09/24.
//  Hotot For Mac is licensed under LGPL version 3.
//

#import "HUDImageController.h"

@implementation HUDImageController

@synthesize imageView, imageWindow, scrollView;


- (BOOL)windowShouldClose:(NSNotification *)notification
{
	[imageWindow orderOut:self];
	return NO;
}

- (void)showImageWithURL:(NSURL *)imageURL {
    
    if (![self isWindowLoaded]) {
        [self showWindow:self];
    }
    NSImage *loadingImage = [NSImage imageNamed:@"loading.gif"];
    
    [imageView setImage:loadingImage];
    [imageView setImageAlignment:NSImageAlignCenter];
    
    NSRect screenRect;
    screenRect = [[NSScreen mainScreen] visibleFrame];
    NSRect loadingRect = NSMakeRect((screenRect.size.width - 100) / 2, (screenRect.size.height - 100) / 2, 200, 200);
    
    [imageWindow setFrame:loadingRect display:YES animate:YES];
    
    [imageWindow orderFront:self];
    
    dispatch_async( dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0 ), ^(void){
        NSImage *image = [[NSImage alloc] initWithContentsOfURL:imageURL];
        dispatch_async( dispatch_get_main_queue(), ^(void){
            if (image) {
                CGFloat width;
                CGFloat height;
                CGFloat left;
                CGFloat top;
                CGFloat maxWidth  = screenRect.size.width * 0.9;
                CGFloat maxHeight = screenRect.size.height * 0.9;
                
                height = image.size.height <= maxHeight ? image.size.height : maxHeight;
                width  = image.size.width <= maxWidth ? image.size.width : maxWidth;
                left   = (screenRect.size.width - width) / 2;
                top    = (screenRect.size.height - height) / 2;
                
                [imageWindow setFrame:NSMakeRect(left, top, width+20, height+20) display:YES animate:YES];
                
                NSRect imageRect = NSMakeRect(0.0, 0.0, image.size.width,image.size.height);
                
                [imageView setFrame:imageRect];
                [imageView setImage:image];
                
                // Scroll the view to top-left
                [[scrollView contentView] scrollToPoint:NSMakePoint(0, image.size.height-height)];
                [scrollView reflectScrolledClipView:[scrollView contentView]];
                
                [image release];
                
            }
        });
    });
}

@end
