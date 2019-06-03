//
//  PlayerManager.m
//  CustomSlider
//
//  Created by Syj on 2019/6/3.
//  Copyright © 2019 Syj. All rights reserved.
//

#import "PlayerManager.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

static void *kStatusKVOKey = &kStatusKVOKey;
static void *kDurationKVOKey = &kDurationKVOKey;
static void *kBufferingRatioKVOKey = &kBufferingRatioKVOKey;




@implementation Track

+ (void)load
{
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
//        [self remoteTracks];
//    });
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
//        [self musicLibraryTracks];
//    });
}

//+ (NSArray *)remoteTracks
//{
//    static NSArray *tracks = nil;
//    
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://douban.fm/j/mine/playlist?type=n&channel=1004693&from=mainsite"]];
//        NSData *data = [NSURLConnection sendSynchronousRequest:request
//                                             returningResponse:NULL
//                                                         error:NULL];
//        NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[string dataUsingEncoding:NSUTF8StringEncoding] options:0 error:NULL];
//        
//        NSMutableArray *allTracks = [NSMutableArray array];
//        for (NSDictionary *song in [dict objectForKey:@"song"]) {
//            Track *track = [[Track alloc] init];
//            [track setArtist:[song objectForKey:@"artist"]];
//            [track setTitle:[song objectForKey:@"title"]];
//            [track setAudioFileURL:[NSURL URLWithString:[song objectForKey:@"url"]]];
//            [allTracks addObject:track];
//        }
//        
//        tracks = [allTracks copy];
//    });
//    
//    return tracks;
//}


+ (NSArray *)musicLibraryTracks
{
    static NSArray * tracks = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableArray *allTracks = [NSMutableArray array];
        for (MPMediaItem *item in [[MPMediaQuery songsQuery] items]) {
            if ([[item valueForProperty:MPMediaItemPropertyIsCloudItem] boolValue]) {
                continue;
            }
            
            Track *track = [[Track alloc] init];
            [track setArtist:[item valueForProperty:MPMediaItemPropertyArtist]];
            [track setTitle:[item valueForProperty:MPMediaItemPropertyTitle]];
            [track setAudioFileURL:[item valueForProperty:MPMediaItemPropertyAssetURL]];
            [allTracks addObject:track];
        }
        
        for (NSUInteger i = 0; i < [allTracks count]; ++i) {
            NSUInteger j = arc4random_uniform((u_int32_t)[allTracks count]);
            [allTracks exchangeObjectAtIndex:i withObjectAtIndex:j];
        }
        
        tracks = [allTracks copy];
    });
    
    return tracks;
}
@end

/**************************¬∆∆∆˙µ≤∫ø**************************************¬¬¬∆∆∆˙µ≤∫øπ********/

@interface PlayerManager()
{
//    DOUAudioVisualizer *_audioVisualizer;
    BOOL needPlay;
}

@property (nonatomic, strong) NSTimer * timer;


@end


@implementation PlayerManager

#pragma mark - Singleton
+ (PlayerManager *)sharedPlayer
{
    static PlayerManager *sharedPlayer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedPlayer = [[super allocWithZone:nil] init];
    });
    return sharedPlayer;
}

+ (id)alloc
{
    return [PlayerManager sharedPlayer];
}

+ (id)allocWithZone:(struct _NSZone *)zone
{
    return [PlayerManager sharedPlayer];
}

- (id)init
{
    self = [super init];
    if (self) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(audioSessionWasInterrupted:)
                                                     name:AVAudioSessionInterruptionNotification
                                                   object:nil];
    }
    return self;
}

#pragma mark -  DOUStreamer
- (void)_cancelStreamer {
    if (self.streamer != nil) {
        [self.streamer pause];
        [self.streamer removeObserver:self forKeyPath:@"status"];
        [self.streamer removeObserver:self forKeyPath:@"duration"];
        [self.streamer removeObserver:self forKeyPath:@"bufferingRatio"];
        self.streamer = nil;
    }
}

