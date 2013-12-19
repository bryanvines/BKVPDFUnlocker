//
//  BKVPDFUnlocker.m
//
//  Created by Bryan Vines on 12/18/13.
//  Copyright (c) 2013 Bryan Vines. All rights reserved.
//

/*
 
    Register as an observer of this class's "unlockedPDF" property.
    When the property is not nil, it contains an unlocked PDFDocument.
 
 */

#import "BKVPDFUnlocker.h"

@interface BKVPDFUnlocker ()

@end

@implementation BKVPDFUnlocker

#pragma mark - Initialization Methods
- (id) initWithWindow:(NSWindow *)window {
    //--------------------------------------------------------------------------------------------------------
    //
    //  initWithWindow:
    //
    //  synopsis:       retval = [self initWithWindow:];
    //                      retval id - Returns an initialized object.
    //
    //  description:    initWithWindow: is designed provide the opportunity to perform any initialization
    //                  when this class is being instantiated.
    //
    //  errors:         none
    //
    //  returns:        Initialized object.
    //
    //--------------------------------------------------------------------------------------------------------

    self = [super initWithWindow:window];
    if (self) {
        // Set up initial properties.
        [self resetProperties];
        
        // Set up KVO.
        [self registerAsObserver];
        
    }

    // Return an initailized object.
    return self;
}

#pragma mark - GUI Methods
- (void) windowDidLoad {
    //--------------------------------------------------------------------------------------------------------
    //
    //  windowDidLoad
    //
    //  synopsis:       [self windowDidLoad];
    //                      void - No return value from this method.
    //
    //  description:    windowDidLoad is designed provide the opportunity to perform any initialization after
    //                  the window controller's window has been loaded from its nib file.
    //
    //  errors:         none
    //
    //  returns:        none
    //
    //--------------------------------------------------------------------------------------------------------

    // Call the superclass's windowDidLoad method so it can do whatever it needs to do.
    [super windowDidLoad];
    
    // Then implement any initialization code here.
    
}

#pragma mark - KVO Methods
- (void) registerAsObserver {
    //--------------------------------------------------------------------------------------------------------
    //
    //  registerAsObserver
    //
    //  synopsis:       [self registerAsObserver];
    //                      void - No return value from this method.
    //
    //  description:    registerAsObserver is designed to register this class as an observer of the
    //                  its own lockedFileURL property.
    //
    //  errors:         none
    //
    //  returns:        none
    //
    //--------------------------------------------------------------------------------------------------------
    
    // Tell the uploadController to add us as an observer of its isUploading property.
    // We want to be notified when a new value has been set.
    [self addObserver:self
           forKeyPath:@"lockedFileURL"
              options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld)
              context:NULL];
}
- (void) observeValueForKeyPath:(NSString *)keyPath
                       ofObject:(id)object
                         change:(NSDictionary *)change
                        context:(void *)context {
    //--------------------------------------------------------------------------------------------------------
    //
    //  observeValueForKeyPath:ofObject:change:context:
    //
    //  synopsis:       [self observeValueForKeyPath:ofObject:change:context:];
    //                      void                    - No return value from this method.
    //                      NSString *keyPath       - A given string variable.
    //                      id object               - The object nofiying us of the change.
    //                      NSDictionary *change    - A dictionary containing change information.
    //                      void context            - The context used when setting up the observation.
    //
    //  description:    observeValueForKeyPath:ofObject:change:context: is designed to handle observations
    //                  of changes for which we have registered.
    //
    //  errors:         none
    //
    //  returns:        none
    //
    //--------------------------------------------------------------------------------------------------------
    
    // We're registered to receive notifications when the our lockedFileURL property is changed.
    if ([keyPath isEqual:@"lockedFileURL"]) {
        if ([change objectForKey:NSKeyValueChangeNewKey] != nil) {
            // If the property is not nil, set a message in our unlockerMessage property.
            self.unlockerMessage = [self message];
        }
    }
}

