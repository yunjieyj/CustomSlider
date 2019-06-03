//
//  ViewController.m
//  1111111
//
//  Created by syj on 16/9/28.
//  Copyright © 2016年 syj. All rights reserved.
//

#import "ViewController.h"
#import "PlayerManager.h"
#import <AVFoundation/AVFoundation.h>
#import "SyjCircleSlider.h"
#import "SYJCustomSliderView.h"

#define localFile @"zhuimeng"
#define netFile1 @"http://mr1.doubanio.com/2081bb1e22f79ab5d8afee437091aa5c/0/fm/song/p1948600_128k.mp3"
#define netFile2 @"http://mr1.doubanio.com/e06433b41b79c3dec3e31d8036cdfba5/0/fm/song/p1591096_64k.mp3"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UILabel *currentTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationTimeLabel;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet UILabel *miscLabel;
@property (nonatomic, strong) NSMutableArray * tracks;
@property (weak, nonatomic) IBOutlet SyjCircleSlider *volumeSlider;
@property (weak, nonatomic) IBOutlet SYJCustomSliderView *customSlider;
@property (nonatomic, assign) BOOL isDraging;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.playButton setTitle:@"播放" forState:UIControlStateNormal];
    [self.playButton setTitle:@"暂停" forState:UIControlStateSelected];
    
    self.currentTimeLabel.text = @"00:00";
    self.durationTimeLabel.text = @"00:00";
    
    self.tracks = [NSMutableArray array];
    Track * track = [[Track alloc]init];
    //本地
    track.audioFileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:localFile ofType:@"mp3" inDirectory:nil]];
    [self.tracks addObject:track];
    //网络
    Track * track1 = [[Track alloc]init];
    track1.audioFileURL = [NSURL URLWithString:netFile1];
    [self.tracks addObject:track1];
    Track * track2 = [[Track alloc]init];
    track2.audioFileURL = [NSURL URLWithString:netFile2];
    [self.tracks addObject:track2];
    [PlayerManager sharedPlayer].tracks = self.tracks;
    
    [self playControl];
    
    NSLog(@"~~~~~~~~~~~~%@",NSHomeDirectory());
    
    [self setVolume];//设置播放器音量
    
    [self setCustomSliderView]; //设置自定义滑块
    
    
}

//设置自定义滑块
- (void)setCustomSliderView {
    __weak typeof(self) weakSelf = self;
    self.customSlider.time = [NSString stringWithFormat:@"0/0"];
    self.customSlider.startDragSliderViewBolck = ^(float progress) {
        NSLog(@"开始拖动 %f",progress);
        weakSelf.isDraging = YES;
        //        [weakself removeProgressTimer];
    };
    self.customSlider.stopDragSliderViewBolck = ^(float progress) {
        NSLog(@"停止拖动 %f",progress);
        
        //        [weakself addProgressTimer];
        [PlayerManager sharedPlayer].currentTime = progress;
        weakSelf.isDraging = NO;
    };
}

//系统滑块
- (IBAction)sysSliderValueChanging:(id)sender {
    self.isDraging = YES;
}
- (IBAction)sysSliderDidStopChange:(id)sender {
    UISlider * slider = (UISlider *)sender;
    [PlayerManager sharedPlayer].currentTime = slider.value;
    self.isDraging = NO;
}


- (IBAction)play:(id)sender {
    UIButton * button = (UIButton *)sender;
    button.selected = !button.selected;
    if ([PlayerManager sharedPlayer].isPlaying) {
        [[PlayerManager sharedPlayer] pause];
    }else{
        // 本地播放
//        NSString *mp3 = [[NSBundle mainBundle] pathForResource:localFile ofType:@"mp3" inDirectory:nil];
//        [PlayerManager sharedPlayer].track.audioFileURL = [NSURL fileURLWithPath:mp3];
        // 流媒体
//        [PlayerManager sharedPlayer].track.audioFileURL = [NSURL URLWithString:netFile2];
        
        [[PlayerManager sharedPlayer] play];
    }

}


- (IBAction)stop:(id)sender {
    if ( ![PlayerManager sharedPlayer].isWorking ) return;
    [self finishPlayMusic];
}

