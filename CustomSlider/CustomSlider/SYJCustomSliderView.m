//
//  SYJCustomSliderView.m
//  CustomPhoto
//
//  Created by syj on 2018/1/4.
//  Copyright © 2018年 S.Y.J. All rights reserved.
//

#import "SYJCustomSliderView.h"

#define kColor(r,g,b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]
#define TimeLabelHeight 20

@interface SYJCustomSliderView () <UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIView *maxTrackView;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UIView *timeLabelView;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, assign) CGPoint startPoint;
@property (nonatomic, assign) double totalTime;
@end

@implementation SYJCustomSliderView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self configure];
        [self initUI];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self configure];
        [self initUI];
    }
    return self;
}

- (void)configure {
    self.trackColor = kColor(102, 102, 102);
    self.progressColor = kColor(244, 0, 145);
}

- (void)initUI {
    self.userInteractionEnabled = YES;
    self.backgroundColor = [UIColor clearColor];
    UIProgressView *progressView = [[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleDefault];
    progressView.frame = CGRectMake(0, 0, self.frame.size.width, 5);
    progressView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    progressView.trackTintColor = self.trackColor; //底色
    progressView.progressTintColor = self.progressColor; //填充颜色
    progressView.progress = 0;
    progressView.userInteractionEnabled = YES;
    [self addSubview:progressView];
    self.progressView = progressView;
    
    UIView *timeLabelView = [[UIView alloc]init];
    timeLabelView.frame = CGRectMake(0, 0, 50, self.frame.size.height);
    [self addSubview:timeLabelView];
    self.timeLabelView = timeLabelView;
//    self.timeLabelView.backgroundColor = [UIColor orangeColor];
//    self.timeLabelView.alpha = 0.3;
    
    UILabel *timeLabel = [[UILabel alloc]init];
    timeLabel.frame = CGRectMake(0, 0, 60, TimeLabelHeight);
    timeLabel.center = CGPointMake(40, timeLabelView.frame.size.height/2);
    timeLabel.textColor = kColor(201, 201, 201);
    timeLabel.backgroundColor = kColor(51, 51, 51);
    timeLabel.font = [UIFont systemFontOfSize:12];
    timeLabel.textAlignment = NSTextAlignmentCenter;
    timeLabel.layer.cornerRadius = TimeLabelHeight/2;
    timeLabel.layer.masksToBounds = YES;
    timeLabel.layer.borderColor = kColor(201, 201, 201).CGColor;
    timeLabel.layer.borderWidth = 0.6;
    timeLabel.userInteractionEnabled = YES;
    [timeLabelView addSubview:timeLabel];
    self.timeLabel = timeLabel;
    
    CGFloat timeLabelWidth = [self getWidthWithTitle:self.timeLabel.text font:self.timeLabel.font];
    self.timeLabelView.frame = CGRectMake(0, 0, timeLabelWidth+4, self.frame.size.height);
    self.timeLabel.frame = CGRectMake(0, 0, timeLabelWidth+4, TimeLabelHeight);
    self.timeLabel.center = CGPointMake(self.timeLabelView.frame.size.width/2, self.timeLabelView.frame.size.height/2);
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pan:)];
    pan.delegate = self;
    [timeLabelView addGestureRecognizer:pan];
}


- (void)drawRect:(CGRect)rect {
    self.progressView.frame = CGRectMake(0, 0, self.frame.size.width, 5);
    self.progressView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    CGFloat timeLabelWidth = [self getWidthWithTitle:self.timeLabel.text font:self.timeLabel.font];
    double timeLabelViewX = self.progressView.frame.size.width * self.progressView.progress;
    self.timeLabelView.frame = CGRectMake(timeLabelViewX - timeLabelWidth * self.progressView.progress, 0, timeLabelWidth+4, self.frame.size.height);
    self.timeLabel.frame = CGRectMake(0, 0, timeLabelWidth+4, TimeLabelHeight);
    self.timeLabel.center = CGPointMake(self.timeLabelView.frame.size.width/2, self.timeLabelView.frame.size.height/2);
}

