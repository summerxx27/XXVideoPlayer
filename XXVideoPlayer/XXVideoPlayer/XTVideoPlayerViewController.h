//
//  XTVideoPlayer.h
//  XTMoviePlayer
//
//  Created by zjwang on 16/10/18.
//  Copyright © 2016年 summerxx.com. All rights reserved.
//

#import <UIKit/UIKit.h>


@class AVPlayer;

typedef void(^dismissCompleteBlock)(void);

@interface XTVideoPlayerViewController : UIViewController
@property (nonatomic, copy) dismissCompleteBlock dismissCompleteBlock;
/**
 *      初始化方法
 *      frame           : 视频播放控件的大小
 *      playFromURL     : URL
 */
- (instancetype)initWithFrame:(CGRect)frame playFormURL:(NSURL *)playFormURL;
/**
 *      播放视频的方法
 */
- (void)xx_VideoPlay;
/**
 *      暂停视频的方法
 */
- (void)xx_VideoPause;
/**
 *      展示在KeyWindow
 */
- (void)xx_ShowInWindow;
@end
