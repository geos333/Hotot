//
//  HUDImageController.h
//  Hotot_mac
//
//  Created by geos on 22.07.13.
//  Created by @Kee_Kun on 11/09/24.
//  Hotot For Mac is licensed under LGPL version 3.
//

#import <Cocoa/Cocoa.h>

@interface HUDImageController : NSWindowController
{
    IBOutlet NSImageView *imageView;
    IBOutlet NSPanel *imageWindow;
    IBOutlet NSScrollView *scrollView;
}

@property (nonatomic, retain) IBOutlet NSImageView *imageView;
@property (nonatomic, retain) IBOutlet NSPanel *imageWindow;
@property (nonatomic, retain) IBOutlet NSScrollView *scrollView;

@end