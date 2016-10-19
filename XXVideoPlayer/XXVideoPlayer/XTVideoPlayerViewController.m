//
//  XTVideoPlayer.m
//  XTMoviePlayer
//
//  Created by zjwang on 16/10/18.
//  Copyright © 2016年 summerxx.com. All rights reserved.
//

#import "XTVideoPlayerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "XTVideoPlayerControlView.h"
#define xScreenWidth    [[UIScreen mainScreen] bounds].size.width;
#define xScreenHeight   [[UIScreen mainScreen] bounds].size.height;

static const CGFloat xVideoPlayerAnimationTimeInterval = 0.3f;


@interface XTVideoPlayerViewController ()
@property (nonatomic, strong) AVPlayer                  *avPlayer;
@property (nonatomic, strong) AVPlayerItem              *avPlayerItem;
@property (nonatomic, strong) XTVideoPlayerControlView  *xVideoPlayerView;
@property (nonatomic, strong) AVPlayerLayer             *playLayer;
@property (nonatomic, assign) BOOL                      isFullscreenMode;
@property (nonatomic, assign) CGRect                    originFrame;
@property (nonatomic, strong) NSTimer                   *timer;
@property (nonatomic, assign) AVPlayerItemStatus        avPlayerItemStatus;
@end

@implementation XTVideoPlayerViewController


- (instancetype)initWithFrame:(CGRect)frame playFormURL:(NSURL *)playFormURL
{
    self = [super init];
    if (self) {
        // 设置自定义View的frame
        self.view.backgroundColor = [UIColor blackColor];
        self.view.frame = frame;
        _avPlayerItem = [[AVPlayerItem alloc] initWithURL:playFormURL];
        self.avPlayer = [[AVPlayer alloc] initWithPlayerItem:_avPlayerItem];
        self.playLayer = [AVPlayerLayer playerLayerWithPlayer:self.avPlayer];
        [self.view.layer addSublayer:self.playLayer];
        self.playLayer.frame = self.view.frame;
        self.xVideoPlayerView.frame = self.view.frame;
        [self configClickEvents];
        [self.view addSubview:self.xVideoPlayerView];
        CGFloat duration = floor(CMTimeGetSeconds(self.avPlayerItem.asset.duration));
        // 设置最大最小值
        self.xVideoPlayerView.progressSlider.minimumValue = 0.f;
        self.xVideoPlayerView.progressSlider.maximumValue = floor(duration);
        
        // 默认值: 非全屏
        self.isFullscreenMode = NO;
        
        // 设置监听
        [self configObserver];
        
        //
        self.xVideoPlayerView.playButton.hidden = YES;
        self.xVideoPlayerView.pauseButton.hidden = NO;
        
    }
    return self;
}
- (XTVideoPlayerControlView *)xVideoPlayerView
{
    if (_xVideoPlayerView == nil) {
        _xVideoPlayerView = [[XTVideoPlayerControlView alloc] init];
    }
    return _xVideoPlayerView;
}

- (void)xx_VideoPlay
{
    [self.avPlayer play];
}

- (void)xx_VideoPause
{
    [self.avPlayer pause];
}

- (void)xx_ShowInWindow
{
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    if (keyWindow == nil) {
        keyWindow = [[UIApplication sharedApplication] windows].firstObject;
    }
    [keyWindow addSubview:self.view];
    
    self.view.alpha = 0.0;
    [UIView animateWithDuration:xVideoPlayerAnimationTimeInterval animations:^{
        self.view.alpha = 1.0;
    } completion:^(BOOL finished) {
        
    }];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
}