#pragma mark - Utility Methods
- (void) resetProperties {
    //--------------------------------------------------------------------------------------------------------
    //
    //  resetProperties
    //
    //  synopsis:       [self resetProperties];
    //                      void    - No return value from this method.
    //
    //  description:    resetProperties is designed to set this class's properties to standard values.
    //
    //  errors:         none
    //
    //  returns:        none
    //
    //--------------------------------------------------------------------------------------------------------
    
    // Set up initial properties.
    self.unlockerWindowTitle = @"Password Required";
    self.unlockerMessage     = @"No message set.";
    self.password            = nil;
    self.lockedFileURL       = nil;
    self.unlockedPDF         = nil;
}
- (NSString *) message {
    //--------------------------------------------------------------------------------------------------------
    //
    //  message
    //
    //  synopsis:       retval = [self message];
    //                      NSString * retval   - No return value from this method.
    //
    //  description:    message is designed to create a message describing the need for a password to unlock
    //                  a file.
    //
    //  errors:         none
    //
    //  returns:        NSString
    //
    //--------------------------------------------------------------------------------------------------------

    // The name of the locked file.
    NSString * lockedFileName = self.lockedFileURL.lastPathComponent;
    
    // Create a message.
    NSString * unlockMessage = [NSString stringWithFormat:@"The file “%@” requires a password to unlock. Please provide the password for this file.",lockedFileName];

    // Return the message.
    return unlockMessage;
}
- (BOOL) unlockPDF {
    //--------------------------------------------------------------------------------------------------------
    //
    //  unlockPDF
    //
    //  synopsis:       retval = [self unlockPDF];
    //                      BOOL retval - YES if document was unlocked. NO otherwise.
    //
    //  description:    unlockPDF is designed to unlock a PDF document.
    //                  Upon successful unlocking, this class's unlockedPDF property will contain a
    //                  PDFDocument.
    //
    //  errors:         none
    //
    //  returns:        none
    //
    //--------------------------------------------------------------------------------------------------------

    // Get the locked PDF document.
    PDFDocument * lockedPDF = [[PDFDocument alloc]initWithURL:self.lockedFileURL];
    
    // Initialize a PDF document to hold the pages of the unlocked document.
    PDFDocument * unlockedPDF;

    // Attempt to unlock the PDF document with the password given.
    if ([lockedPDF unlockWithPassword:self.password]) {
        
        // The document was unlocked. Initialize a PDF document to hold its pages.
        unlockedPDF = [[PDFDocument alloc]init];
        
        // Copy pages from unlocked PDF document into new PDF document.
        for (NSInteger currentPageIndex = 0; currentPageIndex < lockedPDF.pageCount; currentPageIndex++) {
            [unlockedPDF insertPage:[lockedPDF pageAtIndex:currentPageIndex] atIndex:currentPageIndex];
        }
        
        // Set our unlockedPDF property.
        self.unlockedPDF = unlockedPDF;
        
        // Return YES, since we unlocked the document.
        return YES;
    } else {
        // The document was not unlocked.
        // Return NO.
        return NO;
    }
}

#pragma mark - Interface Actions
- (IBAction) clickedOK:(id)sender {
    //--------------------------------------------------------------------------------------------------------
    //
    //  methodName:
    //
    //  synopsis:       [self methodName:aString];
    //                      void                - No return value from this method.
    //                      NSString aString    - A given string variable.
    //
    //  description:    methodName is designed to
    //
    //  errors:         none
    //
    //  returns:        none
    //
    //--------------------------------------------------------------------------------------------------------
    
    // The user clicked the OK button. Let's try to unlock the PDF.
    if ([self unlockPDF]) {
        // The PDF was unlocked.
        // Our unlockedPDF property contains the PDF document.
        // We can close the window.
        [self.window close];
    } else {
        // The PDF was not unlocked. Bad password?
        // Beep, clear the password, let the user try again.
        NSBeep();
        self.password = nil;
    }
    
}
- (IBAction) clickedCancel:(id)sender {
    //--------------------------------------------------------------------------------------------------------
    //
    //  methodName:
    //
    //  synopsis:       [self methodName:aString];
    //                      void                - No return value from this method.
    //                      NSString aString    - A given string variable.
    //
    //  description:    methodName is designed to
    //
    //  errors:         none
    //
    //  returns:        none
    //
    //--------------------------------------------------------------------------------------------------------
    

    [self.window close];
    [self resetProperties];
}

@end
