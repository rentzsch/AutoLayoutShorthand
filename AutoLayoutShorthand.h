// AutoLayoutShorthand.h semver:0.2
//   Copyright (c) 2013 Jonathan 'Wolf' Rentzsch: http://rentzsch.com
//   Some rights reserved: http://opensource.org/licenses/mit
//   https://github.com/rentzsch/AutoLayoutShorthand

#import "AutoLayoutConstants.h"

#ifdef __IPHONE_OS_VERSION_MIN_REQUIRED
#import "UIView+AutoLayoutShorthand.h"
#elif TARGET_OS_MAC
#import "NSView+AutoLayoutShorthand.h"
#endif
