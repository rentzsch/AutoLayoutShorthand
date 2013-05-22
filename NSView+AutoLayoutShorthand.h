// NSView+AutoLayoutShorthand.h semver:0.2
//   Copyright (c) 2013 Jonathan 'Wolf' Rentzsch: http://rentzsch.com
//   Some rights reserved: http://opensource.org/licenses/mit
//   https://github.com/rentzsch/AutoLayoutShorthand

#import <Cocoa/Cocoa.h>

@interface NSView (AutoLayoutShorthand)

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

- (void)als_addConstraints:(NSDictionary *)constraints;

@end