- (void)configClickEvents
{
    [self.xVideoPlayerView.playButton addTarget:self action:@selector(playButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.xVideoPlayerView.pauseButton addTarget:self action:@selector(pauseButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.xVideoPlayerView.closeButton addTarget:self action:@selector(closeButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.xVideoPlayerView.fullScreenButton addTarget:self action:@selector(fullScreenButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.xVideoPlayerView.shrinkScreenButton addTarget:self action:@selector(shrinkScreenButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self.xVideoPlayerView.progressSlider addTarget:self action:@selector(progressSliderTouchBegan:) forControlEvents:UIControlEventTouchDown];
    [self.xVideoPlayerView.progressSlider addTarget:self action:@selector(progressSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.xVideoPlayerView.progressSlider addTarget:self action:@selector(progressSliderTouchEnded:) forControlEvents:UIControlEventTouchUpInside];
    [self.xVideoPlayerView.progressSlider addTarget:self action:@selector(progressSliderTouchEnded:) forControlEvents:UIControlEventTouchUpOutside];
    
}

- (void)playButtonClick
{
    [self xx_VideoPlay];
    self.xVideoPlayerView.playButton.hidden = YES;
    self.xVideoPlayerView.pauseButton.hidden = NO;
}
- (void)pauseButtonClick
{
    [self xx_VideoPause];
    self.xVideoPlayerView.pauseButton.hidden = YES;
    self.xVideoPlayerView.playButton.hidden = NO;
}
- (void)progressSliderTouchBegan:(UISlider *)slider
{
    // 停止播放
    [self xx_VideoPause];
    [self stopDurationTimer];
    [self.xVideoPlayerView cancelAutoFadeOutControlBar];

}
- (void)progressSliderTouchEnded:(UISlider *)slider
{
    //    [self.avPlayer seekToTime:CMTimeMake(slider.value, 1)];
    [self.avPlayer seekToTime:CMTimeMakeWithSeconds(slider.value, self.avPlayerItem.currentTime.timescale)];
    [self.xVideoPlayerView autoFadeOutControlBar];
    [self stopDurationTimer];
    [self xx_VideoPlay];
    // 如果暂停按钮的隐藏属性是 NO, 那么调整按钮显隐性
    if (_xVideoPlayerView.playButton.hidden == NO) {
        _xVideoPlayerView.playButton.hidden = NO;
        _xVideoPlayerView.pauseButton.hidden = YES;
        [self xx_VideoPause];
    }
}
#pragma mark - slider Value Changed
- (void)progressSliderValueChanged:(UISlider *)slider
{
    [self xx_VideoPause];
    [self stopDurationTimer];
    double currentTime = floor(slider.value);
    double totalTime = floor(CMTimeGetSeconds(self.avPlayerItem.asset.duration));
    [self setTimeLabelValues:currentTime totalTime:totalTime];
}
- (void)setTimeLabelValues:(double)currentTime totalTime:(double)totalTime
{
    double minutesElapsed = floor(currentTime / 60.0);
    double secondsElapsed = fmod(currentTime, 60.0);
    NSString *timeElapsedString = [NSString stringWithFormat:@"%02.0f:%02.0f", minutesElapsed, secondsElapsed];
    
    double minutesRemaining = floor(totalTime / 60.0);;
    double secondsRemaining = floor(fmod(totalTime, 60.0));;
    NSString *timeRmainingString = [NSString stringWithFormat:@"%02.0f:%02.0f", minutesRemaining, secondsRemaining];
    
    self.xVideoPlayerView.timeLabel.text = [NSString stringWithFormat:@"%@/%@",timeElapsedString,timeRmainingString];
}
#pragma mark - slider value set
- (void)startDurationTimer
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(monitorVideoPlayback) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
}
- (void)monitorVideoPlayback
{
    // @field timescale The timescale of the CMTime. value/timescale = seconds.
    double currentTime = floor(self.avPlayerItem.currentTime.value / self.avPlayerItem.currentTime.timescale);
    double totalTime = CMTimeGetSeconds(self.avPlayerItem.asset.duration);
    [self setTimeLabelValues:currentTime totalTime:totalTime];
    self.xVideoPlayerView.progressSlider.value = currentTime;
}
- (void)stopDurationTimer
{
    [self.timer invalidate];
}
#pragma mark - 设置监听
- (void)configObserver
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inAVPlayerItemTimeJumpedNotification) name:AVPlayerItemTimeJumpedNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inAVPlayerItemDidPlayToEndTimeNotification) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
    // AVPlayerItemStatusReadyToPlay
    // KVO
    [self.avPlayerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
}
- (void)inAVPlayerItemTimeJumpedNotification
{
    [self startDurationTimer];
    [self.xVideoPlayerView.indicatorView stopAnimating];
    [self.xVideoPlayerView autoFadeOutControlBar];
}
- (void)inAVPlayerItemDidPlayToEndTimeNotification
{
    // 播放结束之后暂停
    [self xx_VideoPause];
}
- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSString*, id> *)change context:(nullable void *)context
{
    if ([keyPath isEqualToString:@"status"]) {
        switch (self.avPlayerItem.status) {
            case AVPlayerItemStatusReadyToPlay:
            {
                [self stopDurationTimer];
                [self.xVideoPlayerView.indicatorView startAnimating];
            }
                break;
            case AVPlayerItemStatusFailed:
            {
                [self.xVideoPlayerView.indicatorView startAnimating];
            }
            default:
                break;
        }
    }
}
#pragma mark - 关闭
- (void)closeButtonClick
{
    [self stopDurationTimer];
    [self xx_VideoPause];
    [UIView animateWithDuration:xVideoPlayerAnimationTimeInterval animations:^{
        self.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
        if (self.dismissCompleteBlock) {
            self.dismissCompleteBlock();
        }
    }];
    [UIApplication sharedApplication].statusBarHidden = NO;
}

#pragma mark - 全屏处理
- (void)fullScreenButtonClick
{
    if (self.isFullscreenMode) {
        return;
    }
    self.originFrame = self.view.frame;
    CGFloat height = [[UIScreen mainScreen] bounds].size.width;
    CGFloat width = [[UIScreen mainScreen] bounds].size.height;
    CGRect frame = CGRectMake((height - width) / 2, (width - height) / 2, width, height);;
    
    [UIView animateWithDuration:0.3f animations:^{
        self.frame = frame;
        self.playLayer.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        [self.view setTransform:CGAffineTransformMakeRotation(M_PI_2)];
    } completion:^(BOOL finished) {
        self.isFullscreenMode = YES;
        self.xVideoPlayerView.fullScreenButton.hidden = YES;
        self.xVideoPlayerView.shrinkScreenButton.hidden = NO;
    }];
}

- (void)shrinkScreenButtonClick
{
    if (!self.isFullscreenMode) {
        return;
    }
    [UIView animateWithDuration:0.3f animations:^{
        [self.view setTransform:CGAffineTransformIdentity];
        self.frame = self.originFrame;
        self.playLayer.frame = self.originFrame;
    } completion:^(BOOL finished) {
        self.isFullscreenMode = NO;
        self.xVideoPlayerView.fullScreenButton.hidden = NO;
        self.xVideoPlayerView.shrinkScreenButton.hidden = YES;
    }];
}
- (void)setFrame:(CGRect)frame
{
    [self.view setFrame:frame];
    [self.xVideoPlayerView setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    [self.xVideoPlayerView setNeedsLayout];
    [self.xVideoPlayerView layoutIfNeeded];
}
@end
