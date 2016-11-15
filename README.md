## XXVideoPlayer

> 有一个月没写博客了, 今天分享一篇关于多媒体的文章, 平时我多分享一些UI方面的零散知识, 这种一般好理解, 让人愿意学习, 看完能够实现某些效果, 今天也是本着这个目的, 今天通过简单封装一个视频播放器, 来学一些AVPlayer相关的一些知识 
[播放器地址https://github.com/summerxx27/XXVideoPlayer](https://github.com/summerxx27/XXVideoPlayer)

![](http://upload-images.jianshu.io/upload_images/1506501-33d3a8d4bca5165a.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

> - 编译环境 Xcode 8
- AVPlayer相关
- AVPlayerItem
- 支持多种视频格式
- 完成了 快进 快退 暂停 播放 全屏等视频播放器的基础功能
- 后期会添加更加丰富的内容, 还可能写一个Swift版本的

```objectivec
_avPlayerItem = [[AVPlayerItem alloc] initWithURL:playFormURL];

```
```objectivec
// 通过AVPlayerItem创建一个AVPlayer对象
self.avPlayer = [[AVPlayer alloc] initWithPlayerItem:_avPlayerItem];
```

```objectivec
// 创建 AVPlayerLayer
self.playLayer = [AVPlayerLayer playerLayerWithPlayer:self.avPlayer];
```

```objectivec
// 添加到要显示视频的View
[self.view.layer addSublayer:self.playLayer];
```
```objectivec
// 播放 | 暂停
- (void)xx_VideoPlay
{
[self.avPlayer play];
}
- (void)xx_VideoPause
{
[self.avPlayer pause];
}
```
```objectivec
// 快进处理 slider 就是滑动条.
[self.avPlayer seekToTime:CMTimeMakeWithSeconds(slider.value, self.avPlayerItem.currentTime.timescale)];
```
```objectivec
// 获取总的播放时间 self.avPlayerItem(当前播放AVPlayerItem的对象)
CMTimeGetSeconds(self.avPlayerItem.asset.duration)
```
```objectivec
// 观察AVPlayerItem的播放状态
AVF_EXPORT NSString *const AVPlayerItemTimeJumpedNotification			 NS_AVAILABLE(10_7, 5_0);	// the item's current time has changed discontinuously
AVF_EXPORT NSString *const AVPlayerItemDidPlayToEndTimeNotification      NS_AVAILABLE(10_7, 4_0);   // item has played to its end time
AVF_EXPORT NSString *const AVPlayerItemFailedToPlayToEndTimeNotification NS_AVAILABLE(10_7, 4_3);   // item has failed to play to its end time
AVF_EXPORT NSString *const AVPlayerItemPlaybackStalledNotification       NS_AVAILABLE(10_9, 6_0);    // media did not arrive in time to continue playback
AVF_EXPORT NSString *const AVPlayerItemNewAccessLogEntryNotification	 NS_AVAILABLE(10_9, 6_0);	// a new access log entry has been added
AVF_EXPORT NSString *const AVPlayerItemNewErrorLogEntryNotification		 NS_AVAILABLE(10_9, 6_0);	// a new error log entry has been added

// notification userInfo key                                                                    type
AVF_EXPORT NSString *const AVPlayerItemFailedToPlayToEndTimeErrorKey     NS_AVAILABLE(10_7, 4_3);   // NSError
```
```objectivec
// 旋转方法 之后 调整frame
[self.view setTransform:CGAffineTransformMakeRotation(M_PI_2)];
// 取消全屏
[self.view setTransform:CGAffineTransformIdentity];
```
```objectivec
// 隐藏状态栏的相关方法
[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
// 同时需要在info.plist文件中进行配置
// View controller-based status bar appearance = NO
```
>以上就是对于视频播放器封装用到的知识点了~
第一次学习AVPlayer 难免出现错误的地方, 请告知我, 这样我就能及时修正了
感谢 [36Kr](https://github.com/36Kr-Mobile) 的开源, 让我能够学习相关的知识点

不同的是 36Kr使用MPMoviePlayerController, 而我使用AVPlayer, UI方面我直接使用了他提供的UI方便快速, 当然可以随意修改, 简单方便.

最后感谢您的阅读, 如果感觉有帮助可以关注我 和我一起学习! 

> 我是夏天, 暖暖的夏天
End

#### 可以关注我的订阅号 [夏天然后 ID: xt1005430006] 
![夏天然后](http://upload-images.jianshu.io/upload_images/1506501-698707adeaa60425.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
