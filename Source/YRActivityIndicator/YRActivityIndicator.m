//
// YRActivityIndicator.h
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

#import "YRActivityIndicator.h"

static CGSize const kDefaultMinItemSize = (CGSize){5, 5};
static CGSize const kDefaultMaxItemSize = (CGSize){20, 20};
static int32_t const kDefaultMaxItems = 6;
static CGFloat const kDefaultMaxSpeed = 1.6;
static NSTimeInterval const kDefaultCycleDuration = 2;
static CGFloat const kDefaultRadius = 30;
static CGPoint const kDefaultFirstBezierControlPoint = (CGPoint){0.89, 0};
static CGPoint const kDefaultSecondBezierControlPoint = (CGPoint){0.12, 1};

#if TARGET_INTERFACE_BUILDER

IB_DESIGNABLE
@interface YRActivityIndicator (IBDesign)
@property (nonatomic) IBInspectable int32_t maxItems;
@property (nonatomic) IBInspectable int32_t radius;
@property (nonatomic) IBInspectable CGFloat cycleDuration;
@property (nonatomic) IBInspectable CGSize minItemSize;
@property (nonatomic) IBInspectable CGSize maxItemSize;
@property (nonatomic) IBInspectable CGFloat maxSpeed;
@property (nonatomic) IBInspectable CGPoint firstBezierControlPoint;
@property (nonatomic) IBInspectable CGPoint secondBezierControlPoint;
@property (nonatomic) IBInspectable BOOL hidesWhenStopped;
@property (nonatomic) IBInspectable UIImage *itemImage;
@property (nonatomic) IBInspectable UIColor *itemColor;
@end

#endif

@implementation YRActivityIndicator {
    NSArray *_animatingItems;
    
    NSTimeInterval _currentCycleTime;
    
    CADisplayLink *_displayLink;
    
    BOOL _isAnimating;
}

#pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit {
    _minItemSize = kDefaultMinItemSize;
    _maxItemSize = kDefaultMaxItemSize;
    _maxItems = kDefaultMaxItems;
    
    _maxSpeed = kDefaultMaxSpeed;
    
    _cycleDuration = kDefaultCycleDuration;
    
    _radius = kDefaultRadius;
    
    _itemColor = [UIColor whiteColor];

    _firstBezierControlPoint = kDefaultFirstBezierControlPoint;
    _secondBezierControlPoint = kDefaultSecondBezierControlPoint;
}

#if TARGET_INTERFACE_BUILDER

#pragma mark - InterfaceBuilder

- (void)drawRect:(CGRect)rect {
    // Draw for IB.
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // Transite to another coordinate system.
    CGContextTranslateCTM(ctx, 0, CGRectGetHeight(rect));
    CGContextScaleCTM(ctx, 1, -1);

    // Draw each item.
    for (int i = 0; i < self.maxItems; i++) {
        // Interpolate speed to solve cubic Bezier.
        CGFloat minSpeed = 1.0;
        
        CGFloat interpolatedSpeed = minSpeed;
        
        // If we have more than one item -> interpolate between 1..self.maxSpeed
        if (self.maxItems > 1) {
            // First item gets max speed and then this speed decreases to 1 for last item.
            interpolatedSpeed = (self.maxSpeed - (self.maxSpeed - minSpeed) * i / (self.maxItems - 1));
        }
        
        CGFloat cycleDurationForItem = self.cycleDuration / interpolatedSpeed;
        
        // We shouldn't exceed normalized value.
        CGFloat currentTime = MIN((self.cycleDuration / 2) / cycleDurationForItem,
                                  1);
        
        // Solve cubic Bezier to get angle value.
        CGFloat currentAngle = [self solveCubicBezierForAngleWithTime:currentTime
                                                    firstControlPoint:self.firstBezierControlPoint
                                                   secondControlPoint:self.secondBezierControlPoint];
        
        CGSize itemSize = self.maxItemSize;
        
        // Get size for current item.
        if (self.maxItems > 1) {
            itemSize = (CGSize){
                self.maxItemSize.width - (self.maxItemSize.width - self.minItemSize.width) * i / (self.maxItems - 1),
                self.maxItemSize.height - (self.maxItemSize.height - self.minItemSize.height) * i / (self.maxItems - 1)
            };
        }

        CGPoint center = (CGPoint){
            (CGRectGetWidth(rect) / 2) + self.radius * sin(currentAngle),
            (CGRectGetHeight(rect) / 2) + self.radius * cos(currentAngle)
        };
        
        // Calculate final rect for item.
        CGRect itemRect = (CGRect){
            center.x - itemSize.width / 2,
            center.y - itemSize.height / 2,
            itemSize
        };
        
        // Grab image to draw.
        UIImage *imageToDraw = self.itemImage;
        if (!imageToDraw) {
            imageToDraw = [self itemImageWithColor:self.itemColor
                                          itemSize:itemSize];
        }

        // Draw final image and start from beggining.
        CGContextDrawImage(ctx, itemRect, imageToDraw.CGImage);
    }
}

