//
//  PS_UI_DragView.h
//  PedalStack
//
//  Created by Poppy on 11/16/16.
//  Copyright © 2016 Deepak Chennakkadan. All rights reserved.
//

#ifndef PS_UI_DragView_h
#define PS_UI_DragView_h

#include "PS_Headers.h"

@interface PS_UI_DragView : NSImageView <NSDraggingSource, NSDraggingDestination, NSPasteboardItemDataProvider>
{
    //highlight the drop zone
    BOOL highlight;
}

- (id)initWithCoder:(NSCoder *)coder;

@end

#endif /* PS_UI_DragView_h */