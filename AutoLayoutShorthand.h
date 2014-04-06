// AutoLayoutShorthand.h semver:1.0
//   Copyright (c) 2013-2014 Jonathan 'Wolf' Rentzsch: http://rentzsch.com
//   Some rights reserved: http://opensource.org/licenses/mit
//   https://github.com/rentzsch/AutoLayoutShorthand

#ifdef __IPHONE_OS_VERSION_MIN_REQUIRED
    #import <UIKit/UIKit.h>
    #define ALSView                    UIView
    #define ALSLayoutPriority          UILayoutPriority
    #define ALSLayoutPriorityRequired  UILayoutPriorityRequired
#elif TARGET_OS_MAC
    #import <Cocoa/Cocoa.h>
    #define ALSView                    NSView
    #define ALSLayoutPriority          NSLayoutPriority
    #define ALSLayoutPriorityRequired  NSLayoutPriorityRequired
#endif

//-----------------------------------------------------------------------------------------

@interface ALSView (AutoLayoutShorthand)
- (id)als_left;
- (id)als_right;
- (id)als_top;
- (id)als_bottom;
- (id)als_leading;
- (id)als_trailing;
- (id)als_width;
- (id)als_height;
- (id)als_centerX;
- (id)als_centerY;
- (id)als_baseline;

- (NSArray*)als_addConstraints:(NSDictionary*)constraints;
@end

extern NSString * const als_view;
extern NSString * const als_superview;
extern NSString * const als_multiplier;
extern NSString * const als_constant;
extern NSString * const als_priority;

//-----------------------------------------------------------------------------------------

@interface NSLayoutConstraint (AutoLayoutShorthand)
- (ALSView*)als_hostView;
- (void)als_setHostView:(ALSView*)hostView;

- (BOOL)als_isActive;
- (void)als_setActive:(BOOL)active;
@end

//-----------------------------------------------------------------------------------------

@interface NSArray (AutoLayoutShorthand)
- (void)als_activateConstraints;
- (void)als_deactivateConstraints;
@end