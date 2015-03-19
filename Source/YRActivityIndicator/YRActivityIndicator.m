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

- (void)dealloc {
    NSLog(@"%s", __FUNCTION__);
}

#pragma mark - Overridden

- (void)willMoveToSuperview:(UIView *)newSuperview {
    // When we move to another superview -> invalidate current activity.
    // Normally its called two times:
    // 1. When instantiating a view from code/xib/storyboard or creating from code.
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

- (void)interpolateForTime:(CGFloat)time {
    NSLog(@"Time: %.4f. Duration: %.2f. Passed: %.2f(%%)", time, self.cycleDuration, (time / self.cycleDuration) * 100);
    
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
        
        // Interpolate by cubic bezier.
        CGFloat maxValue = 2 * M_PI;
        
        // Solve cubic equation and resolve for angle.
        CGFloat a = 3 * self.firstBezierControlPoint.x - 3 * self.secondBezierControlPoint.x + 1;
        CGFloat b = -6 * self.firstBezierControlPoint.x + 3 * self.secondBezierControlPoint.x;
        CGFloat c = 3 * self.firstBezierControlPoint.x;
        CGFloat d = -currentTime;
        
        CGFloat t = [self solveCubicWithA:a
                                    withB:b
                                    withC:c
                                    withD:d];
        CGFloat tt = t * t;
        CGFloat ttt = tt * t;
        
        CGFloat currentAngle = (3 * t * pow(1 - t, 2) * self.firstBezierControlPoint.y + 3 * tt * (1 - t) * self.secondBezierControlPoint.y + ttt) * maxValue;
        
        item.center = (CGPoint){
            (CGRectGetWidth(self.bounds) / 2) + self.radius * sin(currentAngle),
            (CGRectGetHeight(self.bounds) / 2) - self.radius * cos(currentAngle)
        };
    }
}

#pragma mark - Item Creation

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
                       forMode:NSRunLoopCommonModes];
    
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
    
    [self invalidateDisplayLink];
}

#pragma mark - Helpers

/**
 *  Solves cubic equation (simplified version)
 *  Thanks to: http://stackoverflow.com/a/15936684/2186140
 */
- (CGFloat)solveCubicWithA:(CGFloat)a
                     withB:(CGFloat)b
                     withC:(CGFloat)c
                     withD:(CGFloat)d {
    if (fabs(a) <= FLT_EPSILON) {
        return [self solveQuadraticWithA:b
                                   withB:c
                                   withC:d];
    }
    
    b /= a;
    c /= a;
    d /= a;

    if (fabs(d) <= FLT_EPSILON) {
        return 0;
    }
    
    CGFloat q = (3.0 * c - b * b) / 9.0;
    CGFloat r = (-27.0 * d + b * (9.0 * c - 2.0 * b * b)) / 54.0;
    CGFloat discriminant = q * q * q + r * r;
    CGFloat term1 = b / 3.0;
    
    if (discriminant > 0) {
        // We've got 1 real and 2 complex roots.
        // Grab real and return it.
        CGFloat s = r + sqrt(discriminant);
        CGFloat t = r - sqrt(discriminant);
        
        s = (s < 0) ? -pow(-s, 1.0 / 3) : pow(s, 1.0 / 3);
        t = (t < 0) ? -pow(-t, 1.0 / 3) : pow(t, 1.0 / 3);
        
        CGFloat result = -term1 + s + t;
        
        if (result >= 0 && result <= 1) {
            return result;
        } else {
            NSLog(@"Error! Should return result.");
        }
    } else if (discriminant == 0) {
        // We've got all real roots.
        CGFloat r13 = (r < 0) ? -sqrt(-r) : sqrt(r);
        
        CGFloat result = -term1 + 2.0 * r13;
        
        if (result >= 0 && result <= 1) {
            return result;
        } else {
            result = -(r13 + term1);

            if (result >= 0 && result <= 1) {
                return result;
            } else {
                NSLog(@"ERROR IN D = 0");
            }
        }
    } else {
        // We've got 3 roots for that equation and they aren't equal to each other.
        q = -q;
        CGFloat qqq = q * q * q;
        
        CGFloat dum1 = acos(r / sqrt(qqq));
        CGFloat r13 = 2.0 * sqrt(q);
        
        for (int i = 0; i < 3; i++) {
            CGFloat result = -term1 + r13 * cos((dum1 + i * 2 * M_PI) / 3);
            NSLog(@"RESULT: %.2f", result);
            
            if (result >= 0 && result <= 1) {
                return result;
            }
        }
    }
    
    NSLog(@"GOT TO END! ERROR");
    return 0.0;
}

// Solves the equation ax² + bx + c = 0 for x ϵ ℝ
// and returns the first result in [0, 1] or null.
- (CGFloat)solveQuadraticWithA:(CGFloat)a
                         withB:(CGFloat)b
                         withC:(CGFloat)c {
    CGFloat result = (-b + sqrt(b * b - 4 * a * c)) / (2 * a);
    
    if (result >= 0 && result <= 1) {
        return result;
    } else {
        result = (-b - sqrt(b * b - 4 * a * c)) / (2 * a);
        if (result >= 0 && result <= 1) {
            return result;
        }
    }
    
    NSLog(@"ERROR QUADRATIC.");
    return 0.0;
}

@end
