// AutoLayoutShorthand.m semver:0.4
//   Copyright (c) 2013 Jonathan 'Wolf' Rentzsch: http://rentzsch.com
//   Some rights reserved: http://opensource.org/licenses/mit
//   https://github.com/rentzsch/AutoLayoutShorthand

#import "AutoLayoutShorthand.h"
#import <objc/runtime.h>

@interface ALSViewAttr : NSObject
@property(nonatomic, strong)  ALSView            *view;
@property(nonatomic, assign)  NSLayoutAttribute  attr;

+ (instancetype)viewAttrWithView:(ALSView*)view attr:(NSLayoutAttribute)attr;
@end

@implementation ALSView (NS(AutoLayoutShorthand))

+ (NSLayoutAttribute)_jr_parseLayoutAttributeName:(NSString*)key {
    static NSDictionary *attrValueForName = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        attrValueForName =
        @{
          @"left":      @(NSLayoutAttributeLeft),
          @"right":     @(NSLayoutAttributeRight),
          @"top":       @(NSLayoutAttributeTop),
          @"bottom":    @(NSLayoutAttributeBottom),
          @"leading":   @(NSLayoutAttributeLeading),
          @"trailing":  @(NSLayoutAttributeTrailing),
          @"width":     @(NSLayoutAttributeWidth),
          @"height":    @(NSLayoutAttributeHeight),
          @"centerX":   @(NSLayoutAttributeCenterX),
          @"centerY":   @(NSLayoutAttributeCenterY),
          @"baseline":  @(NSLayoutAttributeBaseline),
          };
    });
    
    NSString *attrName = [key componentsSeparatedByString:@" "][0];
    NSNumber *attrValueObj = attrValueForName[attrName];
    if (attrValueObj) {
        return [attrValueObj integerValue];
    } else {
        NSAssert1(NO, @"can't parse layout attribute from key: %@", key);
        return -1;
    }
}

+ (NSLayoutRelation)_jr_parseLayoutRelation:(NSString*)key {
    static NSDictionary *relationValueForName = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        relationValueForName =
        @{
          @"==":  @(NSLayoutRelationEqual),
          @">=":  @(NSLayoutRelationGreaterThanOrEqual),
          @"<=":  @(NSLayoutRelationLessThanOrEqual),
          };
    });
    
    NSString *relationName = [key componentsSeparatedByString:@" "][1];
    NSNumber *relationValueObj = relationValueForName[relationName];
    if (relationValueObj) {
        return [relationValueObj integerValue];
    } else {
        NSAssert1(NO, @"can't parse layout relation from key: %@", key);
        return -1;
    }
}

- (NSArray*)als_addConstraints:(NSDictionary*)constraints {
    NSMutableArray *result = [NSMutableArray array];
    for (NSString *constraintKey in constraints) {
        ALSView *firstItem = self;
        NSLayoutAttribute firstAttribute = [ALSView _jr_parseLayoutAttributeName:constraintKey];
        NSLayoutRelation relation = [ALSView _jr_parseLayoutRelation:constraintKey];
        ALSView *secondItem = nil;
        NSLayoutAttribute secondAttribute = NSLayoutAttributeNotAnAttribute;
        CGFloat multiplier = 1.0;
        CGFloat constant = 0.0;
        ALSLayoutPriority priority = ALSLayoutPriorityRequired;
        
        id constraintValue = constraints[constraintKey];
        if ([constraintValue isKindOfClass:[ALSViewAttr class]]) {
            ALSViewAttr *viewAttribute = constraintValue;
            secondItem = viewAttribute.view;
            secondAttribute = viewAttribute.attr;
        } else if ([constraintValue isKindOfClass:[NSDictionary class]]) {
            NSDictionary *constraintValueNumberDict = constraintValue;
            if (constraintValueNumberDict[als_view]) {
                if ([constraintValueNumberDict[als_view] isKindOfClass:[NSString class]]) {
                    if ([constraintValueNumberDict[als_view] isEqualToString:als_superview]) {
                        secondItem = firstItem.superview;
                        secondAttribute = firstAttribute;
                    } else {
                        NSAssert3(NO,
                                  @"unsupported string value \"%@\" for key %@.%@",
                                  constraintValue,
                                  constraintKey,
                                  als_view
                                  );
                    }
                } else {
                    ALSViewAttr *viewAttribute = constraintValueNumberDict[als_view];
                    secondItem = viewAttribute.view;
                    secondAttribute = viewAttribute.attr;
                }
            }
            if (constraintValueNumberDict[als_multiplier]) {
                multiplier = (CGFLOAT_TYPE)[constraintValueNumberDict[als_multiplier] doubleValue];
            }
            if (constraintValueNumberDict[als_constant]) {
                constant = (CGFLOAT_TYPE)[constraintValueNumberDict[als_constant] doubleValue];
            }
            if (constraintValueNumberDict[als_priority]) {
                priority = MIN([constraintValueNumberDict[als_priority] floatValue], ALSLayoutPriorityRequired);
            }
        } else if ([constraintValue isKindOfClass:[NSNumber class]]) {
            constant = (CGFLOAT_TYPE)[constraintValue doubleValue];
        } else if ([constraintValue isKindOfClass:[NSString class]]) {
            if ([constraintValue isEqualToString:als_superview]) {
                secondItem = firstItem.superview;
                secondAttribute = firstAttribute;
            } else {
                NSAssert2(NO,
                          @"unsupported string value \"%@\" for key %@",
                          constraintValue,
                          constraintKey
                          );
            }
        } else {
            NSAssert3(NO,
                      @"unsupported value class for key %@ (value: %@)",
                      [constraintValue class],
                      constraintKey,
                      constraintValue
                      );
        }
        
        NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:firstItem
                                                                      attribute:firstAttribute
                                                                      relatedBy:relation
                                                                         toItem:secondItem
                                                                      attribute:secondAttribute
                                                                     multiplier:multiplier
                                                                       constant:constant];
        constraint.priority = priority;
        
        [result addObject:constraint];
        
        if (secondItem) {
            ALSView *closestCommonSuperview = nil;
            
            ALSView *rhsViewItr = self;
            while (!closestCommonSuperview && rhsViewItr) {
                ALSView *lhsViewItr = secondItem;
                while (!closestCommonSuperview && lhsViewItr) {
                    if (rhsViewItr == lhsViewItr) {
                        closestCommonSuperview = rhsViewItr;
                    }
                    lhsViewItr = lhsViewItr.superview;
                }
                rhsViewItr = rhsViewItr.superview;
            }
            
            NSAssert2(closestCommonSuperview,
                      @"couldn't find a common superview for %@ and %@",
                      firstItem,
                      secondItem);
            [constraint als_setHostView:closestCommonSuperview];
        } else {
            [constraint als_setHostView:self];
        }
    }
    return result;
}