- (IBAction)previous:(UIButton *)sender {
    [[PlayerManager sharedPlayer] previous];
}

- (IBAction)next:(UIButton *)sender {
    [[PlayerManager sharedPlayer] next];
}




- (void)playControl
{
    __weak typeof(self) weakSelf = self;
    
    if ([PlayerManager sharedPlayer].isPlaying) {
        self.playButton.selected = YES;
    }else{
        self.playButton.selected = NO;
    }
    
    [[PlayerManager sharedPlayer] setStatusBlock:^(DOUAudioStreamer * streamer) {
        switch ([streamer status]) {
            case DOUAudioStreamerPlaying:
                weakSelf.playButton.selected = YES;
                break;
                
            case DOUAudioStreamerPaused:
                weakSelf.playButton.selected = NO;
                break;
                
            case DOUAudioStreamerIdle:
                [weakSelf finishPlayMusic];
                break;
                
            case DOUAudioStreamerFinished:  //播放结束
                [weakSelf finishPlayMusic];
                break;
                
            case DOUAudioStreamerBuffering:
                
                break;
                
            case DOUAudioStreamerError:
                [weakSelf finishPlayMusic];
                break;
        }

    }];
    
    [[PlayerManager sharedPlayer]  setDurationBlock:^(DOUAudioStreamer *streamer) {
        if ([streamer duration] == 0.0) {
            if (!self.isDraging) {
                [weakSelf.slider setValue:0.0f animated:NO];
                weakSelf.customSlider.time = [NSString stringWithFormat:@"0/0"];
            }
            
        }
        else {
            weakSelf.currentTimeLabel.text = [NSString stringWithFormat:@"%@",[weakSelf stringWithTime:streamer.currentTime]];
            weakSelf.durationTimeLabel.text = [NSString stringWithFormat:@"%@",[weakSelf stringWithTime:streamer.duration]];
            
            if (!self.isDraging) {
                [weakSelf.slider setValue:[streamer currentTime] / [streamer duration] animated:YES];

                weakSelf.customSlider.time = [NSString stringWithFormat:@"%.0f/%.0f",[PlayerManager sharedPlayer].streamer.currentTime,[PlayerManager sharedPlayer].streamer.duration];
            }
            
        }
    }];
    
    // 流媒体下载进度
    [[PlayerManager sharedPlayer] setBufferingRatioBlock:^(DOUAudioStreamer * _streamer) {
        
        [weakSelf.miscLabel setText:[NSString stringWithFormat:@"Received %.2f/%.2f MB (%.2f %%), Speed %.2f MB/s", (double)[_streamer receivedLength] / 1024 / 1024, (double)[_streamer expectedLength] / 1024 / 1024, [_streamer bufferingRatio] * 100.0, (double)[_streamer downloadSpeed] / 1024 / 1024]];
        
        if ([_streamer bufferingRatio] >= 1.0) {
            NSLog(@"sha256: %@", [_streamer sha256]);
        }
    }];
}

- (void)finishPlayMusic{
    self.playButton.selected = NO;
    [self.slider setValue:0.0f animated:NO];
    [[PlayerManager sharedPlayer] stop];
    self.currentTimeLabel.text = @"00:00";
    self.customSlider.time = [NSString stringWithFormat:@"0/0"];
}

- (NSString *)stringWithTime:(NSTimeInterval)time
{
    // 分钟
    int minute = time / 60;
    // 秒
    int second = (int)time % 60;
    // 02:59
    return [NSString stringWithFormat:@"%02d:%02d",minute,second];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [[PlayerManager sharedPlayer] stop];
}


- (void)setVolume{
    self.volumeSlider.lineWidth = 2;
    self.volumeSlider.strokeColor = [UIColor blackColor];
    self.volumeSlider.backgroundCircleColor = [UIColor whiteColor];
    self.volumeSlider.value = 0.5;
    
    [PlayerManager sharedPlayer].streamer.volume = self.volumeSlider.value;
}


- (IBAction)changeVolume:(SyjCircleSlider *)sender {
    
    [PlayerManager sharedPlayer].streamer.volume = sender.value;
}


@end
