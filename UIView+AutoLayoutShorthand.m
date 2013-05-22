// UIView+AutoLayoutShorthand.m semver:0.2
//   Copyright (c) 2013 Jonathan 'Wolf' Rentzsch: http://rentzsch.com
//   Some rights reserved: http://opensource.org/licenses/mit
//   https://github.com/rentzsch/AutoLayoutShorthand

#import "UIView+AutoLayoutShorthand.h"
#import "AutoLayoutConstants.h"

@interface ALSViewAttr : NSObject
@property(nonatomic, strong)  UIView           *view;
@property(nonatomic, assign)  NSLayoutAttribute attr;

+ (instancetype)viewAttrWithView:(UIView *)view attr:(NSLayoutAttribute)attr;
@end

@implementation ALSViewAttr

+ (instancetype)viewAttrWithView:(UIView *)view attr:(NSLayoutAttribute)attr
{
    ALSViewAttr *result = [[ALSViewAttr alloc] init];

    result.view = view;
    result.attr = attr;
    return result;
}

@end

@implementation UIView (AutoLayoutShorthand)

+ (NSLayoutAttribute)_jr_parseLayoutAttributeName:(NSString *)key
{
    static NSDictionary   *attrValueForName = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        attrValueForName =
        @{
          @"left" : @(NSLayoutAttributeLeft),
          @"right" : @(NSLayoutAttributeRight),
          @"top" : @(NSLayoutAttributeTop),
          @"bottom" : @(NSLayoutAttributeBottom),
          @"leading" : @(NSLayoutAttributeLeading),
          @"trailing" : @(NSLayoutAttributeTrailing),
          @"width" : @(NSLayoutAttributeWidth),
          @"height" : @(NSLayoutAttributeHeight),
          @"centerX" : @(NSLayoutAttributeCenterX),
          @"centerY" : @(NSLayoutAttributeCenterY),
          @"baseline" : @(NSLayoutAttributeBaseline),
          };
    });

    NSString *attrName     = [key componentsSeparatedByString:@" "][0];
    NSNumber *attrValueObj = attrValueForName[attrName];

    if (attrValueObj) {
        return [attrValueObj integerValue];
    } else {
        NSAssert1(NO, @"can't parse layout attribute from key: %@", key);
        return -1;
    }
}

+ (NSLayoutRelation)_jr_parseLayoutRelation:(NSString *)key
{
    static NSDictionary   *relationValueForName = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        relationValueForName =
        @{
          @"==" : @(NSLayoutRelationEqual),
          @">=" : @(NSLayoutRelationGreaterThanOrEqual),
          @"<=" : @(NSLayoutRelationLessThanOrEqual),
          };
    });

    NSString *relationName     = [key componentsSeparatedByString:@" "][1];
    NSNumber *relationValueObj = relationValueForName[relationName];

    if (relationValueObj) {
        return [relationValueObj integerValue];
    } else {
        NSAssert1(NO, @"can't parse layout relation from key: %@", key);
        return -1;
    }
}

- (void)als_addConstraints:(NSDictionary *)constraints
{
    for (NSString *constraintKey in constraints) {
        UIView           *firstItem       = self;
        NSLayoutAttribute firstAttribute  = [UIView _jr_parseLayoutAttributeName:constraintKey];
        NSLayoutRelation  relation        = [UIView _jr_parseLayoutRelation:constraintKey];
        UIView           *secondItem      = nil;
        NSLayoutAttribute secondAttribute = NSLayoutAttributeNotAnAttribute;
        CGFloat           multiplier      = 1.0;
        CGFloat           constant        = 0.0;
        UILayoutPriority  priority        = UILayoutPriorityRequired;

        id constraintValue = constraints[constraintKey];

        if ([constraintValue isKindOfClass:[ALSViewAttr class]]) {
            ALSViewAttr *viewAttribute = constraintValue;
            secondItem      = viewAttribute.view;
            secondAttribute = viewAttribute.attr;
        } else if ([constraintValue isKindOfClass:[NSDictionary class]]) {
            NSDictionary *constraintValueNumberDict = constraintValue;

            if (constraintValueNumberDict[als_view]) {
                if ([constraintValueNumberDict[als_view] isKindOfClass:[NSString class]]) {
                    if ([constraintValueNumberDict[als_view] isEqualToString:als_superview]) {
                        secondItem      = firstItem.superview;
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
                    secondItem      = viewAttribute.view;
                    secondAttribute = viewAttribute.attr;
                }
            }

            if (constraintValueNumberDict[als_multiplier]) {
                multiplier = [constraintValueNumberDict[als_multiplier] doubleValue];
            }

            if (constraintValueNumberDict[als_constant]) {
                constant = [constraintValueNumberDict[als_constant] doubleValue];
            }

            if (constraintValueNumberDict[als_priority]) {
                priority = [constraintValueNumberDict[als_priority] doubleValue];
            }
        } else if ([constraintValue isKindOfClass:[NSNumber class]]) {
            constant = [constraintValue doubleValue];
        } else if ([constraintValue isKindOfClass:[NSString class]]) {
            if ([constraintValue isEqualToString:als_superview]) {
                secondItem      = firstItem.superview;
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

        if (secondItem) {
            UIView *closestCommonSuperview = nil;

            UIView *rhsViewItr = self.superview;

            while (!closestCommonSuperview && rhsViewItr) {
                UIView *lhsViewItr = secondItem;

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
            [closestCommonSuperview addConstraint:constraint];
        } else {
            [self addConstraint:constraint];
        }
    }
}

- (id)als_left
{
    return [ALSViewAttr viewAttrWithView:self attr:NSLayoutAttributeLeft];
}

- (id)als_right
{
    return [ALSViewAttr viewAttrWithView:self attr:NSLayoutAttributeRight];
}

- (id)als_top
{
    return [ALSViewAttr viewAttrWithView:self attr:NSLayoutAttributeTop];
}

- (id)als_bottom
{
    return [ALSViewAttr viewAttrWithView:self attr:NSLayoutAttributeBottom];
}

- (id)als_leading
{
    return [ALSViewAttr viewAttrWithView:self attr:NSLayoutAttributeLeading];
}

- (id)als_trailing
{
    return [ALSViewAttr viewAttrWithView:self attr:NSLayoutAttributeTrailing];
}

- (id)als_width
{
    return [ALSViewAttr viewAttrWithView:self attr:NSLayoutAttributeWidth];
}

- (id)als_height
{
    return [ALSViewAttr viewAttrWithView:self attr:NSLayoutAttributeHeight];
}

- (id)als_centerX
{
    return [ALSViewAttr viewAttrWithView:self attr:NSLayoutAttributeCenterX];
}

- (id)als_centerY
{
    return [ALSViewAttr viewAttrWithView:self attr:NSLayoutAttributeCenterY];
}

- (id)als_baseline
{
    return [ALSViewAttr viewAttrWithView:self attr:NSLayoutAttributeBaseline];
}

@end
