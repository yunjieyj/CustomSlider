//
//  PlayerManager.h
//  CustomSlider
//
//  Created by Syj on 2019/6/3.
//  Copyright © 2019 Syj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DOUAudioStreamer.h"
//#import "DOUAudioVisualizer.h"
#import "DOUAudioFile.h"

@interface Track : NSObject <DOUAudioFile>

@property (nonatomic, strong) NSString *artist;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSURL *audioFileURL;

+ (NSArray *)remoteTracks;
+ (NSArray *)musicLibraryTracks;

@end

@interface PlayerManager : NSObject

+ (PlayerManager *)sharedPlayer;

@property (nonatomic, strong) Track * track;  
@property (nonatomic, copy) NSArray<Track *> * tracks; //音乐数组
@property (nonatomic, assign) NSInteger currentTrackIndex;//当前播放
@property (nonatomic, assign) float currentTime;  //当前时间

@property (nonatomic, strong) DOUAudioStreamer * streamer; //播放器

- (BOOL)isWorking; //是否在播放
- (BOOL)isPlaying; //暂停,闲置状态
- (BOOL)isTruePlaying; //正在播放状态
- (void)play; //播放
- (void)pause; //暂停
- (void)stop; //停止
- (void)previous; //前一首
- (void)next; //下一首

- (void)shake;

@property(nonatomic,copy) void(^statusBlock)(DOUAudioStreamer *streamer);
@property(nonatomic,copy) void(^durationBlock)(DOUAudioStreamer *streamer);
@property(nonatomic,copy) void(^bufferingRatioBlock)(DOUAudioStreamer *streamer);

@end