#endif

#pragma mark - Overridden

- (void)willMoveToSuperview:(UIView *)newSuperview {
    // When we move to another superview -> invalidate current activity.
    // Normally its called two times:
    // 1. When instantiating a view from code/xib/storyboard.
    // 2. When superview deallocates - we get notified about that via this call with nil param.
    [self invalidate];
}

#pragma mark - Dynamic Properties

- (void)setMaxItems:(int32_t)maxItems {
    _maxItems = maxItems;
    
    // We should recreate everything and interpolate for current time.
    [self createItemsForAnimation];
    [self interpolateForTime:_currentCycleTime];
}

- (void)setRadius:(int32_t)radius {
    _radius = radius;
    
    [self interpolateForTime:_currentCycleTime];
}

- (void)setCycleDuration:(NSTimeInterval)cycleDuration {
    // Calculate current cycle progress in percents.
    CGFloat percentsDone = _currentCycleTime / _cycleDuration;
    
    // Apply new cycle duration.
    _cycleDuration = cycleDuration;
    
    // Calculate new current cycle time depending on cycle progress
    _currentCycleTime = percentsDone * _cycleDuration;
}

- (void)setMinItemSize:(CGSize)minItemSize {
    _minItemSize = minItemSize;
    
    // We should recreate everything and intepolate for current time.
    [self createItemsForAnimation];
    [self interpolateForTime:_currentCycleTime];
}

- (void)setMaxItemSize:(CGSize)maxItemSize {
    _maxItemSize = maxItemSize;
    
    // We should recreate everything and interpolate for current time.
    [self createItemsForAnimation];
    [self interpolateForTime:_currentCycleTime];
}

- (void)setMaxSpeed:(CGFloat)maxSpeed {
    _maxSpeed = maxSpeed;
    
    // Only interpolate.
    [self interpolateForTime:_currentCycleTime];
}

- (void)setFirstBezierControlPoint:(CGPoint)firstBezierControlPoint {
    _firstBezierControlPoint = firstBezierControlPoint;
    
    // Only interpolate.
    [self interpolateForTime:_currentCycleTime];
}

- (void)setSecondBezierControlPoint:(CGPoint)secondBezierControlPoint {
    _secondBezierControlPoint = secondBezierControlPoint;

    // Only interpolate.
    [self interpolateForTime:_currentCycleTime];
}

- (void)setItemImage:(UIImage *)itemImage {
    _itemImage = itemImage;
    
    // Recreate items and interpolate.
    [self createItemsForAnimation];
    [self interpolateForTime:_currentCycleTime];
}

- (void)setItemColor:(UIColor *)itemColor {
    _itemColor = itemColor;
    
    // We should recreate everything and restart animating if needed.
    [self createItemsForAnimation];
    [self interpolateForTime:_currentCycleTime];
}

