//
//  ViewController.m
//  ActivityIndicatorDemo
//
//  Created by Yuriy Romanchenko on 3/18/15.
//  Copyright (c) 2015 solomidSF. All rights reserved.
//

// ViewControllers
#import "ViewController.h"

// Components
#import "YRActivityIndicator.h"

@implementation ViewController {
    __weak IBOutlet UILabel *_cycleDurationLabel;

    __weak IBOutlet UILabel *_radiusValueLabel;

    __weak IBOutlet UILabel *_maxSpeedValueLabel;
    
    __weak IBOutlet UILabel *_minItemSizeValueLabel;
    __weak IBOutlet UILabel *_maxItemSizeValueLabel;
    
    __weak IBOutlet UILabel *_maxItemsLabel;

    __weak IBOutlet YRActivityIndicator *_activityIndicator;
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
    // TODO:
}

- (IBAction)hidesWhenStoppedValueChanged:(UISwitch *)sender {
    _activityIndicator.hidesWhenStopped = sender.on;
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

- (IBAction)maxItemsValueChanged:(UIStepper *)sender {
    _activityIndicator.maxItems = sender.value;

    [self refreshUI];
}

#pragma mark - Private

- (void)refreshUI {
    _cycleDurationLabel.text = [NSString stringWithFormat:@"Cycle duration: %.2f", _activityIndicator.cycleDuration];
    
    _radiusValueLabel.text = [NSString stringWithFormat:@"Radius: %d", _activityIndicator.radius];

    _maxSpeedValueLabel.text = [NSString stringWithFormat:@"Max speed: %.2f", _activityIndicator.maxSpeed];

    _minItemSizeValueLabel.text = [NSString stringWithFormat:@"Min item size: {%.2f, %.2f}", _activityIndicator.minItemSize.width, _activityIndicator.minItemSize.height];
    _maxItemSizeValueLabel.text = [NSString stringWithFormat:@"Max item size: {%.2f, %.2f}", _activityIndicator.maxItemSize.width, _activityIndicator.maxItemSize.height];
    
    _maxItemsLabel.text = [NSString stringWithFormat:@"Max items: %d", _activityIndicator.maxItems];
}

@end
