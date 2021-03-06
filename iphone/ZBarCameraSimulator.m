//------------------------------------------------------------------------
//  Copyright 2010-2011 (c) Jeff Brown <spadix@users.sourceforge.net>
//
//  This file is part of the ZBar Bar Code Reader.
//
//  The ZBar Bar Code Reader is free software; you can redistribute it
//  and/or modify it under the terms of the GNU Lesser Public License as
//  published by the Free Software Foundation; either version 2.1 of
//  the License, or (at your option) any later version.
//
//  The ZBar Bar Code Reader is distributed in the hope that it will be
//  useful, but WITHOUT ANY WARRANTY; without even the implied warranty
//  of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU Lesser Public License for more details.
//
//  You should have received a copy of the GNU Lesser Public License
//  along with the ZBar Bar Code Reader; if not, write to the Free
//  Software Foundation, Inc., 51 Franklin St, Fifth Floor,
//  Boston, MA  02110-1301  USA
//
//  http://sourceforge.net/projects/zbar
//------------------------------------------------------------------------

#import <ZBarSDK/ZBarCameraSimulator.h>
#import <ZBarSDK/ZBarReaderView.h>

// hack around missing simulator support for AVCapture interfaces

@implementation ZBarCameraSimulator

@synthesize readerView;

- (instancetype) initWithViewController: (UIViewController*) vc
{
    if(!TARGET_IPHONE_SIMULATOR) {
        [self release];
        return(nil);
    }
    self = [super init];
    if(!self)
        return(nil);

    viewController = vc;

    return(self);
}

- (void) dealloc
{
    viewController = nil;
    readerView = nil;
    [picker release];
    picker = nil;
    [super dealloc];
}

- (void) setReaderView: (ZBarReaderView*) view
{
    ZBarReaderView *oldView = readerView;
    readerView = [view retain];
    [oldView release];

    UILongPressGestureRecognizer *gesture =
        [[UILongPressGestureRecognizer alloc]
            initWithTarget: self
            action: @selector(didLongPress:)];
    gesture.numberOfTouchesRequired = 2;
    [view addGestureRecognizer: gesture];
    [gesture release];
}

- (void) didLongPress: (UILongPressGestureRecognizer*) gesture
{
    if(gesture.state == UIGestureRecognizerStateBegan)
        [self takePicture];
}

- (void) takePicture
{
    if(!picker) {
        picker = [UIImagePickerController new];
        picker.delegate = self;
    }
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		
		[picker setModalPresentationStyle:UIModalPresentationPopover];
		
		[viewController presentViewController:picker
									 animated:YES
								   completion:nil];
		
		// Get the popover presentation controller and configure it.
		UIPopoverPresentationController *presentationController = [picker popoverPresentationController];
		presentationController.delegate = self;
		presentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
		presentationController.sourceView = readerView;
		presentationController.sourceRect = CGRectZero;
    }
    else
        [viewController presentViewController: picker
									 animated: YES
								   completion: ^{}];
}

- (void)  imagePickerController: (UIImagePickerController*) _picker
  didFinishPickingMediaWithInfo: (NSDictionary*) info
{
    UIImage *image = [info objectForKey: UIImagePickerControllerOriginalImage];

    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        [viewController dismissViewControllerAnimated:YES completion:nil];
    else
		[_picker dismissViewControllerAnimated: YES completion: ^{}];

    [readerView performSelector: @selector(scanImage:)
                withObject: image
                afterDelay: .1];
}

- (void) imagePickerControllerDidCancel: (UIImagePickerController*) _picker
{
	[_picker dismissViewControllerAnimated: YES completion: ^{}];
}

@end