- (void)setHidesWhenStopped:(BOOL)hidesWhenStopped {
    _hidesWhenStopped = hidesWhenStopped;
    
    if (!_isAnimating) {
        self.hidden = _hidesWhenStopped;
    }
}

#pragma mark - CADisplayLink

- (void)handleTick:(CADisplayLink *)link {
    // Pass current time for interpolation.
    [self interpolateForTime:_currentCycleTime];
    
    // Increase current time.
    _currentCycleTime += link.duration;
    
    if (_currentCycleTime >= self.cycleDuration) {
        // Start looping from the beggining.
        _currentCycleTime = _currentCycleTime - ((int32_t)(_currentCycleTime / self.cycleDuration)) * self.cycleDuration;
    }
}

#pragma mark - Public

- (void)startAnimating {
    if (self.superview) {
        // Animate only if we have superview.
        if (!_isAnimating && self.maxItems > 0) {
            // Also animate only if we're not already animating && we got at least 1 item.
            // Become visible in case we're hidden.
            self.hidden = NO;
            
            // Create items if we didn't do that already.
            if (_animatingItems.count == 0) {
                [self createItemsForAnimation];
                
                // Interpolate all items for current time.
                [self interpolateForTime:_currentCycleTime];
            }
            // Start animating.
            [self scheduleDisplayLink];
        }
    }
}

- (void)stopAnimating {
    [self invalidateDisplayLink];

    self.hidden = self.hidesWhenStopped;
}

#pragma mark - Private

- (void)interpolateForTime:(CGFloat)time {
//    NSLog(@"Time: %.10f. Duration: %.2f. Passed: %.2f(%%)", time, self.cycleDuration, (time / self.cycleDuration) * 100);
    
    // Interpolate each object around circle.
    for (int i = 0; i < _animatingItems.count; i++) {
        // 1. First of all interpolate a speed to get individual current cycle time for item.
        // 2. After that build coefficients from cubic equation and solve it for 't'.
        // 3. By solving it we get 't' (it's not time!) param, that is defined by Bezier function:
        // (1 - t) ^ 3 * {0, 0} + 3 * (1 - t) ^ 2 * t * firstControlPoint + 3 (1 - t) * t^2 * secondControlPoint + t^3 * {1, 1}
        // 4. Now solve for angle, using cubic Bezier by inserting t param in equation.
        // 5. Simply set center for item depending on interpolated angle.
        UIView *item = _animatingItems[i];
        
        CGFloat minSpeed = 1.0;
        
        CGFloat interpolatedSpeed = minSpeed;
        
        // If we have more than one item -> interpolate between 1..self.maxSpeed
        if (_animatingItems.count > 1) {
            // First item gets max speed and then this speed decreases to 1 for last item.
            interpolatedSpeed = (self.maxSpeed - (self.maxSpeed - minSpeed) * i / (_animatingItems.count - 1));
        }
        
        CGFloat cycleDurationForItem = self.cycleDuration / interpolatedSpeed;
        
        // We shouldn't exceed normalized value.
        CGFloat currentTime = MIN(time / cycleDurationForItem,
                                  1);
        
        CGFloat currentAngle = [self solveCubicBezierForAngleWithTime:currentTime
                                                    firstControlPoint:self.firstBezierControlPoint
                                                   secondControlPoint:self.secondBezierControlPoint];
        
        item.center = (CGPoint){
            (CGRectGetWidth(self.bounds) / 2) + self.radius * sin(currentAngle),
            (CGRectGetHeight(self.bounds) / 2) - self.radius * cos(currentAngle)
        };
    }
}

#pragma mark - Item Creation

