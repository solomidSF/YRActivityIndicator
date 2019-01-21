# YRActivityIndicator

`YRActivityIndicator` is simple, highly-customizable lightweight component to present loading activity in your application.

## Description

`YRActivityIndicator` - component for showing loading activity in your application. Animation consist of items that rotate around imaginary circle in fixed time interval. Items size are interpolated linearly between `maxItemSize` and `minItemSize`. Each item has it’s own rotation speed value, that tells how fast it will make full rotation cycle from 0..2PI. This value is specified by setting `maxSpeed` property and it’s interpolated linearly between items. First item get’s max speed, last item gets regular speed (1.0). Rotation angle is interpolated by using cubic Bezier curve. 

## Demo

`YRActivityIndicator` with default settings:

![Demo](https://raw.githubusercontent.com/solomidSF/YRActivityIndicator/1.2.0/DemoImages/demo.gif)

Customization demo:

[![FullDemo](https://raw.githubusercontent.com/solomidSF/YRActivityIndicator/1.2.0/DemoImages/youtube.png)](https://www.youtube.com/watch?v=YJ3_vZMaG8E&feature=youtu.be)

[See full video on YouTube](https://www.youtube.com/watch?v=YJ3_vZMaG8E&feature=youtu.be)

## Installation

#### Manual
Simply drag&drop source into your project.

#### CocoaPods
YRActivityIndicator is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'YRActivityIndicator'
```


## Usage

1. Create regular view and set it’s class to `YRActivityIndicator`.
2. Create outlet connection for it in your class which should present loading activity.
3. Customize any properties you want before presenting.
4. Call `-(void)startAnimating` on `YRActivityIndicator` object.
5. When you need to stop animating call `-(void)stopAnimating`.

## Customization 

You can customize these properties at any time, even while animating.
Also you can customize `YRActivityIndicator` directly in xib/storyboard by using User Defined Runtime Attributes:
![RuntimeAttributes](https://raw.githubusercontent.com/solomidSF/YRActivityIndicator/1.2.0/DemoImages/RuntimeAttributes.png)

In addition, `YRActivityIndicator` supports live rendering in Interface Builder:
![LiveRendering](https://raw.githubusercontent.com/solomidSF/YRActivityIndicator/1.2.0/DemoImages/LiveRendering.png)

Total count of items that will turn around imaginary circle.

`@property (nonatomic) int32_t maxItems;`

Radius of imaginary circle around which items are rotating.

`@property (nonatomic) int32_t radius;`


Describes how much time needed to rotate around circle.

`@property (nonatomic) NSTimeInterval cycleDuration;`


Minimum/Maximum item size. Generally, item sizes are linearly interpolated from first to last, so first item would have `maxItemSize` and last item would have `minItemSize`.

`@property (nonatomic) CGSize minItemSize;`
`@property (nonatomic) CGSize maxItemSize;`

Tells how much faster items will make full rotation around a circle. This value is linearly interpolated between items. First item would get `maxSpeed`, last item would get `minSpeed`(`minSpeed` always equal to 1).

`@property (nonatomic) CGFloat maxSpeed;`

All items are rotated around imaginary circle, thus they depend on angle. Angle of rotation is interpolated by using cubic Bezier. Cubic Bezier has 4 control points to configure a curve (more information [here](http://en.wikipedia.org/wiki/B%C3%A9zier_curve#Cubic_B.C3.A9zier_curves)). 2 curves are preserved by component (initial, final) and they are equal to (0, 0) and (1, 1). Other two can be customized by you. You can use for example this [site](http://cubic-bezier.com/) to adjust your curve/grab control point and set them for activity indicator.

`@property (nonatomic) CGPoint firstBezierControlPoint;`
`@property (nonatomic) CGPoint secondBezierControlPoint;`

When activity indicator isn’t animating it can automatically hide if this property set to `YES`.    

`@property (nonatomic) BOOL hidesWhenStopped;`


You can provide custom image for items that are rotating. `itemImage` has more priority than `itemColor`, so setting color when component has image won’t change anything.

`@property (nonatomic) UIImage *itemImage;`

Color of items that will be animated.

`@property (nonatomic) UIColor *itemColor;` 

Simply tells is current activity indicator is animating or not.

`@property (nonatomic, readonly) BOOL isAnimating;`

## Notes

If you have any suggestions feel free to [contact](mailto:solomidSF@bk.ru) me.

## Version

v1.2.0

## License

YRActivityIndicator is released under the MIT license. See [LICENSE](https://github.com/solomidSF/YRActivityIndicator/blob/master/LICENSE) for details.
