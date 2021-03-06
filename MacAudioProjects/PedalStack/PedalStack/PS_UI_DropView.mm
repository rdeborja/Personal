/*****************************************************************************/
/*!
 \file   PS_UI_DragView.mm
 \author Deepak Chennakkadan
 \par    email: deepak.chennakkadan\@digipen.edu
 \par    DigiPen login: deepak.chennakkadan
 \par    Course: MUS470
 \par    Project: PedalStack
 \date   12/13/2016
 \brief
 This file contains the implementation for a Custom Drag View class for Drag
 & Drop
 */
/*****************************************************************************/

#import "PS_UI_DropView.h"
#import "PS_UI_DragView.h"
#import "PS_UI_Manager.h"
#include <iostream>

@implementation PS_UI_DropView

- (id)initWithCoder:(NSCoder *)coder
{
    self=[super initWithCoder:coder];
    
    if ( self )
    {
        [self registerForDraggedTypes:[PS_UI_DragView pasteboardTypes]];
    }
    
    return self;
}

#pragma mark - Destination Operations

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
    // Check if the pasteboard contains image data and source/user wants it copied
    if ( [self isOurType:[sender draggingPasteboard]] && [sender draggingSourceOperationMask] & NSDragOperationCopy )
    {
        //highlight our drop zone
        highlight=YES;
        
        [self setNeedsDisplay: YES];
        
        /* When an image from one window is dragged over another, we want to resize the dragging item to
         * preview the size of the image as it would appear if the user dropped it in. */
        [sender enumerateDraggingItemsWithOptions: NSDraggingItemEnumerationConcurrent
                                          forView: self
                                          classes:[NSArray arrayWithObject:[NSPasteboardItem class]]
                                    searchOptions: nil
                                       usingBlock:^(NSDraggingItem *draggingItem, NSInteger idx, BOOL *stop) {
                                           
                                           /* Only resize a fragging item if it originated from one of our windows.  To do this,
                                            * we declare a custom UTI that will only be assigned to dragging items we created.  Here
                                            * we check if the dragging item can represent our custom UTI.  If it can't we stop. */
                                           if ( ![self isOurType:[sender draggingPasteboard]])
                                           {
                                               *stop = YES;
                                           }
                                           else
                                           {
                                               /* In order for the dragging item to actually resize, we have to reset its contents.
                                                * The frame is going to be the destination view's bounds.  (Coordinates are local
                                                * to the destination view here).
                                                * For the contents, we'll grab the old contents and use those again.  If you wanted
                                                * to perform other modifications in addition to the resize you could do that here. */
                                               [draggingItem setDraggingFrame:self.bounds contents:[[[draggingItem imageComponents] objectAtIndex:0] contents]];
                                           }
                                       }];
        
        //accept data as a copy operation
        return NSDragOperationCopy;
    }
    
    return NSDragOperationNone;
}

- (void)draggingExited:(id <NSDraggingInfo>)sender
{
    /*------------------------------------------------------
     method called whenever a drag exits our drop zone
     --------------------------------------------------------*/
    //remove highlight of the drop zone
    highlight=NO;
    
    [self setNeedsDisplay: YES];
}


- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
    /*------------------------------------------------------
     method that should handle the drop data
     --------------------------------------------------------*/
    if ( [sender draggingSource] != self )
    {
        NSData *data;
        NSString *string;

        //set the effect type
        if(self.image == nil)
        {
            NSString *name = self.identifier;
            
            if(name == [(PS_UI_Manager *) [NSApp delegate] getEmptyPedalIndex])
            {
                data = [[sender draggingPasteboard] dataForType:[PS_UI_DragView pasteboardType]];
                string = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
                effectType = string;
                [(PS_UI_Manager *)[NSApp delegate] addNewEffect:string];
                
                NSImage *newImage = [(PS_UI_Manager *)[NSApp delegate] getEffectImage:string];
                [self setImage:newImage];
                [newImage release];
                
                std::cout << std::endl << std::string([effectType UTF8String]) << " Pedal Connected!";
                [(PS_UI_Manager *) [NSApp delegate] addPedal:string];
            }
        }
        else
        {
            data = [[sender draggingPasteboard] dataForType:[PS_UI_DragView pasteboardType]];
            string = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
            effectType = string;
            //[(PS_UI_Manager *)[NSApp delegate] addNewEffect:string];
            
            NSImage *newImage = [(PS_UI_Manager *)[NSApp delegate] getEffectImage:string];
            [self setImage:newImage];
            [newImage release];
            
            std::cout << std::endl << std::string([effectType UTF8String]) << " Pedal Connected!";
            
            NSString *name = self.identifier;
            unsigned index;
            sscanf([name UTF8String], "%u", &index);
            [(PS_UI_Manager *) [NSApp delegate] swapPedal:string arg2:index];
            [(PS_UI_Manager *) [NSApp delegate] swapEffect:string arg2:index];
        }
    }
    
    return YES;
}