#pragma mark - 手势方法
- (void)pan:(UIPanGestureRecognizer *)pan {
    if (pan.state == UIGestureRecognizerStateBegan) { //拖动开始
        if (self.startDragSliderViewBolck) {
            self.startDragSliderViewBolck(self.progressView.progress);
        }
    }else if (pan.state == UIGestureRecognizerStateChanged) { //拖动中
        CGPoint translation = [pan translationInView:self];
        pan.view.center = CGPointMake(pan.view.center.x + translation.x, pan.view.center.y);
        
//        NSLog(@"%f  %f  %f",pan.view.center.x, pan.view.frame.size.width/2.0, self.timeLabelView.frame.origin.x);
        
        if ((pan.view.center.x - pan.view.frame.size.width/2.0) <= self.progressView.frame.origin.x) {
            pan.view.center = CGPointMake(self.progressView.frame.origin.x + pan.view.frame.size.width/2.0, pan.view.center.y);
        }
        if ((pan.view.center.x + pan.view.frame.size.width/2.0) > self.progressView.frame.size.width) {
            pan.view.center = CGPointMake(self.progressView.frame.size.width - pan.view.frame.size.width/2.0, pan.view.center.y);
        }

        // progressView 与 label 的速度比
        double speedRatio =  (self.progressView.frame.size.width/2) / (self.progressView.frame.size.width/2 - self.timeLabelView.frame.size.width/2);
        self.progressView.progress = self.timeLabelView.frame.origin.x/self.progressView.frame.size.width * speedRatio;
        if (speedRatio == 0) {
            self.progressView.progress = 0;
        }
        
        double currentTime = self.progressView.progress * self.totalTime;
//        NSLog(@" %f  ",self.progressView.progress);
        NSString *timeLabelText = [NSString stringWithFormat:@"%@/%@",[self getPlayerCurrentTime:currentTime],[self getPlayerTotalTime:self.totalTime]];
        self.timeLabel.text = timeLabelText;
        CGFloat timeLabelWidth = [self getWidthWithTitle:self.timeLabel.text font:self.timeLabel.font] + 6.0;
//        CGFloat timeLabelWidth = [self getWidthWithTitle:[NSString stringWithFormat:@"%@/%@",[self getPlayerCurrentTime:self.totalTime],[self getPlayerTotalTime:self.totalTime]] font:self.timeLabel.font] + 6.0;
        double timeLabelViewX = self.progressView.frame.size.width * self.progressView.progress;
        self.timeLabelView.frame = CGRectMake(timeLabelViewX - timeLabelWidth * self.progressView.progress, 0, timeLabelWidth, self.frame.size.height);
        self.timeLabel.frame = CGRectMake(0, 0, timeLabelWidth, TimeLabelHeight);
        self.timeLabel.center = CGPointMake(self.timeLabelView.frame.size.width/2, self.timeLabelView.frame.size.height/2);
        
        //清空位移数据，避免拖拽事件的位移叠加
        [pan setTranslation:CGPointZero inView:pan.view];
    }else { //拖动结束
        if (self.stopDragSliderViewBolck) {
            self.stopDragSliderViewBolck(self.progressView.progress);
        }
    }
}

- (void)setTime:(NSString *)time {
    _time = time;
    
    NSArray *array = [time componentsSeparatedByString:@"/"]; //从字符A中分隔成2个元素的数组
//    NSLog(@"time:%@",time);
    if (array.count < 2) return;
    double currentTime = [array[0] doubleValue];
    double totalTime = [array[1] doubleValue];  self.totalTime = totalTime;;
    double progressValue = currentTime/totalTime;
    if (totalTime == 0) {
        progressValue = 0;
    }
    
    NSString *timeLabelText = [NSString stringWithFormat:@"%@/%@",[self getPlayerCurrentTime:currentTime],[self getPlayerTotalTime:totalTime]];
    self.timeLabel.text = timeLabelText;
    CGFloat timeLabelWidth = [self getWidthWithTitle:self.timeLabel.text font:self.timeLabel.font] + 6.0;
//    CGFloat timeLabelWidth = [self getWidthWithTitle:[NSString stringWithFormat:@"%@/%@",[self getPlayerCurrentTime:totalTime],[self getPlayerTotalTime:totalTime]] font:self.timeLabel.font] + 6.0;
    
    self.progressView.progress = progressValue;
    double timeLabelViewX = self.progressView.frame.size.width * progressValue;
//    NSLog(@"~~ %lf %lf",progressValue,timeLabelViewX);
    
    self.timeLabelView.frame = CGRectMake(timeLabelViewX - timeLabelWidth * progressValue, 0, timeLabelWidth, self.frame.size.height);
    self.timeLabel.frame = CGRectMake(0, 0, timeLabelWidth, TimeLabelHeight);
    self.timeLabel.center = CGPointMake(self.timeLabelView.frame.size.width/2, self.timeLabelView.frame.size.height/2);
    
}

- (NSString *) getPlayerCurrentTime:(NSTimeInterval)time {
    NSInteger currentTime = time;
    if (currentTime >= 3600) {
        return [NSString stringWithFormat:@"%2d:%02d:%02d",currentTime/60/60%60,currentTime/60%60,currentTime%60];
    }else {
        return [NSString stringWithFormat:@"%2d:%02d",currentTime/60%60,currentTime%60];
    }
    
}

- (NSString *) getPlayerTotalTime:(NSTimeInterval)time {
    NSInteger totalTime = time;
    if (totalTime >= 3600) {
        return [NSString stringWithFormat:@"%2d:%02d:%02d",totalTime/60/60%60,totalTime/60%60,totalTime%60];
    }else {
        return [NSString stringWithFormat:@"%2d:%02d",totalTime/60%60,totalTime%60];
    }
}

//时间转化格式
- (NSString *)TimeformatFromSeconds:(NSInteger)seconds
{
    //format of hour
    NSString *str_hour = [NSString stringWithFormat:@"%02d",seconds/3600];
    //format of minute
    NSString *str_minute = [NSString stringWithFormat:@"%02d",(seconds%3600)/60];
    //format of second
    NSString *str_second = [NSString stringWithFormat:@"%02d",seconds%60];
    //format of time
    if ([str_hour isEqualToString: @"00"]) { //如果小时数为0，只显示分和秒
        return [NSString stringWithFormat:@"%@:%@",str_minute,str_second];
    } else {
        return [NSString stringWithFormat:@"%@:%@:%@",str_hour,str_minute,str_second];
    }
}

- (CGFloat)getWidthWithTitle:(NSString *)title font:(UIFont *)font {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 1000, 0)];
    label.text = title;
    label.font = font;
    [label sizeToFit];
    return label.frame.size.width;
}


- (void)setTrackColor:(UIColor *)trackColor {
    _trackColor = trackColor;
    self.progressView.trackTintColor = trackColor;
}

- (void)setProgressColor:(UIColor *)progressColor {
    _progressColor = progressColor;
    self.progressView.progressTintColor = progressColor;
}

@end