- (void)_resetStreamer {
    [self _cancelStreamer];
    
    Track * track = [self.tracks objectAtIndex:self.currentTrackIndex];
    self.streamer = [DOUAudioStreamer streamerWithAudioFile:track];
    
    [self.streamer addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:kStatusKVOKey];
    [self.streamer addObserver:self forKeyPath:@"duration" options:NSKeyValueObservingOptionNew context:kDurationKVOKey];
    [self.streamer addObserver:self forKeyPath:@"bufferingRatio" options:NSKeyValueObservingOptionNew context:kBufferingRatioKVOKey];
    
    [self.streamer play];
//    [self _setupHintForStreamer];
    self.timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(_timerAction:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == kStatusKVOKey) {
        [self performSelector:@selector(_updateStatus)
                     onThread:[NSThread mainThread]
                   withObject:nil
                waitUntilDone:NO];
    }
    else if (context == kDurationKVOKey) {
        [self performSelector:@selector(_timerAction:)
                     onThread:[NSThread mainThread]
                   withObject:nil
                waitUntilDone:NO];
    }
    else if (context == kBufferingRatioKVOKey) {
        [self performSelector:@selector(_updateBufferingStatus)
                     onThread:[NSThread mainThread]
                   withObject:nil
                waitUntilDone:NO];
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)_updateStatus {
    if (self.statusBlock) {
        self.statusBlock(_streamer);
    }
}

- (void)_timerAction:(id)timer {
    if (self.durationBlock) {
        self.durationBlock(_streamer);
    }
}

- (void)_updateBufferingStatus {
    if (self.bufferingRatioBlock) {
        self.bufferingRatioBlock(_streamer);
    }
}

- (BOOL)isWorking{
    if (!self.streamer) return NO;
    return (([self.streamer status] == DOUAudioStreamerPaused) ||
            ([self.streamer status] == DOUAudioStreamerPlaying) ||
            ([self.streamer status] == DOUAudioStreamerBuffering));
}

- (BOOL)isPlaying{
    if (!_streamer) return NO;
    return !(([self.streamer status] == DOUAudioStreamerPaused) || ([self.streamer status] == DOUAudioStreamerIdle));
}

- (BOOL)isTruePlaying{
    if (!_streamer) return NO;
    return [self.streamer status] == DOUAudioStreamerPlaying;
}


- (void)play{
    if ([self.streamer status] == DOUAudioStreamerPaused) {
        [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(_timerAction:) userInfo:nil repeats:YES];
        [self.streamer play];
    }
    else{
        [self _resetStreamer];
    }
}

-(void)pause{
    [self.streamer pause];
}

- (void)stop{
    [_timer invalidate];
    [self.streamer stop];
    [self _cancelStreamer];
}

- (void)previous
{
    if (--self.currentTrackIndex <= -1 ) {
        self.currentTrackIndex = self.tracks.count - 1;
    }
    [self _resetStreamer];
}


- (void)next
{
    if (++self.currentTrackIndex >= [self.tracks count]) {
        self.currentTrackIndex = 0;
    }
    [self _resetStreamer];
}


- (void)_setupHintForStreamer
{
    NSUInteger nextIndex = self.currentTrackIndex + 1;
    if (nextIndex >= [self.tracks count]) {
        nextIndex = 0;
    }
    [DOUAudioStreamer setHintWithAudioFile:[self.tracks objectAtIndex:nextIndex]];
}

- (float)currentTime{
    return self.streamer.currentTime / self.streamer.duration;
}

- (void)setCurrentTime:(float)currentTime{
    [self.streamer setCurrentTime:self.streamer.duration * currentTime];
}

- (void)shake{
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

- (void)audioSessionWasInterrupted:(NSNotification *)notification
{
    if ([notification.userInfo count] == 0){
        return;
    }
    if (AVAudioSessionInterruptionTypeBegan == [notification.userInfo[AVAudioSessionInterruptionTypeKey] intValue]) {
        if (self.isTruePlaying) {
            [self pause];
            needPlay =YES;
        }
    }
    
    if (AVAudioSessionInterruptionTypeEnded == [notification.userInfo[AVAudioSessionInterruptionTypeKey] intValue]) {
        if (needPlay) {
            [self play];
            needPlay =NO;
        }
    }
}

@end
