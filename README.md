AutoLayoutShorthand
===================

AutoLayoutShorthand (ALS) is an alternative system for creating and adding Auto Layout constraints.

It feels kind of CSS, though without HTML's frustrating layout model.

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

AutoLayoutShorthand Advantages
------------------------------

* More concise than `+[NSLayoutConstraint constraintWithItem:…]` but just as powerful. Actually, just a smidge more powerful since you can specify the constraint's priority at creation time.

* Easier to read+understand than `+[NSLayoutConstraint constraintWithItem:…]`.

* Often more concise than even Visual Format Language, yet more powerful (AutoLayoutShorthand can specify centerX and centerY).

* Refactoring-friendly. Visual Format Language strings are opaque to Xcode's refactoring support. This results in nasty runtime exceptions if you use the rename a variable or property and forget to update any corresponding VFL string.

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

* Built-in Closest-Common-Superview Discovery. When relating attributes across views, AutoLayoutShorthand automatically calculates the views' closest common superview and adds the generated constraints there. This is the Apple-recommended place to put your constraints.

AutoLayoutShorthand Disadvantages
---------------------------------

* Yet Another Dependancy.

* Another thing to learn. You probably have to learn VFL anyway to understand Auto Layout's debugging logs.

* Like Only God Can Create A Tree, Only VFL Can Create NSSpacers. Fortunately ALS plays nicely with VFL, so use VFL if you want to take advantage of spacers.



---

1. Actually `+[NSLayoutConstraint  constraintsWithVisualFormat:…]` will create a constraint with an attribute of `NSLayoutAttributeLeading` where the example above uses `NSLayoutAttributeLeft`. ALS does support `@"leading =="` in addition to `@"left =="`, I just wanted to make the example straightforward to folks who haven't learned about Auto Layout's Right-To-Left text system support yet.

2. Same deal as <sup>1</sup>.

Version History
---------------

### v0.0.1: Apr 22 2013

* Initial release.