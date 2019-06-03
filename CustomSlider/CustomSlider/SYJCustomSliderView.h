//
//  SYJCustomSliderView.h
//  CustomPhoto
//
//  Created by syj on 2018/1/4.
//  Copyright © 2018年 S.Y.J. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SYJCustomSliderView : UIView

//@property (nonatomic, assign) float progress; //进度
@property (nonatomic, copy) NSString *time; //时间，格式： 当前时间/总时间
@property (nonatomic, strong) UIColor *trackColor; //底色
@property (nonatomic, strong) UIColor *progressColor; //轨迹颜色

@property (nonatomic, copy) void(^startDragSliderViewBolck)(float progress);
@property (nonatomic, copy) void(^stopDragSliderViewBolck)(float progress);

@end
