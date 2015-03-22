//
//  ViewController.m
//  ActivityIndicatorDemo
//
//  Created by Yuriy Romanchenko on 3/18/15.
//  Copyright (c) 2015 solomidSF. All rights reserved.
//

// ViewControllers
#import "DemoViewController.h"

// Components
#import "YRActivityIndicator.h"

@implementation DemoViewController {
    // Sliders/Switches
    __weak IBOutlet UISwitch *_hidesWhenStoppedSwitch;
    __weak IBOutlet UIStepper *_maxItemsStepper;
    __weak IBOutlet UISlider *_cycleDurationSlider;
    __weak IBOutlet UISlider *_radiusSlider;
    __weak IBOutlet UISlider *_maxSpeedSlider;
    __weak IBOutlet UISlider *_minItemSizeSlider;
    __weak IBOutlet UISlider *_maxItemSizeSlider;
    __weak IBOutlet UISlider *_firstBezierXControlPointSlider;
    __weak IBOutlet UISlider *_firstBezierYControlPointSlider;
    __weak IBOutlet UISlider *_secondBezierXControlPointSlider;
    __weak IBOutlet UISlider *_secondBezierYControlPointSlider;
    __weak IBOutlet UISlider *_redValueSlider;
    __weak IBOutlet UISlider *_greenValueSlider;
    __weak IBOutlet UISlider *_blueValueSlider;
    
    // UI
    __weak IBOutlet UILabel *_maxItemsLabel;
    
    __weak IBOutlet UILabel *_cycleDurationLabel;
    
    __weak IBOutlet UILabel *_radiusValueLabel;

    __weak IBOutlet UILabel *_maxSpeedValueLabel;
    
    __weak IBOutlet UILabel *_minItemSizeValueLabel;
    __weak IBOutlet UILabel *_maxItemSizeValueLabel;

    __weak IBOutlet UILabel *_firstBezierXPointValueLabel;
    __weak IBOutlet UILabel *_firstBezierYPointValueLabel;
    
    __weak IBOutlet UILabel *_secondBezierXPointValueLabel;
    __weak IBOutlet UILabel *_secondBezierYPointValueLabel;
    
    __weak IBOutlet UILabel *_redValueLabel;
    __weak IBOutlet UILabel *_greenValueLabel;
    __weak IBOutlet UILabel *_blueValueLabel;
    
    // Overlay
    __weak IBOutlet UIView *_overlayView;
    __weak IBOutlet UIView *_overlayContentView;
    
    // Activity indicator
    __weak IBOutlet YRActivityIndicator *_activityIndicator;
    IBOutlet NSLayoutConstraint *_activityIndicatorHorizontalConstraint;
    IBOutlet NSLayoutConstraint *_activityIndicatorVerticalConstraint;
}

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self refreshUI];
}

#pragma mark - Callbacks

- (IBAction)startClicked:(id)sender {
    [_activityIndicator startAnimating];
}

- (IBAction)stopClicked:(id)sender {
    [_activityIndicator stopAnimating];
}

- (IBAction)overlayClicked:(id)sender {
    if (_activityIndicator.isAnimating) {
        [UIView animateWithDuration:0.25
                         animations:^{
                             _overlayView.alpha = 1;
                         } completion:^(BOOL finished) {
                             [_overlayContentView addSubview:_activityIndicator];

                             [self.view removeConstraints:@[_activityIndicatorHorizontalConstraint,
                                                            _activityIndicatorVerticalConstraint]];

                             NSLayoutConstraint *horizontalConstraint = nil;
                             NSLayoutConstraint *verticalConstraint = nil;
                             
                             horizontalConstraint = [NSLayoutConstraint constraintWithItem:_activityIndicator
                                                                                 attribute:NSLayoutAttributeCenterX
                                                                                 relatedBy:NSLayoutRelationEqual
                                                                                    toItem:_overlayContentView
                                                                                 attribute:NSLayoutAttributeCenterX
                                                                                multiplier:1
                                                                                  constant:0];

                             verticalConstraint = [NSLayoutConstraint constraintWithItem:_activityIndicator
                                                                               attribute:NSLayoutAttributeCenterY
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:_overlayContentView
                                                                               attribute:NSLayoutAttributeCenterY
                                                                              multiplier:1
                                                                                constant:0];

                             [_overlayView addConstraints:@[horizontalConstraint, verticalConstraint]];
                             
                             [self.view layoutIfNeeded];
                             
                             [_activityIndicator startAnimating];
                         }];
    }
}

