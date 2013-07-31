// AutoLayoutShorthand.h semver:0.4
//   Copyright (c) 2013 Jonathan 'Wolf' Rentzsch: http://rentzsch.com
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
// Poor man's namespacing support.
// See http://rentzsch.tumblr.com/post/40806448108/ns-poor-mans-namespacing-for-objective-c

#ifndef NS
    #ifdef NS_NAMESPACE
        #define JRNS_CONCAT_TOKENS(a,b) a##_##b
        #define JRNS_EVALUATE(a,b) JRNS_CONCAT_TOKENS(a,b)
        #define NS(original_name) JRNS_EVALUATE(NS_NAMESPACE, original_name)
    #else
        #define NS(original_name) original_name
    #endif
#endif

//-----------------------------------------------------------------------------------------

@interface ALSView (NS(AutoLayoutShorthand))
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

@interface NSLayoutConstraint (NS(AutoLayoutShorthand))
- (ALSView*)als_hostView;
- (void)als_setHostView:(ALSView*)hostView;

- (BOOL)als_isActive;
- (void)als_setActive:(BOOL)active;
@end

//-----------------------------------------------------------------------------------------

@interface NSArray (NS(AutoLayoutShorthand))
- (void)als_activateConstraints;
- (void)als_deactivateConstraints;
@end