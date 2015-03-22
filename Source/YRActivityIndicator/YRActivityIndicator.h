//
// YRActivityIndicator.m
//
// The MIT License (MIT)
//
// Copyright (c) 2015 Yuri R.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

@import UIKit;

/**
 *  Customizable activity indicator.
 *  Animation consist of items that rotate around imaginary circle in fixed time interval.
 *  Items size are interpolated linearly between maxItemSize and minItemSize.
 *  Each item has it’s own rotation speed value, that tells how fast it will make full rotation cycle from 0..2PI.
 *  This value is specified by setting maxSpeed property and it’s interpolated linearly between items.
 *  First item get’s max speed, last item gets regular speed (1.0).
 *  Rotation angle is interpolated by using cubic Bezier curve.
 */
@interface YRActivityIndicator : UIView

/**
 *  Total number of items that will take part in activity animation.
 *  Default to 6.
 */
@property (nonatomic) int32_t maxItems;

/**
 *  Radius of invisible circle around which items are moved.
 */
@property (nonatomic) int32_t radius;

/**
 *  Total duration of full cycle from 0..2PI that items make turning around the circle.
 */
@property (nonatomic) NSTimeInterval cycleDuration;

/**
 *  Defines min size for item.
 */
@property (nonatomic) CGSize minItemSize;

/**
 *  Defines max size for item. First item will always have max size.
 *  Other item sizes are interpolated between max..min size.
 */
@property (nonatomic) CGSize maxItemSize;

/**
 *  Defines max speed coefficient that item may have.
 *  First item will get max speed (if there are more than one item).
 *  Other items speed will be interpolated between maxSpeed and 1.0.
 *  Last item will always have speed of 1.0.
 *  Default to 1.6.
 */
@property (nonatomic) CGFloat maxSpeed;

/**
 *  First control point of cubic bezier curve.
 */
@property (nonatomic) CGPoint firstBezierControlPoint;

/**
 *  Second control point of cubic bezier curve.
 */
@property (nonatomic) CGPoint secondBezierControlPoint;

/**
 *  Property acts like in UIActivityIndicatorView.
 *  When indicator isn't animating - it will be hidden if property set to YES.
 *  Default to NO.
 */
@property (nonatomic) BOOL hidesWhenStopped;

/**
 *  Custom image for item. Preffered size for it is maxItemSize.
 *  If you don't want to provide image - set itemColor property.
 *  Default to nil.
 */
@property (nonatomic) UIImage *itemImage;

/**
 *  Item color in case if item image isn't provided.
 *  itemImage gets priority if both of properties are set.
 *  Default to white.
 */
@property (nonatomic) UIColor *itemColor;

/**
 *  Tells if activity indicator currently animating.
 */
@property (nonatomic, readonly) BOOL isAnimating;

/**
 *  Begins fancy activity indicator animation using cubic Bezier curve as interpolation function.
 */
- (void)startAnimating;

/**
 *  Stops current activity indicator animation.
 */
- (void)stopAnimating;

@end
