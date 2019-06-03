//
//  SyjCircleSlider.h
//  CustomSlider
//
//  Created by Syj on 2019/6/3.
//  Copyright © 2019 Syj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SyjCircleSlider : UIControl

@property (nonatomic, assign) float value;// 0.0 - 1.0

@property (nonatomic, assign) BOOL clockwise;//默认顺时针
@property (nonatomic, assign) CGFloat startAngle;//M_PI_2
@property (nonatomic, assign) CGFloat lineWidth;
@property (nonatomic, strong) UIColor *strokeColor; //填充轨迹颜色
@property (nonatomic, strong) UIColor *fillColor; 
@property (nonatomic, strong) UIColor *backgroundCircleColor; //圆圈颜色

@end
