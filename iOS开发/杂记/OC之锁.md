# 

######前言：多线程下的 _数据竞争_ 问题

使用并发编程以更高效率处理任务的同时，也带来了一些问题：如对共享内存的读写操作。程序中多个线程的执行顺序是不确定的，不同的执行顺序执行同一段代码得到不同的结果，这会导致并发程序中的bug难以检测和修复。
__例子：__多次执行该段代码，得到的打印数据可能不同，最终结果也不符合预计！

```
dispatch_queue_t queue = dispatch_queue_create("com.demo.task", DISPATCH_QUEUE_CONCURRENT);
 __block int length = 0;
 dispatch_apply(6, queue, ^(size_t index) {
     dispatch_async(queue, ^{
         NSLog(@"length === %d -- %@",++length,NSThread.currentThread);
         [NSThread sleepForTimeInterval:2];//模拟耗时任务
         NSLog(@"length --- %d == %@",--length,NSThread.currentThread);
     });
 });
```

多条线程同时访问一个变量，至少一条线程修改该变量，这种情况就叫__竞态__ 。开启 Xcode 线程竞态检测工具 `Thread Sanitizer` 可以检测出这类问题：

![Data race WARNING](https://upload-images.jianshu.io/upload_images/7112462-2934d7f63035f00d.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

iOS 使用同步机制解决多线程下的竞态，如 __锁__ 或者 __条件__。条件：使线程处于休眠状态，满足条件唤醒休眠的线程，条件变量通常用锁来实现。锁实行互斥策略，避免共享数据被多个线程同时访问；使用不当可能引发死锁、活锁、资源匮乏等问题，导致程序中断：

* 死锁：多个线程互相阻塞，每个线程都等待其他线程释放锁，导致所有线程都处于等待状态。如 GCD 的 `dispatch_sync()` 函数使用不当，容易造成队列的循环等待。
* 活锁：任务或者线程没有被阻塞，由于某些条件没有满足，导致一直重复尝试、失败，尝试、失败…如 `NSConditionLock` 的条件无法得到满足。
* 资源匮乏：一些线程占用共享资源的时间过长，导致其它线程无法正常访问该资源。活锁也是资源匮乏的一种形式。


####1、互斥锁

互斥锁通过将代码切片成一个个临界区，防止多条线程同时对某个资源进行读写。

#####1.1、`@synchronized` 锁
[@synchronized](http://rykap.com/objective-c/2015/05/09/synchronized/) 发挥了和锁一样的作用：它避免了多个线程同时执行同一段代码。对比`NSLock`创建锁、加锁、解锁，在某些情况下`@synchronized` 会更方便、更易读。


```
- (void)synchronizedMethod{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"taskA_1 --- %@",NSThread.currentThread);
        NSLog(@"taskA_2 === %@",[self getTheString]);
        NSLog(@"taskA_3 --- %@",NSThread.currentThread);
    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"taskB_1 --- %@",NSThread.currentThread);
        NSLog(@"taskB_2 === %@",[self getTheString]);
        NSLog(@"taskB_3 --- %@",NSThread.currentThread);
    });
}

- (NSString *)getTheString{
    @synchronized (self){
        NSLog(@"currentThread == %@",NSThread.currentThread);
        [NSThread sleepForTimeInterval:2];
        return @"*****************************";
    }
}

/* 打印数据：
10:23:26 taskB_1 --- <NSThread: 0x7b1000056800>{number = 5, name = (null)}
10:23:26 taskA_1 --- <NSThread: 0x7b1000053f80>{number = 4, name = (null)}
10:23:26 currentThread == <NSThread: 0x7b1000053f80>{number = 4, name = (null)}
10:23:28 taskA_2 === *****************************
10:23:28 currentThread == <NSThread: 0x7b1000056800>{number = 5, name = (null)}
10:23:28 taskA_3 --- <NSThread: 0x7b1000053f80>{number = 4, name = (null)}
10:23:30 taskB_2 === *****************************
10:23:30 taskB_3 --- <NSThread: 0x7b1000056800>{number = 5, name = (null)}
 */
```

#####1.2、`NSLock` 锁

Cocoa 的 [NSLock](https://developer.apple.com/documentation/foundation/nslock?changes=latest_minor&language=objc) 是最基本的锁，使用 `POSIX` 线程实现其功能。

```
//锁的通用协议
@protocol NSLocking

/* 加锁操作，此时如果已经在其它线程上锁，则此操作会堵塞当前线程，等待其它线程解锁；
 *         如果没有在其它线程上锁，则立即上锁，并向下执行。
 * @note 死锁：同一条线程，如果多次上同一把锁，会堵塞线程导致无法解锁，造成线程死锁。
 *           除非使用递归锁：NSRecursiveLock
 */
- (void)lock;
/* 解锁操作
 */
- (void)unlock;
@end

//NSLock在内部封装了一个 pthread_mutex，属性为 PTHREAD_MUTEX_ERRORCHECK。
@interface NSLock : NSObject <NSLocking> 
/* 试图加锁，不会阻塞线程；无论能否加锁，都立即执行后续代码
 * @return 加锁成功返回 YES；
 *         NSLock 对象在其它线程被锁定，该操作失败，则返回 NO
 */
- (BOOL)tryLock; 

/* 堵塞当前线程，在截止时间内一直尝试上锁
 * @param limit 截止时间
 * @return 在截止时间内成功加锁，返回 YES
 *         到截止时间，依旧被其它线程锁定，返回 NO
 */
- (BOOL)lockBeforeDate:(NSDate *)limit;
@property (nullable, copy) NSString *name;
@end
```

#####1.3、`pthread_mutex_t`

`pthread_mutex_t` 是为`Unix/Linux` 平台提供的一套锁：除了实现互斥锁，还可以创建递归锁、读写锁、条件锁等。

```
/* 类似于 NSLocking 的 -lock 方法
 * 加锁操作，此时如果 pthread_mutex_t 已经上锁，则堵塞当前线程，等待解锁，
 *         如果 pthread_mutex_t 没有上锁，则立即上锁，并向下执行
 */
int pthread_mutex_lock(pthread_mutex_t *);

/* 类似于 NSLock 的 -tryLock 方法
 * 试图加锁，不会阻塞线程；无论能否加锁，都立即执行后续代码
 * @return 如果 pthread_mutex_t 被其它线程上锁，或者已经被释放，加锁失败，返回非 0 值：
 *        加锁成功返回 0
 */
int pthread_mutex_trylock(pthread_mutex_t *);

/* 解锁
 */
int pthread_mutex_unlock(pthread_mutex_t *);

/* 释放锁
 * @note  pthread_mutex 由 C 函数创建，编译器不负责释放，需要程序员在合适的时机释放
 */
int pthread_mutex_destroy(pthread_mutex_t *);
```

__例子：__引入头文件` #include<pthread.h>`，利用`pthread_mutex_t`实现一个互斥锁：


```
- (void)pthread_mutex_LockMethod{
    dispatch_group_t group = dispatch_group_create();
    //静态创建一个互斥锁
    __block pthread_mutex_t pthreadLock = PTHREAD_MUTEX_INITIALIZER;
    __block int length = 0;
    
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        pthread_mutex_lock(&pthreadLock);
        length ++;
        [NSThread sleepForTimeInterval:2];
        pthread_mutex_unlock(&pthreadLock);
    });
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (pthread_mutex_trylock(&pthreadLock) == 0){
            [NSThread sleepForTimeInterval:2];
            pthread_mutex_unlock(&pthreadLock);
        }else{
            NSLog(@"加锁失败 %@",NSThread.currentThread);
        }
    });

    //使用 dispatch_group 监听任务全部完成后手动释放 pthread_mutex
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        pthread_mutex_destroy(&pthreadLock);
    });
}
```

使用互斥锁需要注意的几点：
* 互斥锁的加锁和解锁操作要消耗时间。因此互斥锁够用即可，每个互斥锁保护的区域尽量大。
* 互斥锁本质是串行。如果多条线程频繁使用同一互斥锁，则线程的大部分时间就会在等待，这对性能是有害的。如果互斥锁保护的数据包含彼此无关的片段，将这些片段拆分到不同的互斥锁保护。这样，任意时刻等待互斥锁的线程减少，线程等待时间减少。所以，互斥锁应该足够多(到有意义的地步)，每个互斥锁保护的区域则应尽量的少。

####2、 递归锁

> Warning : You should not use this class to implement a recursive lock. Calling the lock method twice on the same thread will lock up your thread permanently. Use the NSRecursiveLock class to implement recursive locks instead.

官方文档警告：在递归中建议使用`NSRecursiveLock`，使用 `NSLock` 造成递归死锁。

递归锁在同一个线程可以重复上锁，不会导致死锁。

#####2.1、递归锁 `NSRecursiveLock`

使用 `NSRecursiveLock` 处理递归代码：

```
- (void)recursiveLockMethod{
    NSMutableArray *array = [NSMutableArray array];
    NSRecursiveLock *recursiveLock = [[NSRecursiveLock alloc] init];
    static void (^recursiveTestBlock)(int length);
    recursiveTestBlock = ^(int length){
        NSLog(@"开始加锁 === length ：%d -- %@",length,NSThread.currentThread);
        [recursiveLock lock];
        if (length > 0){
            [array addObject:@(length)];
            [NSThread sleepForTimeInterval:2];//模拟耗时任务
            recursiveTestBlock(--length);
        }
        [recursiveLock unlock];
        NSLog(@"已经解锁 --- length ：%d == %@",length,NSThread.currentThread);
    };
    
    [NSThread detachNewThreadWithBlock:^{
        recursiveTestBlock(3);
    }];

    [NSThread detachNewThreadWithBlock:^{
        [recursiveLock lock];
        NSLog(@"array ------ %@",array);
        [recursiveLock unlock];
    }];
}

/* 打印数据：
11:54:38 开始加锁 === length ：3 -- <NSThread: 0x7b100007c000>{number = 7, name = (null)}
11:54:40 开始加锁 === length ：2 -- <NSThread: 0x7b100007c000>{number = 7, name = (null)}
11:54:42 开始加锁 === length ：1 -- <NSThread: 0x7b100007c000>{number = 7, name = (null)}
11:54:44 开始加锁 === length ：0 -- <NSThread: 0x7b100007c000>{number = 7, name = (null)}
11:54:44 已经解锁 --- length ：0 == <NSThread: 0x7b100007c000>{number = 7, name = (null)}
11:54:44 已经解锁 --- length ：0 == <NSThread: 0x7b100007c000>{number = 7, name = (null)}
11:54:44 已经解锁 --- length ：1 == <NSThread: 0x7b100007c000>{number = 7, name = (null)}
11:54:44 已经解锁 --- length ：2 == <NSThread: 0x7b100007c000>{number = 7, name = (null)}
11:54:44 array ------ (3,2,1)
 */
```

在一条线程中任务是按顺序执行的，不存在资源竞争问题；可以使用`NSRecursiveLock` 在一条线程中重复加锁。`NSRecursiveLock`会记录上锁和解锁的次数，当二者平衡时才会释放锁，__其它线程才能获取该锁__。

#####2.3、`pthread_mutex_t` 实现递归锁


#####2.3.1、互斥锁属性`pthread_mutexattr_t` 

```
//互斥锁属性
typedef __darwin_pthread_mutexattr_t pthread_mutexattr_t;
 
 /* 互斥锁属性的初始化
 * 该结构体的属性都是默认值；需要调用不同的函数设置其属性 
 */
 int pthread_mutexattr_init(pthread_mutexattr_t *)

/* 销毁互斥锁属性
 */
int pthread_mutexattr_destroy(pthread_mutexattr_t *)

/* 设置互斥锁的类型
 * @return 如果设置成功，返回 0 ；否则返回错误码。
 */
int pthread_mutexattr_settype(pthread_mutexattr_t *, int)

/*  获取互斥锁的类型
 * @return 如果获取成功，返回 0 ；否则返回错误码。
*/
int pthread_mutexattr_gettype(const pthread_mutexattr_t * __restrict,int * __restrict)
```

互斥锁 `pthread_mutex_t` 的几种类型：
* `PTHREAD_PROCESS_SHARED`： 跨进程共享；
  每个进程的地址空间是独立的，位于一个进程的普通内存区域中的对象是无法被其它进程所访问的；
    能满足这一要求的内存区域是共享内存，因而互斥锁要在进程的共享内存区域内创建。
* `PTHREAD_PROCESS_PRIVATE` ： 进程私有
* `PTHREAD_MUTEX_TIMED_NP` 普通锁，保证了资源分配的公平性；
    当一个线程加锁以后，其余请求锁的线程将形成一个等待队列，并在解锁后按优先级获得锁。
    解锁一个由别的线程锁定的互斥锁将会返回一个错误代码。
    解锁已经被解锁的互斥锁也将会返回一个错误代码。
* `PTHREAD_MUTEX_NORMAL` 与 `PTHREAD_MUTEX_DEFAULT` ：不会自动检测死锁，不会返回错误代码，避免使用
* `PTHREAD_MUTEX_ADAPTIVE_NP` ： 适应锁，仅等待解锁后重新竞争
* `PTHREAD_MUTEX_ERRORCHECK` 与 `PTHREAD_MUTEX_ERRORCHECK_NP` ：检错锁：自动检测死锁。
如果一个线程试图对一个互斥锁重复锁定，返回 `EDEADLK`，保证多次加锁时不会出现最简单情况下的死锁。
* `PTHREAD_MUTEX_RECURSIVE` 与 `PTHREAD_MUTEX_RECURSIVE_NP` ：递归锁： 在一个线程重复上锁，不会引起死锁；进程私有；
    一个线程对递归锁重复上锁必须由这个线程来重复相同数量的解锁，这样才能解开这个互斥锁，_然后_ 别的线程才能得到这个互斥锁。



__例子：__利用`pthread_mutex_t`实现递归锁的效果 与 `NSRecursiveLock`一样：

```
- (void)pthread_mutex_RecursiveLockMethod{
    __block pthread_mutex_t pthreadLock;
    pthread_mutexattr_t pthreadMutexattr;
    pthread_mutexattr_init(&pthreadMutexattr);//锁属性的初始化
    pthread_mutexattr_settype(&pthreadMutexattr, PTHREAD_MUTEX_RECURSIVE);//设置为递归锁
    pthread_mutex_init(&pthreadLock, &pthreadMutexattr);//锁的初始化
    
    static void (^recursiveTestBlock)(int length);
    recursiveTestBlock = ^(int length){
        NSLog(@"开始加锁 === length ：%d -- %@",length,NSThread.currentThread);
        pthread_mutex_lock(&pthreadLock);//上锁
        if (length > 0){
            [NSThread sleepForTimeInterval:2];
            recursiveTestBlock(--length);
        }
        pthread_mutex_unlock(&pthreadLock);//解锁
        NSLog(@"已经解锁 --- length ：%d == %@",length,NSThread.currentThread);
    };
    [NSThread detachNewThreadWithBlock:^{
        recursiveTestBlock(3);
    }];
}
```

####3、条件锁

条件锁：当某些条件不满足时线程进入休眠；满足条件时，唤醒休眠线程继续执行。

#####3.1、条件锁 `NSConditionLock` 

[NSConditionLock ](https://developer.apple.com/documentation/foundation/nsconditionlock?changes=latest_minor&language=objc) 确保只有满足特定条件时，线程才能获取该锁。

```
//实现 NSLocking 协议
@interface NSConditionLock : NSObject <NSLocking>

/* 初始化条件锁
* @param condition 加锁满足的条件
*/
- (instancetype)initWithCondition:(NSInteger)condition;

// 获取当前的条件
@property (readonly) NSInteger condition;

/* 试图加锁，不会阻塞当前线程的执行。
 * @param condition 加锁满足的条件
 *        满足该条件，且没有在其它线程加锁，才能加锁成功
 * @return 加锁成功返回 YES，否则返回 NO
 */
- (BOOL)tryLock;
- (BOOL)tryLockWhenCondition:(NSInteger)condition;

/* 加锁操作，阻塞当前线程
* @param condition 加锁满足的条件
*        满足该条件，且没有在其它线程加锁，则加锁成功，程序向下执行；
*        如果不满足该条件，或者在其它线程上锁，则堵塞线程，一直等待
*/
- (void)lockWhenCondition:(NSInteger)condition;

/* 加锁操作，会堵塞当前线程
* @param limit 加锁的截止时间
*        在截止时间之前，堵塞当前线程，一直尝试加锁。
* @return 加锁成功返回 YES ，否则返回 NO
*/
- (BOOL)lockBeforeDate:(NSDate *)limit;

/* 加锁操作，会堵塞当前线程
 * @param condition 加锁满足的条件，
 * @param limit 加锁的截止时间
 * @note 在截止时间 limit 之前，堵塞当前线程，一直尝试加锁。
 *       如果满足条件，并且没有在其它线程上锁，则加锁成功，立即返回 YES；
 *                  在其它线程上锁，超过截止时间，则加锁失败，返回 NO；
 *       如果不满足条件，在到达截止时间之前，会一直尝试，等待可能变化的条件；
 *                    在到达截止时间也不满足，则加锁失败，返回 NO；
 * @return 加锁成功返回 YES ，否则返回 NO
 */
- (BOOL)lockWhenCondition:(NSInteger)condition beforeDate:(NSDate *)limit;

/* 解锁操作
 * @param condition 重置锁的条件
 */
- (void)unlockWithCondition:(NSInteger)condition;
@end
```

#####3.2、条件锁 `NSCondition` 

 [NSCondition](https://developer.apple.com/documentation/foundation/nscondition?changes=latest_minor&language=objc) 实现了一个线程等待信号而休眠时，可以被另外一个线程唤醒的功能。其对象实现了锁和线程检查器的功能：
* 锁：保护共享数据； 
* 线程检查器：判断线程是否休眠，收到信号唤醒休眠线程。

```
//实现 NSLocking 协议
@interface NSCondition : NSObject <NSLocking> 

/* 使线程处于休眠状态，只有收到信号，才会唤醒线程
 * @note 一条线程处于休眠，则之前 -lock 操作的锁也被休眠，
 *        只有该条线程再次活跃，加锁才有效；
 */
- (void)wait;

/* 使线程处于休眠状态
 * @param limit 休眠的截止时间
 *    如果在截止时间之前收到了信号就唤醒线程，返回 YES
 *    如果到了截止时间也没收到信号，也会唤醒线程，返回 NO
 */
- (BOOL)waitUntilDate:(NSDate *)limit;

/* 发送一个信号量，唤醒一个休眠线程
 * 唤醒多条线程就得多次调用；如果没有线程休眠，则这个方法不起作用；
 */
- (void)signal;

/* 唤醒所有休眠线程
 * @note 如果这些线程在休眠之前 -lock， 在收到广播之后并非同时唤醒的；
 *     按先后顺序，一条条线程依次唤醒并解锁
 */
- (void)broadcast;
@end
```


#####3.3、利用`pthread_mutex_t`实现条件锁

条件变量 `pthread_cond_t` 包括两个动作：一条线程因_条件变量不满足_ 而休眠；另一条线程使_条件成立_ 发出信号唤醒休眠线程。为了防止竞争，条件变量总和互斥锁结合使用。

```
/* 初始化一个条件变量
 * @note 可以直接静态创建一个条件变量： PTHREAD_COND_INITIALIZER
 * @return 初始化成功，返回 0； 否则返回非 0
 */
int pthread_cond_init(pthread_cond_t* cond, pthread_condattr_t *cond_attr);

/* 销毁一个条件变量
 * @return 销毁成功，返回 0； 否则返回非 0
 */
int pthread_cond_destroy(pthread_cond_t* cond);

/* 休眠当前线程
 * @param pthread_cond_t  条件变量
 * @param pthread_mutex_t 互斥锁
 * @return 收到信号，返回 0 ，唤醒线程继续执行
 * @note 该函数唤醒休眠线程后，并不意味满足下述执行的条件，必须重新检查条件；最好的测试方法是循环调用：
 *     while (条件){
 *          pthread_cond_wait(&pthreadCondition, &condMutexLock);
 *     }
 *     // 和条件关联的某些代码
 */
int pthread_cond_wait(pthread_cond_t * __restrict,pthread_mutex_t * __restrict);

/* 休眠当前线程到截止时间
 * @param pthread_cond_t  条件变量
 * @param pthread_mutex_t 互斥锁
 * @param timespec 截止时间
 * @return 如果在截止时间内收到信号，返回 0 ，唤醒线程继续执行；
 *         如果到截止时间还没有信号，返回 ETIMEOUT ，唤醒线程继续执行；
 */
int pthread_cond_timedwait(pthread_cond_t * __restrict, pthread_mutex_t * __restrict,const struct timespec * _Nullable __restrict)

/* 发送一个信号，唤醒一条处于休眠的线程；
 * @note 存在多条休眠线程时按入队顺序唤醒其中一条
 * @return 发送信号成功，返回 0 ；否则返回非 0 值
 */
int pthread_cond_signal(pthread_cond_t* cond);

/* 广播某信号，唤醒所有相关的处于休眠的线程；
 * @return 广播成功，返回 0 ；否则返回非 0 值
 */
int pthread_cond_broadcast(pthread_cond_t* cond);
```

__例子：__ 条件锁的使用（用法与`NSCondition`大同小异）

```
- (void)pthread_mutex_ConditionMethod{
    __block pthread_mutex_t condMutexLock;
    __block pthread_cond_t pthreadCondition;//条件变量
    pthread_mutex_init(&condMutexLock, NULL);//初始化一个互斥锁
    pthread_cond_init(&pthreadCondition, NULL);//初始化一个条件变量
    NSMutableArray *array = [[NSMutableArray alloc] init];
        
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSLog(@"开始加锁 ： taskA === %@",NSThread.currentThread);
        pthread_mutex_lock(&condMutexLock);
        //wait() 接到 signal 后，并不意味着条件的值一定发生了变化，必须重新检查条件的值。最好的测试方法是循环调用：
        while ([array containsObject:@5] == NO){
            NSLog(@"执行wait： taskA === %@",NSThread.currentThread);
            struct timespec abstime;
            struct timeval now;
            long timeout_s = 5; // 等待 1s
            gettimeofday(&now, NULL);
            long nsec = now.tv_usec * 1000 + timeout_s * 1000000;
            abstime.tv_sec = now.tv_sec + nsec / 1000000000 + timeout_s;
            abstime.tv_nsec = nsec % 1000000000;
            if (pthread_cond_timedwait(&pthreadCondition, &condMutexLock, &abstime) == 0){
                NSLog(@"接signal： taskA === %@",NSThread.currentThread);
            }else{
                NSLog(@"taskA ---- 指定时间内也没有收到 信号");
            }
        }
        pthread_mutex_unlock(&condMutexLock);//解锁
        NSLog(@"已经解锁 ： taskA === %@",NSThread.currentThread);
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSLog(@"开始加锁 ： taskB === %@",NSThread.currentThread);
        pthread_mutex_lock(&condMutexLock);//上锁
        [array addObject:@5];
        pthread_cond_signal(&pthreadCondition);
        NSLog(@"发送信号 ： taskB === %@",NSThread.currentThread);
        pthread_mutex_unlock(&condMutexLock);//解锁
        NSLog(@"已经解锁 ： taskB === %@",NSThread.currentThread);
    });
}
```

####4、信号量`dispatch_semaphore`

信号量也称数据操作锁，本身不具备数据交换功能，通过控制其它通信资源来实现线程间通信。信号量在此过程中负责数据操作的互斥、同步等功能。

 `dispatch_semaphore` 和 `NSCondition` 类似，都是一种基于信号的同步方式。但 `NSCondition` 只能发送信号，不能保存：_如果没有线程在等待，则发送的信号会失效_；而 `dispatch_semaphore` 能保存发送的信号。`dispatch_semaphore` 的核心是 `dispatch_semaphore_t `类型的信号量。

```
/* 创建一个信号量
 * @param value 如果 < 0,则返回 NULL
 */
dispatch_semaphore_t dispatch_semaphore_create(long value);

/* 根据指定的条件，将线程休眠
 * @param dsema 指定的信号量，如果该信号量的 value>0 ，则该函数不执行任何操作，返回 0
 *              如果 value=0，当前线程会和 NSCondition 一样休眠，等待其它线程发送信号唤醒此线程去执行后续任务
 * @param timeout 截止时间；此时即使 value 值不大于 0 ，也会接着向下执行，
 *               DISPATCH_TIME_NOW 立即发生的时间，表示忽略信号量，直接运行
 *               DISPATCH_TIME_FOREVER表示无穷大的时间，表示会一直等待信号量为正数，才会继续运行
 * @return 如果该信号量的 value>0 ，则不执行任何操作，直接返回 0,
 *         如果 value=0，在截止时间之内收到信号，则唤醒该线程，并返回 0 ；
 *                      超过截止时间，唤醒该线程并返回非 0 值，
 */
long dispatch_semaphore_wait(dispatch_semaphore_t dsema, dispatch_time_t timeout);

/* 发送一个信号
* @param dsema 指定的信号量，如果该信号量的 value>0 ，则该函数不执行任何操作，返回 0
*              如果 value=0，则 value++，发送信号，唤醒休眠中的线程，返回 0
*/
long dispatch_semaphore_signal(dispatch_semaphore_t dsema);
```


__例子：__ `dispatch_semaphore`控制线程的最大并发数

```
- (void)dispatch_semaphoreMethod{
    dispatch_queue_t queue = dispatch_queue_create("com.demo.task", DISPATCH_QUEUE_CONCURRENT);
    dispatch_group_t group = dispatch_group_create();
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(2);
    dispatch_apply(6, queue, ^(size_t i) {
        long single = dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        dispatch_group_async(group, queue, ^{
            NSLog(@"开始执行第 %zu 次任务 == single : %ld----- %@",i,single,NSThread.currentThread);
            [NSThread sleepForTimeInterval:(i % 2 == 0 ? 2 : 3)];//模拟耗时任务
            long value = dispatch_semaphore_signal(semaphore);// 当线程任务执行完成之后，发送一个信号，增加信号量。
            NSLog(@"结束执行第 %zu 次任务 == single : %ld----- %@",i,value,NSThread.currentThread);
        });
    });
    
    //既控制了线程数量，也在执行任务完成之后得到了通知。
    dispatch_group_notify(group, queue, ^{
        NSLog(@"任务结束 ------ %@",NSThread.currentThread);
    });
}
```


####5、读写锁

对于实时性较高的应用如订票系统，使用互斥锁时，多条线程无法同时读取某个数据，并发性能较低。此时读写锁可以提高读取效率。
读写锁把对共享资源的访问者划分成读者和写者，__在任一时刻允许多条线程读取数据，提高并发度__；__同时在某个线程修改数据期间保护该数据，以免被其它线程的读取、修改操作干扰__。
 
* 写者：只需修改共享资源，具有排它性，同一时刻只有一条线程在写；
* 读者：只能读取共享资源；多条线程可以同时读取；
当之前（_读操作之前_）所有写操作完成之后，才能进行读操作；


利用 `dispatch_barrier_async()` 函数在队列中设置同步点，可以分别执行读取、写入，达到读写锁的效果。但没有 `pthread_rwlock_t` 好用。

##### 读写锁`pthread_rwlock_t` 

```
/* 初始化一个读写锁
 * @return 初始化成功，返回 0； 否则返回非 0
 */
int pthread_rwlock_init(pthread_rwlock_t * __restrict, const pthread_rwlockattr_t * _Nullable __restrict);

/* 销毁指定读写锁
 * @return 销毁成功，返回 0； 否则返回非 0
 */
int pthread_rwlock_destroy(pthread_rwlock_t * );

/* 写入操作上锁，会堵塞线程
 * @note 当该锁已经在其它线程执行 “写入操作上锁”，则会堵塞当前线程，等待其它线程完成写入操作；
 * @return 上锁成功，返回 0 ；否则返回非 0 值
 */
int pthread_rwlock_wrlock(pthread_rwlock_t *);

/* 写入操作尝试上锁，不会堵塞当前线程
 * @return 当该锁已经在其它线程执行“写入操作上锁”，上锁失败，立即返回非 0 值
 *         成功上锁返回 0；
 */
int pthread_rwlock_trywrlock(pthread_rwlock_t *);

/* 读取操作上锁，会堵塞线程
 * @note 当该锁已经在其它线程执行“写入操作上锁”，则会堵塞当前线程，等待其它线程解除 wrlock；
 *       直到之前的 wrlock 都已解锁，该函数返回 0 ，代码接着执行
 * @note 即使该锁已经在其它线程执行“读取操作上锁”，也不会影响该操作
 *       多条处于 rdlock 锁定的线程，可以同时访问某一资源
 * @return 成功上锁返回 0；否则返回非 0 值
 */
int pthread_rwlock_rdlock(pthread_rwlock_t *);

/* 读取操作尝试上锁，不会堵塞线程
 * @note1 当该锁已经在其它线程执行“写入操作上锁”，上锁失败，立即返回非 0 值；
 * @note2 即使该锁已经在其它线程执行 rdlock，也不会影响此处的 tryrdlock，依旧可以上锁成功
 * @return 成功上锁返回 0；否则返回非 0 值
 */
int pthread_rwlock_tryrdlock(pthread_rwlock_t *);

/* 解除读锁、解除写锁
 * @return 成功解除返回 0；否则返回非 0 值
*/
int pthread_rwlock_unlock(pthread_rwlock_t *);
```

__例子：__同时多次写入与读取：

```
- (void)pthread_rwlock_Method{
    __block pthread_rwlock_t rwlock;
    pthread_rwlock_init(&rwlock, NULL);//初始化一个读写锁
    NSMutableArray *array = [NSMutableArray array];
    dispatch_queue_t queue = dispatch_queue_create("com.demo.barrier", DISPATCH_QUEUE_CONCURRENT);

    //写任务：写锁锁定
    dispatch_block_t writeTask = dispatch_block_create(DISPATCH_BLOCK_BARRIER, ^{
        pthread_rwlock_wrlock(&rwlock);
        NSInteger index = array.count;
        NSLog(@"开始执行writeTask:%ld === %@",index,NSThread.currentThread);
        [array addObject:@(index)];
        [NSThread sleepForTimeInterval:3];//模拟耗时任务
        NSLog(@"结束执行writeTask:%ld === %@",index,NSThread.currentThread);
        pthread_rwlock_unlock(&rwlock);
    });

    NSLog(@"开始执行写入操作");
    for (int i = 0; i < 3; i++) {
        dispatch_async(queue, writeTask);
    }
    
    NSLog(@"开始执行读取操作");
    for (NSInteger index = 0; index < 3; index++) {
        dispatch_async(queue, ^{
            pthread_rwlock_rdlock(&rwlock);
            NSLog(@"开始执行readTask:%ld === %@",index,NSThread.currentThread);
            NSLog(@"读取数据:%ld---- %@",index,array[index]);
            [NSThread sleepForTimeInterval:3];//模拟耗时任务
            NSLog(@"结束执行readTask:%ld === %@",index,NSThread.currentThread);
            pthread_rwlock_unlock(&rwlock);
        });
    }
    NSLog(@"结束执行读写操作");
}
```


####6、执行一次的操作

```
/* GCD 提供 dispatch_once_t 保证在应用程序执行中只执行一次;
 * 常用于创建单例
 * @note 堵塞当前线程，直到 block 执行完毕
 * @note  如果在一个线程调用 dispatch_once() 函数时，另外的线程调用此处代码，
 *        则调用线程等待，不往下执行，直到首次调用的线程返回；
 *        此时 dispatch_once_t 被标记执行，Block 不再被执行，跳过往下执行。
 */
typedef intptr_t dispatch_once_t;
void dispatch_once(dispatch_once_t *predicate, DISPATCH_NOESCAPE dispatch_block_t block);

/* C语言提供 pthread_once_t 保证在应用程序执行中只执行一次; 常用于创建单例
 * @param pthread_once_t 控制变量，使用宏 PTHREAD_ONCE_INIT 静态地初始化该变量；
 * @param void(* _Nonnull)(void) 函数指针
 * @note 堵塞当前线程，直到函数执行完毕
 * @note  如果在一个线程调用 pthread_once() 函数时，另外的线程调用此处代码，
 *        则调用线程等待，不往下执行，直到首次调用的线程返回；
 *        此时 pthread_once_t 被标记执行，跳过该函数，往下执行。
 */
int pthread_once(pthread_once_t *, void (* _Nonnull)(void));
```

`pthread_once_t` 的实现效果和 `dispatch_once_t` 一样。使用 `pthread_once_t` 创建一个单例：

```
void pthread_once_Function(void) {
    static id shareInstance;
    shareInstance = [[NSObject alloc] init];
}

- (void)pthread_once_Method{
    pthread_once_t once = PTHREAD_ONCE_INIT;
     pthread_once(&once, &pthread_once_Function);
}
```

####7、属性修饰词 `atomic/nonatomic`

`atomic/nonatomic` 用来决定编译器生成的`getter` 和 `setter` 是否为原子操作；

#####7.1、`atomic`

声明一个属性默认为 `atomic`，系统会保证在其自动生成的 `getter/setter` 方法中的操作是完整的，不受其他线程的影响。如`线程5`在执行 `getter` 方法时，`线程6`执行了 `setter` 方法，此时 `线程5` 依然会得到一个完整无损的对象。

```
//声明一个atomic修饰的属性
@property (atomic ,copy) NSString *testStrig;

//setter 方法的内部实现
 - (void)setTestStrig:(NSString *)testStrig{
     {lock}
     if (![_testStrig isEqualToString:testStrig]){
        _testStrig = testStrig;
     }
    {unlock}
 }
```

`atomic` 不是线程安全的，如果有另一条线程同时在调 `[testStrig release]` ，程序可能 `crash` ，因为 `-release` 不受 `getter/setter` 操作的限制。也就是说，这个属性只是读/写安全的，但并不是线程安全的，因为其它线程还能执行读写之外的其他操作。线程安全需要开发者自己来保证。

`atomic` | `nonatomic`
-|-
默认修饰符|不是默认的
读写速度慢，性能差|速度更快，提高性能
读写安全，线程不安全|读写不安全，线程不安全

[demo](https://gitee.com/longMo/DataRace)

参考文章：
[iOS 常见知识点（三）：Lock](https://www.jianshu.com/p/ddbe44064ca4)
[C语言互斥锁pthread_mutex_t](https://blog.csdn.net/baidu_36649389/article/details/54573825)
[iOS 中常见的几种锁](http://www.cocoachina.com/ios/20180720/24248.html)
[pthread_cond_wait()用法分析](https://blog.csdn.net/hairetz/article/details/4535920)
[pthread_rwlock_t读写锁函数说明](https://www.cnblogs.com/renxinyuan/p/3875659.html)
 [ios atomic nonatomic区别](https://blog.csdn.net/lipeiran1987/article/details/31767917)
