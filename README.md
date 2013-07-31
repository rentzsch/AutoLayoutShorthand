Auto Layout Shorthand
=====================

Auto Layout Shorthand (ALS) is an alternative system for creating and adding Auto Layout constraints.

It feels kind of like CSS, though more powerful and without HTML's frustrating default layout model.

Here's a simple example to introduce ALS:

	[iconView als_addConstraints:@{
	 @"left ==": als_superview,
	 @"width ==": @(kIconWidth),
	 @"top ==": als_superview,
	 @"height ==": @(kIconHeight),
	 }];

Here's mostly<sup>1</sup> the same example using the Visual Format Language (VFL):

	[iconView addConstraints:@[
	 [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[iconView(kIconWidth)]"
	                                         options:0
	                                         metrics:NSDictionaryOfVariableBindings(kIconWidth)
	                                           views:NSDictionaryOfVariableBindings(iconView)],
	 [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[iconView(kIconHeight)]"
	                                         options:0
	                                         metrics:NSDictionaryOfVariableBindings(kIconHeight)
	                                           views:NSDictionaryOfVariableBindings(iconView)],
	 ]];

And mostly<sup>2</sup> the same example using `+[NSLayoutConstraint constraintWithItem:…]`:

	[iconView addConstraints:@[
	 [NSLayoutConstraint constraintWithItem:iconView
								  attribute:NSLayoutAttributeLeft
								  relatedBy:NSLayoutRelationEqual
									 toItem:iconView.superview
								  attribute:NSLayoutAttributeLeft
								 multiplier:1.0
								   constant:0.0],
	 [NSLayoutConstraint constraintWithItem:iconView
								  attribute:NSLayoutAttributeWidth
								  relatedBy:NSLayoutRelationEqual
									 toItem:nil
								  attribute:NSLayoutAttributeNotAnAttribute
								 multiplier:1.0
								   constant:kIconWidth],
	 [NSLayoutConstraint constraintWithItem:iconView
								  attribute:NSLayoutAttributeTop
								  relatedBy:NSLayoutRelationEqual
									 toItem:iconView.superview
								  attribute:NSLayoutAttributeTop
								 multiplier:1.0
								   constant:0.0],
	 [NSLayoutConstraint constraintWithItem:iconView
								  attribute:NSLayoutAttributeHeight
								  relatedBy:NSLayoutRelationEqual
									 toItem:nil
								  attribute:NSLayoutAttributeNotAnAttribute
								 multiplier:1.0
								   constant:kIconHeight],
	 ]];

Auto Layout Shorthand Reference
-------------------------------

Auto Layout Shorthand is a poor man's DSL wedged into a normal Objective-C dictionary literal.

Each key-value pair contains enough information to create one NSLayoutConstraint. This stands in contrast to VFL, where one string can be used to generate multiple constraints.

The dictionary key encodes two pieces of information: the the NSLayoutConstraint's `firstAttribute` and its `relation`. Here's some examples:

* `@"width >="`
* `@"height <="`
* `@"centerX =="`

