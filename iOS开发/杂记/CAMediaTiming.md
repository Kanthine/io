# CoreAnimation 的时间系统

无论是  `CALayer` 还是 `CAAnimation`， 都有一个时间线 `Timeline` 的概念！
* `CAMediaTiming` 协议设计了一个分层计时体系，每个对象描述了从对象的父时间值到本地时间的映射。

绝对时间 `Absolute time` 被定义为 `mach_absolute_time()` 转换为秒的时间；通过 `CACurrentMediaTime()` 查询当前的绝对时间！

从父时间到本地时间的转换有两个阶段:
* 转换为 `active local time` : 这包括对象在父时间轴上的出现点，以及它相对于父时间轴的运行速度；
* 从 `active local time` 转换为  "basic local time" : 计时模型允许对象多次重复其基本持续时间，并可选择在重复之前向后播放；
 
 
```
@protocol CAMediaTiming

/** 无论是 CALayer 还是 CAAnimation，都有一个时间线 Timeline 的概念
 * beginTime 是相对于父级对象的开始时间，默认情况下所有 CALayer 的时间线都是一致的, CALayer.beginTime 都是0
 *／
@property CFTimeInterval beginTime;

/** 当前 layer 相对于 superLayer 时间流的流逝速度，默认值是 1.0
 *  例如 (beginTime = 0 && speed = 2) 表示当前 layer 的时间流逝是 superLayer 的两倍, 这个动画的1秒处相当于父级对象时间流中的2秒处
 * 
 * speed 越大则说明时间流逝速度越快，那动画也就越快:
 *   比如 layer.speed = 2，其所有的 superLayer.speed = 1, 但 layer.subLayer.speed = 2
 *   那么一个 8 秒的动画，在这个 subLayer 上运行，只需 (8 / 2 / 2) = 2 秒
 * 所以 speed 有叠加的效果
 *／
@property float speed;

/* active local time 的额外偏移量。
 * 例如，将父时间tp转换为活动的本地时间t:  t = (tp - begin) * speed + offset
 * 它的一个重要用途是暂停 layer 的时间流速
 * 默认值为0。
 *
 * 将一个动画看作一个环，timeOffset 改变的其实是动画在环内的起点
 *    比如一个 duration=5 的动画，将 timeOffset 设置为 2；
 *    那么动画的运行则是从原来的2秒开始到5秒,接着再0秒到2秒,完成一次动画
 *／
@property CFTimeInterval timeOffset;

/// 对象的基本持续时间。默认值为 0
@property CFTimeInterval duration;

/// 对象的重复计数。默认值为 0
@property float repeatCount;

/// 对象的重复持续时间。默认值为 0
@property CFTimeInterval repeatDuration;

/// 默认为 NO；当为true时，倒退播放
@property BOOL autoreverses;

/// 决定当前对象过了非active时间段的行为
@property(copy) CAMediaTimingFillMode fillMode;

@end
```


## `FillMode`

`CAMediaTimingFillMode` 决定当前对象过了非active时间段的行为；比如动画开始之前、动画结束之后:
* 如果是一个动画 `CAAnimation`,则需要将其 `removedOnCompletion` 设置为 `NO`,要不然 `fillMode` 不起作用; 

```
typedef NSString * CAMediaTimingFillMode;

/// 当动画结束后,layer 会一直保持着动画最后的状态 
CA_EXTERN CAMediaTimingFillMode const kCAFillModeForwards;

/// 在动画开始前，只要将动画加入了一个 layer，layer 便立即进入动画的初始状态并等待动画开始
CA_EXTERN CAMediaTimingFillMode const kCAFillModeBackwards;

/// 动画加入后开始之前 layer 便处于动画初始状态；动画结束后 layer 保持动画最后的状态
CA_EXTERN CAMediaTimingFillMode const kCAFillModeBoth;

/// 默认值,也就是说当动画开始前和动画结束后,动画对layer都没有影响；动画结束后,layer 会恢复到之前的状态 
CA_EXTERN CAMediaTimingFillMode const kCAFillModeRemoved;
```

## 暂停当前 `CALayer` 的时间流速

将一个 `CALayer` 的时间流速设置为 0 后，如何确定它的相对时间（相对于系统时间钟）？
* 获取当前 `CALayer` 与当前时间种的相对时间；
* 标记它的时间偏移量；

这种操作相当于为该 `CALayer` 打了个标记，记录它的时间点！

```
- (void)pause {
    /// 首先设置当前 CALayer 的时间偏移量
    self.layer.timeOffset = [self.layer convertTime:CACurrentMediaTime() fromLayer:nil];
    /// 然后将时间流速设置为 0
    self.layer.speed = 0;
}

- (void)frameAnimation {
    /// 记录了时间偏移量 timeOffset 之后，当前的相对时间将保持不变
    /// 通过相对时间驱动的帧动画，将一直保持当前帧，画面不变，实现了暂停的效果
    CFTimeInterval timeInterval = [self.layer convertTime:CACurrentMediaTime() fromLayer:nil];
    
    /// 如果没有设置 timeOffset ，则 timeInterval 将取到 0，动画将显示异常
}

/// 恢复帧动画
- (void)resume {
    self.layer.speed = 1.0;
    //从superlayer的时间线获取时间，确保localTime对应到当前的位置
    self.layer.beginTime = [self.layer.superlayer convertTime:CACurrentMediaTime() fromLayer:nil];
}
```