- (IBAction)resetClicked:(id)sender {
    // Set default data for activity indicator.
    _activityIndicator.minItemSize = (CGSize){5, 5};
    _activityIndicator.maxItemSize = (CGSize){20, 20};
    _activityIndicator.maxItems = 6;
    
    _activityIndicator.maxSpeed = 1.6;
    
    _activityIndicator.cycleDuration = 2;
    
    _activityIndicator.radius = 30;
    
    _activityIndicator.itemImage = nil;
    _activityIndicator.itemColor = [UIColor whiteColor];
    
    _activityIndicator.firstBezierControlPoint = (CGPoint){0.89, 0};
    _activityIndicator.secondBezierControlPoint = (CGPoint){0.12, 1};
    
    // Update sliders.
    _hidesWhenStoppedSwitch.on = _activityIndicator.hidesWhenStopped;
    _maxItemSizeSlider.value = _activityIndicator.maxItems;
    _cycleDurationSlider.value = _activityIndicator.cycleDuration;
    _radiusSlider.value = _activityIndicator.radius;
    _maxSpeedSlider.value = _activityIndicator.maxSpeed;
    _minItemSizeSlider.value = _activityIndicator.minItemSize.width;
    _maxItemSizeSlider.value = _activityIndicator.maxItemSize.width;
    _firstBezierXControlPointSlider.value = _activityIndicator.firstBezierControlPoint.x;
    _firstBezierYControlPointSlider.value = _activityIndicator.firstBezierControlPoint.y;
    _secondBezierXControlPointSlider.value = _activityIndicator.secondBezierControlPoint.x;
    _secondBezierYControlPointSlider.value = _activityIndicator.secondBezierControlPoint.y;
    _redValueSlider.value = 1;
    _greenValueSlider.value = 1;
    _blueValueSlider.value = 1;
    
    [self refreshUI];
}

- (IBAction)hidesWhenStoppedValueChanged:(UISwitch *)sender {
    _activityIndicator.hidesWhenStopped = sender.on;
}

- (IBAction)maxItemsValueChanged:(UIStepper *)sender {
    _activityIndicator.maxItems = sender.value;
    
    [self refreshUI];
}

- (IBAction)cycleDurationSliderValueChanged:(UISlider *)sender {
    _activityIndicator.cycleDuration = sender.value;

    [self refreshUI];
}

- (IBAction)radiusSliderValueChanged:(UISlider *)sender {
    _activityIndicator.radius = sender.value;
    
    [self refreshUI];
}

- (IBAction)maxSpeedSliderValueChanged:(UISlider *)sender {
    _activityIndicator.maxSpeed = sender.value;
    
    [self refreshUI];
}

- (IBAction)minItemSizeSliderValueChanged:(UISlider *)sender {
    _activityIndicator.minItemSize = (CGSize){
        sender.value,
        sender.value
    };
    
    [self refreshUI];
}

- (IBAction)maxItemSizeSliderValueChanged:(UISlider *)sender {
    _activityIndicator.maxItemSize = (CGSize){
        sender.value,
        sender.value
    };
    
    [self refreshUI];
}

- (IBAction)firstBezierXPointValueChanged:(UISlider *)sender {
    _activityIndicator.firstBezierControlPoint = (CGPoint) {
        sender.value,
        _activityIndicator.firstBezierControlPoint.y
    };
    
    [self refreshUI];
}

- (IBAction)firstBezierYPointValueChanged:(UISlider *)sender {
    _activityIndicator.firstBezierControlPoint = (CGPoint) {
        _activityIndicator.firstBezierControlPoint.x,
        sender.value
    };
    
    [self refreshUI];
}

- (IBAction)secondBezierXPointValueChanged:(UISlider *)sender {
    _activityIndicator.secondBezierControlPoint = (CGPoint) {
        sender.value,
        _activityIndicator.secondBezierControlPoint.y
    };
    
    [self refreshUI];
}

- (IBAction)secondBezierYPointValueChanged:(UISlider *)sender {
    _activityIndicator.secondBezierControlPoint = (CGPoint) {
        _activityIndicator.secondBezierControlPoint.x,
        sender.value
    };
    
    [self refreshUI];
}

- (IBAction)redValueSliderChanged:(UISlider *)sender {
    CGFloat currentGreen = 0;
    CGFloat currentBlue = 0;
    
    [_activityIndicator.itemColor getRed:NULL
                                   green:&currentGreen
                                    blue:&currentBlue
                                   alpha:NULL];
    
    _activityIndicator.itemColor = [UIColor colorWithRed:sender.value
                                                   green:currentGreen
                                                    blue:currentBlue
                                                   alpha:1];
    
    [self refreshUI];
}