- (void)createItemsForAnimation {
    // Remove previous items.
    [_animatingItems makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSMutableArray *animatingItems = [NSMutableArray new];
    
    for (int i = 0; i < self.maxItems; i++) {
        CGSize itemSize = self.maxItemSize;
        
        if (self.maxItems > 1) {
            itemSize = (CGSize){
                self.maxItemSize.width - (self.maxItemSize.width - self.minItemSize.width) * i / (self.maxItems - 1),
                self.maxItemSize.height - (self.maxItemSize.height - self.minItemSize.height) * i / (self.maxItems - 1)
            };
        }
        
        UIView *itemView = [self createItemViewWithSize:itemSize];
        
        [self addSubview:itemView];
        [animatingItems addObject:itemView];
    }
    
    _animatingItems = [NSArray arrayWithArray:animatingItems];
}

- (UIView *)createItemViewWithSize:(CGSize)itemSize {
    UIImage *itemImage = self.itemImage;
    
    if (!itemImage) {
        NSAssert(self.itemColor != nil,
                 @"[YRActivityIndicator]: Couldn't create items for animation! Item color and image not specified!");
     
        itemImage = [self itemImageWithColor:self.itemColor
                                    itemSize:itemSize];
    }

    UIImageView *resultingView = [[UIImageView alloc] initWithImage:itemImage];
    
    resultingView.frame = (CGRect){
        CGPointZero,
        itemSize
    };
    
    return resultingView;
}

- (UIImage *)itemImageWithColor:(UIColor *)color
                       itemSize:(CGSize)itemSize {
    UIImage *resultingImage = nil;
    
    UIGraphicsBeginImageContextWithOptions(itemSize, NO, 0);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextAddEllipseInRect(ctx, (CGRect){CGPointZero, itemSize});
    CGContextSetFillColorWithColor(ctx, color.CGColor);
    CGContextFillPath(ctx);
    
    resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return resultingImage;
}

#pragma mark - Display Link Management

- (void)scheduleDisplayLink {
    if (_displayLink) {
        NSLog(@"[YRActivityIndicator]: Contact developer and specify how did control flow get here.");
        // Invalidate if current link is present.
        [self invalidateDisplayLink];
    }
    
    _displayLink = [CADisplayLink displayLinkWithTarget:self
                                               selector:@selector(handleTick:)];
    [_displayLink addToRunLoop:[NSRunLoop currentRunLoop]
                       forMode:NSDefaultRunLoopMode];
	[_displayLink addToRunLoop:[NSRunLoop currentRunLoop]
					   forMode:UITrackingRunLoopMode];
    
    _isAnimating = YES;
}

- (void)invalidateDisplayLink {
    if (_displayLink) {
        [_displayLink invalidate];
        _displayLink = nil;
    }
    
    _isAnimating = NO;
}

#pragma mark - Cleanup

- (void)invalidate {
    [_animatingItems makeObjectsPerformSelector:@selector(removeFromSuperview)];
    _animatingItems = nil;
    
    [self invalidateDisplayLink];
    
    self.hidden = self.hidesWhenStopped;
}

#pragma mark - Bezier

/**
 *  Solves cubic Bezier for angle with given time and returns value between 0..2PI
 */
- (CGFloat)solveCubicBezierForAngleWithTime:(CGFloat)time
                          firstControlPoint:(CGPoint)firstControlPoint
                         secondControlPoint:(CGPoint)secondControlPoint {
    CGFloat maxAngle = 2 * M_PI;
    
    // Solve cubic equation and resolve for angle.
    CGFloat a = 3 * firstControlPoint.x - 3 * secondControlPoint.x + 1;
    CGFloat b = -6 * firstControlPoint.x + 3 * secondControlPoint.x;
    CGFloat c = 3 * firstControlPoint.x;
    CGFloat d = -time;
    
    CGFloat t = [self solveCubicWithA:a
                                withB:b
                                withC:c
                                withD:d];
    CGFloat tt = t * t;
    CGFloat ttt = tt * t;
    
    return (3 * t * pow(1 - t, 2) * firstControlPoint.y + 3 * tt * (1 - t) * secondControlPoint.y + ttt) * maxAngle;
}

/**
 *  Solves cubic equation (simplified version)
 *  Thanks to: https://en.wikipedia.org/wiki/Cubic_function
 */
- (CGFloat)solveCubicWithA:(CGFloat)a
                     withB:(CGFloat)b
                     withC:(CGFloat)c
                     withD:(CGFloat)d {
    b /= a;
    c /= a;
    d /= a;
    
    // If d is very small make earlier return with 0 as result.
    if (fabs(d) < FLT_EPSILON) {
        return 0;
    }
    
    CGFloat bb = b * b;
    CGFloat bbb = bb * b;
    
    CGFloat q = (bb - 3 * c) / 9;
    CGFloat r = (2 * bbb - 9 * b * c + 27 * d) / 54;
    CGFloat s =  q * q * q - r * r;
    
    CGFloat resultingValue = 0.0f;
    
    if (s < 0) {
        // 1 real root, 2 non-real.
        // Grab real root and return it.
        if (q == 0) {
            CGFloat underRootExpression = d - bbb / 27;
            
            if (underRootExpression == 0) {
                resultingValue = -b / 3;
            } else {
                resultingValue = (-pow(underRootExpression < 0 ? -underRootExpression : underRootExpression, 1.0 / 3) * underRootExpression / fabs(underRootExpression) - b / 3);
            }
        } else if (q > 0) {
            CGFloat angle = 1.0 / 3 * acosh(fabs(r) / sqrt(q * q * q));
            
            if (r == 0) {
                resultingValue = -b / 3;
            } else {
                resultingValue = -2 * r / fabs(r) * sqrt(q) * cosh(angle) - b / 3;
            }
        } else {
            // q < 0
            CGFloat angle = 1.0 / 3 * asinh(fabs(r) / sqrt(fabs(q * q * q)));
            
            if (r == 0) {
                resultingValue = -b / 3;
            } else {
                resultingValue = -2 * r / fabs(r) * sqrt(-q) * sinh(angle) - b / 3;
            }
        }
    } else if (s > 0) {
        // We've got 3 roots each is unique.
        CGFloat angle = 1.0 / 3 * acos(r / sqrt(q * q * q));
        resultingValue = -2 * sqrt(q) * cos(angle) - b / 3;
        
        if (resultingValue < 0 || resultingValue > 1) {
            resultingValue = -2 * sqrt(q) * cos(angle + (2.0 * M_PI) / 3) - b / 3;
        }
        
        if (resultingValue < 0 || resultingValue > 1) {
            resultingValue = -2 * sqrt(q) * cos(angle - (2.0 * M_PI) / 3) - b / 3;
        }
    } else {
        // We've got 3 roots, 2 of them are equal.
        // s = 0
        if (r == 0) {
            resultingValue = -b / 3;
        } else {
            resultingValue = (-2 * pow(r < 0 ? -r : r, 1.0 / 3)) * r / fabs(r) - b / 3;
            
            if (resultingValue < 0 || resultingValue > 1) {
                resultingValue = pow(r < 0 ? -r : r, 1.0 / 3) * r / fabs(r) - b / 3;
            }
        }
    }

    if (isnan(resultingValue)) {
        NSLog(@"[YRActivityIndicator]: Couldn't correctly solve cubic equation. Contact developer, or open an issue on: https://github.com/solomidSF/YRActivityIndicator/issues. Please also provide given values: T: %.24f A: %24f. B: %24f. C: %24f. D: %24f. Q: %.24f. R: %.24f. S: %.24f. Current time: %.24f. Durartion: %.24f. Max items: %d. Max speed: %.24f. 1Bezier: %@. 2Bezier: %@.",
              resultingValue,
              a,
              b,
              c,
              d,
              q,
              r,
              s,
              _currentCycleTime,
              self.cycleDuration,
              self.maxItems,
              self.maxSpeed,
              NSStringFromCGPoint(self.firstBezierControlPoint),
              NSStringFromCGPoint(self.secondBezierControlPoint));
    }
    
    // Clamp value to our interval [0..1].
    return MIN(MAX(resultingValue, 0),
               1);
}

@end
