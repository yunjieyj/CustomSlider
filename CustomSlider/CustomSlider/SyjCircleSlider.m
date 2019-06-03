//
//  SyjCircleSlider.m
//  CustomSlider
//
//  Created by Syj on 2019/6/3.
//  Copyright © 2019 Syj. All rights reserved.
//

#import "SyjCircleSlider.h"

@interface SyjCircleSlider ()

@property (nonatomic, assign) CGPoint touchPoint;
@property (nonatomic, assign) CGPoint lastPoint;
@property (nonatomic, assign) CGFloat angle;
@property (nonatomic, assign) CGFloat lastAngle;
@property (nonatomic, assign) float lastValue;

@end

@implementation SyjCircleSlider

- (void)configure
{
    self.value = 0.0;

    self.clockwise = YES;
    self.startAngle = M_PI_2;
    self.lineWidth = 5;
    self.strokeColor = [UIColor whiteColor];
    self.fillColor = [UIColor cyanColor];
    self.backgroundCircleColor = [UIColor grayColor];
}

- (void)initialization
{
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configure];
        [self initialization];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self configure];
        [self initialization];
    }
    return self;
}

- (void)dealloc {
}

- (void)drawRect:(CGRect)rect {
    // Get Current Context
    CGContextRef context = UIGraphicsGetCurrentContext();

    NSUInteger radius = rect.size.width / 3 * 2;
    // backgroundCircle
    CGContextSetLineWidth(context, self.lineWidth);
    CGContextSetStrokeColorWithColor(context, self.backgroundCircleColor.CGColor);
    CGContextStrokeEllipseInRect(context, CGRectMake((rect.size.width - radius) / 2 + self.lineWidth / 2,(rect.size.height - radius) / 2 + self.lineWidth / 2, radius - self.lineWidth, radius - self.lineWidth));
//    CGContextAddEllipseInRect(context, rect);
//    CGContextStrokePath(context);

    CGContextSetLineWidth(context, self.lineWidth);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    CGContextSetStrokeColorWithColor(context, self.strokeColor.CGColor);
    CGContextSetFillColorWithColor(context, self.fillColor.CGColor);
    CGContextBeginPath(context);
//    from 0 -> 2 * M_PI
//    from 0.0 -> 1.0
    CGContextAddArc(context, rect.size.width / 2, rect.size.height / 2, radius / 2 - self.lineWidth / 2, self.startAngle, self.startAngle + self.angle, !self.clockwise);
    CGContextStrokePath(context);
//    CGContextDrawPath(context, kCGPathFill);
//    CGContextFillPath(context);
}

- (void)setValue:(float)value
{
    _value = value;
    self.angle = self.value * 2 * M_PI;
    [self setNeedsDisplay];
}

#pragma mark - UIResponder touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    NSArray *array = [event.allTouches allObjects];
    self.touchPoint = [touch locationInView:self];
    self.lastPoint = self.touchPoint;
    self.lastValue = self.value;
    self.lastAngle = self.angle;
    [self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    self.touchPoint = [touch locationInView:self];
    CGFloat increaseAngle = atan2(self.touchPoint.y - self.bounds.size.height / 2, self.touchPoint.x - self.bounds.size.width / 2) - atan2(self.lastPoint.y - self.bounds.size.height / 2, self.lastPoint.x - self.bounds.size.width / 2);
    self.angle = self.lastAngle + increaseAngle;
    if (self.angle < 0) {
        self.angle += 2 * M_PI;
    } else if (self.angle > 2 * M_PI) {
        self.angle -= 2 * M_PI;
    }
    self.value = self.angle / (2 * M_PI);
    if (self.lastValue < 0.25 && self.lastValue >= 0) {
        if (self.value > 0.5) {
            self.angle = 0;
            self.value = self.angle / (2 * M_PI);
            self.lastAngle = self.angle;
            self.lastPoint = self.touchPoint;
//            NSLog(@"1 - 4");
//        } else {
//            NSLog(@"11 %f", self.value);
        }
    } else if (self.lastValue > 0.75 && self.lastValue <= 1) {
        if (self.value < 0.5) {
            self.angle = 2 * M_PI;
            self.value = self.angle / (2 * M_PI);
            self.lastAngle = self.angle;
            self.lastPoint = self.touchPoint;
//            NSLog(@"4 - 1");
//        } else {
//            NSLog(@"44 %f", self.value);
        }
    }
    if (self.value != self.lastValue) {
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
    self.lastValue = self.value;
//    NSLog(@"%f %f", self.value, self.angle);
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    self.touchPoint = [touch locationInView:self];
    self.lastAngle = self.angle;
    [self setNeedsDisplay];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    self.touchPoint = [touch locationInView:self];
    self.lastAngle = self.angle;
    [self setNeedsDisplay];
}

@end