- (id)als_left      { return [ALSViewAttr viewAttrWithView:self attr:NSLayoutAttributeLeft];      }
- (id)als_right     { return [ALSViewAttr viewAttrWithView:self attr:NSLayoutAttributeRight];     }
- (id)als_top       { return [ALSViewAttr viewAttrWithView:self attr:NSLayoutAttributeTop];       }
- (id)als_bottom    { return [ALSViewAttr viewAttrWithView:self attr:NSLayoutAttributeBottom];    }
- (id)als_leading   { return [ALSViewAttr viewAttrWithView:self attr:NSLayoutAttributeLeading];   }
- (id)als_trailing  { return [ALSViewAttr viewAttrWithView:self attr:NSLayoutAttributeTrailing];  }
- (id)als_width     { return [ALSViewAttr viewAttrWithView:self attr:NSLayoutAttributeWidth];     }
- (id)als_height    { return [ALSViewAttr viewAttrWithView:self attr:NSLayoutAttributeHeight];    }
- (id)als_centerX   { return [ALSViewAttr viewAttrWithView:self attr:NSLayoutAttributeCenterX];   }
- (id)als_centerY   { return [ALSViewAttr viewAttrWithView:self attr:NSLayoutAttributeCenterY];   }
- (id)als_baseline  { return [ALSViewAttr viewAttrWithView:self attr:NSLayoutAttributeBaseline];  }

@end

//-----------------------------------------------------------------------------------------

@implementation NSLayoutConstraint (NS(AutoLayoutShorthand))

- (ALSView*)als_hostView {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)als_setHostView:(ALSView*)hostView {
    if (hostView == self.als_hostView) return;
    
    if ([self.als_hostView.constraints containsObject:self]) {
        [self.als_hostView removeConstraint:self];
    }
    
    objc_setAssociatedObject(self,
                             @selector(als_hostView),
                             hostView,
                             OBJC_ASSOCIATION_ASSIGN); // too bad we don't have weak
    
    [self.als_hostView addConstraint:self];
}

- (BOOL)als_isActive {
    NSParameterAssert(self.als_hostView);
    return [self.als_hostView.constraints containsObject:self];
}

- (void)als_setActive:(BOOL)active {
    NSParameterAssert(self.als_hostView);
    if (active) {
        if (![self.als_hostView.constraints containsObject:self]) {
            [self.als_hostView addConstraint:self];
        }
    } else {
        if ([self.als_hostView.constraints containsObject:self]) {
            [self.als_hostView removeConstraint:self];
        }
    }
}

@end

//-----------------------------------------------------------------------------------------

@implementation NSArray (NS(AutoLayoutShorthand))

- (void)als_activateConstraints {
    for (NSLayoutConstraint *constraint in self) {
        [constraint als_setActive:YES];
    }
}

- (void)als_deactivateConstraints {
    for (NSLayoutConstraint *constraint in self) {
        [constraint als_setActive:NO];
    }
}

@end

//-----------------------------------------------------------------------------------------

@implementation ALSViewAttr

+ (instancetype)viewAttrWithView:(ALSView*)view attr:(NSLayoutAttribute)attr {
    ALSViewAttr *result = [[ALSViewAttr alloc] init];
    result.view = view;
    result.attr = attr;
    return result;
}

@end

NSString * const als_view        = @"als_view";
NSString * const als_superview   = @"als_superview";
NSString * const als_constant    = @"als_constant";
NSString * const als_multiplier  = @"als_multiplier";
NSString * const als_priority    = @"als_priority";