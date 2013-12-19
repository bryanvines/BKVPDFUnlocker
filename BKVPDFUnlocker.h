//
//  BKVPDFUnlocker.h
//
//  Created by Bryan Vines on 12/18/13.
//  Copyright (c) 2013 Bryan Vines. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>

@interface BKVPDFUnlocker : NSWindowController

// Properties
@property (copy) NSString       * unlockerWindowTitle;
@property (copy) NSString       * unlockerMessage;
@property (copy) NSString       * password;
@property (copy) NSURL          * lockedFileURL;
@property        PDFDocument    * unlockedPDF;

// Interface Actions
- (IBAction) clickedOK:(id)sender;
- (IBAction) clickedCancel:(id)sender;

@end