- (IBAction)greenValueSliderChanged:(UISlider *)sender {
    CGFloat currentRed = 0;
    CGFloat currentBlue = 0;
    
    [_activityIndicator.itemColor getRed:&currentRed
                                   green:NULL
                                    blue:&currentBlue
                                   alpha:NULL];
    
    _activityIndicator.itemColor = [UIColor colorWithRed:currentRed
                                                   green:sender.value
                                                    blue:currentBlue
                                                   alpha:1];

    [self refreshUI];
}

- (IBAction)blueValueSliderChanged:(UISlider *)sender {
    CGFloat currentRed = 0;
    CGFloat currentGreen = 0;
    
    [_activityIndicator.itemColor getRed:&currentRed
                                   green:&currentGreen
                                    blue:NULL
                                   alpha:NULL];
    
    _activityIndicator.itemColor = [UIColor colorWithRed:currentRed
                                                   green:currentGreen
                                                    blue:sender.value
                                                   alpha:1];

    [self refreshUI];
}

- (IBAction)catClicked:(id)sender {
    _activityIndicator.itemImage = [UIImage imageNamed:@"cat"];
}

- (IBAction)heartClicked:(id)sender {
    _activityIndicator.itemImage = [UIImage imageNamed:@"heart"];
}

- (IBAction)weatherClicked:(id)sender {
    _activityIndicator.itemImage = [UIImage imageNamed:@"weather"];
}

- (IBAction)closeOverlayClicked:(id)sender {
    [UIView animateWithDuration:0.25
                     animations:^{
                         _overlayView.alpha = 0;
                     } completion:^(BOOL finished) {
                         [self.view addSubview:_activityIndicator];

                         [_activityIndicator startAnimating];
                         
                         [self.view addConstraints:@[_activityIndicatorHorizontalConstraint,
                                                     _activityIndicatorVerticalConstraint]];
                         [self.view layoutIfNeeded];
                     }];
}

#pragma mark - Private

- (void)refreshUI {
    _maxItemsLabel.text = [NSString stringWithFormat:@"Max items: %d", _activityIndicator.maxItems];

    _cycleDurationLabel.text = [NSString stringWithFormat:@"Cycle duration: %.2f", _activityIndicator.cycleDuration];
    
    _radiusValueLabel.text = [NSString stringWithFormat:@"Radius: %d", _activityIndicator.radius];

    _maxSpeedValueLabel.text = [NSString stringWithFormat:@"Max speed: %.2f", _activityIndicator.maxSpeed];

    _minItemSizeValueLabel.text = [NSString stringWithFormat:@"Min item size: {%.2f, %.2f}", _activityIndicator.minItemSize.width, _activityIndicator.minItemSize.height];
    _maxItemSizeValueLabel.text = [NSString stringWithFormat:@"Max item size: {%.2f, %.2f}", _activityIndicator.maxItemSize.width, _activityIndicator.maxItemSize.height];
    
    _firstBezierXPointValueLabel.text = [NSString stringWithFormat:@"1 Bezier x: %.2f", _activityIndicator.firstBezierControlPoint.x];
    _firstBezierYPointValueLabel.text = [NSString stringWithFormat:@"1 Bezier y: %.2f", _activityIndicator.firstBezierControlPoint.y];
    
    _secondBezierXPointValueLabel.text = [NSString stringWithFormat:@"2 Bezier x: %.2f", _activityIndicator.secondBezierControlPoint.x];
    _secondBezierYPointValueLabel.text = [NSString stringWithFormat:@"2 Bezier y: %.2f", _activityIndicator.secondBezierControlPoint.y];
    
    CGFloat currentRed = 0;
    CGFloat currentGreen = 0;
    CGFloat currentBlue = 0;
    
    [_activityIndicator.itemColor getRed:&currentRed
                                   green:&currentGreen
                                    blue:&currentBlue
                                   alpha:NULL];
    
    _redValueLabel.text = [NSString stringWithFormat:@"Red: %d", (int32_t)(currentRed * 255)];
    _greenValueLabel.text = [NSString stringWithFormat:@"Green: %d", (int32_t)(currentGreen * 255)];
    _blueValueLabel.text = [NSString stringWithFormat:@"Blue: %d", (int32_t)(currentBlue * 255)];
}

@end