- (void) mouseDown: (NSEvent *)event
{
    if(effectType != nil)
    {
        [(PS_UI_Manager *)[NSApp delegate] drawControls: effectType];
        [(PS_UI_Manager *)[NSApp delegate] setIndex: self.identifier];
    }
}

- (void)rightMouseDown:(NSEvent *)event
{
    if(![self image])
        return;
    
    NSString *name = self.identifier;
    
    if(name == [(PS_UI_Manager *) [NSApp delegate] getLastPedalIndex])
    {
        std::cout  << std::endl << std::string([effectType UTF8String]) << " Pedal Disconnected!";
        
        if([name isEqualToString:@"0"])
        {
            [(PS_UI_Manager *) [NSApp delegate] removePedal:0];
        }
        else if([name isEqualToString:@"1"])
        {
            [(PS_UI_Manager *) [NSApp delegate] removePedal:1];
        }
        else if([name isEqualToString:@"2"])
        {
            [(PS_UI_Manager *) [NSApp delegate] removePedal:2];
        }
        else if([name isEqualToString:@"3"])
        {
            [(PS_UI_Manager *) [NSApp delegate] removePedal:3];
        }
        else if([name isEqualToString:@"4"])
        {
            [(PS_UI_Manager *) [NSApp delegate] removePedal:4];
        }
        
        [(PS_UI_Manager *) [NSApp delegate] removeEffect];
        [self setImage: nil];
        effectType = nil;
    }
}

-(void)drawRect:(NSRect)rect
{
    /*------------------------------------------------------
     draw method is overridden to do drop highlighing
     --------------------------------------------------------*/
    //do the usual draw operation to display the image
   
    [super drawRect:rect];
    
    if ( highlight )
    {
        NSString *name = self.identifier;
        
        if(name == [(PS_UI_Manager *) [NSApp delegate] getEmptyPedalIndex])
        {
            //highlight by overlaying a gray border
            [[NSColor grayColor] set];
            [NSBezierPath setDefaultLineWidth: 5];
            [NSBezierPath strokeRect: rect];
        }
    }
}

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender
{
    /*------------------------------------------------------
     method to determine if we can accept the drop
     --------------------------------------------------------*/
    //finished with the drag so remove any highlighting
    highlight=NO;
    
    [self setNeedsDisplay: YES];
    
    //check to see if we can accept the data
    return [self isOurType:[sender draggingPasteboard]];
}

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*!
 \brief
 Function to check if incoming object type is the type we want
 
 \param pasteboard
 (Item that was copied to the pasteboard)
 
 \return
 Returns a bool if true or false
 */
/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
-(BOOL)isOurType:(NSPasteboard *)pasteboard
{
    return [[pasteboard types] containsObject:[PS_UI_DragView pasteboardType]];
}

- (NSRect)windowWillUseStandardFrame:(NSWindow *)window defaultFrame:(NSRect)newFrame;
{
    /*------------------------------------------------------
     delegate operation to set the standard window frame
     --------------------------------------------------------*/
    //get window frame size
    NSRect ContentRect=self.window.frame;
    
    //set it to the image frame size
    ContentRect.size=[[self image] size];
    
    return [NSWindow frameRectForContentRect:ContentRect styleMask: [window styleMask]];
};

#pragma mark - Source Operations

- (NSDragOperation)draggingSession:(NSDraggingSession *)session sourceOperationMaskForDraggingContext:(NSDraggingContext)context
{
    /*------------------------------------------------------
     NSDraggingSource protocol method.  Returns the types of operations allowed in a certain context.
     --------------------------------------------------------*/
    switch (context) {
        case NSDraggingContextOutsideApplication:
            return NSDragOperationCopy;
            
            //by using this fall through pattern, we will remain compatible if the contexts get more precise in the future.
        case NSDraggingContextWithinApplication:
        default:
            return NSDragOperationCopy;
            break;
    }
}
@end