For the first part of the key, the attribute, every `NSLayoutAttribute` is supported except `NSLayoutAttributeNotAnAttribute`. See the *ALS Dictionary Key Name* column below (we'll get to *ALS Dictionary Value Name* in a moment):

NSLayoutAttribute constant  |  ALS Dictionary Key Name  |  ALS Dictionary Value Name
--------------------------  |  -----------------------  |  -------------------------
NSLayoutAttributeLeft       |  left                     |  als_left
NSLayoutAttributeRight      |  right                    |  als_right
NSLayoutAttributeTop        |  top                      |  als_top
NSLayoutAttributeBottom     |  bottom                   |  als_bottom
NSLayoutAttributeLeading    |  leading                  |  als_leading
NSLayoutAttributeTrailing   |  trailing                 |  als_trailing
NSLayoutAttributeWidth      |  width                    |  als_width
NSLayoutAttributeHeight     |  height                   |  als_height
NSLayoutAttributeCenterX    |  centerX                  |  als_centerX
NSLayoutAttributeCenterY    |  centerY                  |  als_centerY
NSLayoutAttributeBaseline   |  baseline                 |  als_baseline

The second part of the dictionary key encodes the `NSLayoutRelation` in the obvious manner:

NSLayoutRelation constant           |  Auto Layout Shorthand equivalent
----------------------------------  |  --------------------------------
NSLayoutRelationLessThanOrEqual     |  <=
NSLayoutRelationEqual               |  ==
NSLayoutRelationGreaterThanOrEqual  |  >=

The dictionary value encodes either a relation or a constant. Simple relations and simple constants are directly assigned:

* `@"top ==": headerView.als_bottom`
* `@"width ==": @(42)`

Let's talk about `headerView.als_bottom` some more. `als_bottom` is a method added as a category to `UIView`. Auto Layout Shorthand adds a suite of methods, one for each `NSLayoutAttribute`. That's the *ALS Dictionary Value Name* column above.

These categories enable you to refer to both a view and an attribute in one expression. The result is a simple class that just packages up both of them into one object that's later consumed by `-[UIView(AutoLayoutShorthand) als_addConstraints:]`.

You can use a dictionary to specify more complex constraints:

* `@"top ==": @{als_view:headerView.al_bottom, als_constant:@(10)},`
* `@"width ==": @{als_constant:@(42), als_priority:@(UILayoutPriorityDefaultHigh)]`

Supported keys are:

Auto Layout Shorthand Key  |  Corresponding NSLayoutConstraint property
-------------------------  |  -----------------------------------------
als_view                   |  secondItem
als_multiplier             |  multiplier
als_constant               |  constant
als_priority               |  priority

Finally, VFL has `@"|"`, which represents the superview. `als_superview` is ALS's version of the same thing.

Auto Layout Shorthand Advantages
--------------------------------

* More concise than `+[NSLayoutConstraint constraintWithItem:…]` but just as powerful. Actually, just a smidge more powerful since you can specify the constraint's priority at creation time.

* Easier to read+understand than `+[NSLayoutConstraint constraintWithItem:…]`.

* Often more concise than even Visual Format Language, yet more powerful (Auto Layout Shorthand can specify centerX and centerY).

* Refactoring-friendly. Visual Format Language strings are opaque to Xcode's refactoring support. This results in nasty runtime exceptions if you use refactoring to rename a variable or property and forget to update any corresponding VFL string.

* View Property-friendly. This code doesn't work:

		[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[self.iconView(32)]"
		                                        options:0
		                                        metrics:nil
		                                          views:NSDictionaryOfVariableBindings(self.iconView)];

	apparently because of the `self.`. One work-around is to access the ivar directly:

		[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_iconView(32)]"
		                                        options:0
		                                        metrics:nil
		                                          views:NSDictionaryOfVariableBindings(_iconView)];

	which I don't much care for since it bypasses the accessor. I recommend creating the dictionary yourself:

		[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[iconView(32)]"
	    	                                    options:0
		                                        metrics:nil
		                                          views:@{@"iconView": self.iconView}];

	or using ALS.

* Built-in Closest-Common-Superview Discovery. When relating attributes across views, Auto Layout Shorthand automatically calculates the views' closest common superview and adds the generated constraints there. This is the Apple-recommended place to put your constraints.

Auto Layout Shorthand Disadvantages
-----------------------------------

* Another Dependancy. Not that bad though, since it's a self-contained .h/.m pair.

* Another thing to learn. You probably have to learn VFL anyway to understand Auto Layout's debugging logs.

* Like Only God Can Create A Tree, Only VFL Can Create NSSpacers. Fortunately ALS plays nicely with VFL, so use VFL if you want to take advantage of spacers.

TODO
----

* Either upgrade `als_superview` to a UIView or remove it altogether. Probably the former -- it's not strictly needed (you can always just `myview.superview`, but the conceptual clarity is worth a more-complicated implementation AFAICS.

* Write an example app to showcase common scenarios.

* NS()-ify method names :(

Version History
---------------

### v0.4: Jun 24 2013

* [NEW] Improved handling for groups of constraints (the common case):

	* als_addConstraints: now returns an array of the constraints its created.

	* als_activateConstraints and als_deactivateConstraints category methods on NSArray allow enabling and disabling groups of NSLayoutConstraints.

		Coupled with als_addConstraints: above, this allows you to create groups of constraints, easily switching them on or off based on user interaction and/or application state.

	* als_hostView and als_setHostView: category methods on NSLayoutConstraint handle the to-one nature (`(UI|NS)View <->> NSLayoutConstraint`) of views and their constraints and to keep track of which host view a constraint has been assigned to so it can be activated (added) and deactivated (removed) easily at runtime.

	* als_isActive and als_setActive: category methods on NSLayoutConstraint to provide individual constraint activation control. Used by als_activateConstraints & als_deactivateConstraints.

This replaces the idea that I'd add a way to get/set constraints by their ALS keys previously mentioned in the TODO section. Also the idea to allow overwriting of previously-set constraints.

### v0.3: Jun 18 2013

* [DEV] Re-unify UIView and NSView implementations.

### v0.2: May 22 2013

* [NEW] Add NSView support. ([Tony Arnold](https://github.com/rentzsch/AutoLayoutShorthand/pull/2))

### v0.1.1: Apr 24 2013

* [FIX] Make Closest-Common-Superview a little more forgiving.

### v0.1: Apr 22 2013

* Initial version.

	As its [Semantic Version](http://semver.org/) suggests, its interface may still change in client-breaking ways.



---

1. Actually `+[NSLayoutConstraint  constraintsWithVisualFormat:…]` will create a constraint with an attribute of `NSLayoutAttributeLeading` where the example above uses `NSLayoutAttributeLeft`. ALS does support `@"leading =="` in addition to `@"left =="`, I just wanted to make the example straightforward to folks who haven't learned about Auto Layout's Right-To-Left text system support yet.

2. Same deal as <sup>1</sup>.
