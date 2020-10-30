//
//  ViewController.m
//  RunLoop-线程保活
//
//  Created by admin on 2020/10/29.
//

#import "ViewController.h"
//#import "GYThread.h"
#import "GYPermanentThread.h"

@interface ViewController ()
//@property (nonatomic, strong)GYThread *thread;
@property (nonatomic, getter=isStop) BOOL stop;

@property (nonatomic, strong)GYPermanentThread *thread;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.stop = NO;
    //创建线程
//    self.thread = [[GYThread alloc] initWithTarget:self selector:@selector(threadTest) object:nil];
//    __weak typeof(self) weakSelf = self;
//    self.thread = [[GYThread alloc] initWithBlock:^{
//        [[NSRunLoop currentRunLoop] addPort:[[NSPort alloc] init] forMode:NSDefaultRunLoopMode];
//        while (weakSelf && !weakSelf.isStop) {
//            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
//        }
//        NSLog(@"END--------%@",[NSThread currentThread]);
//    }];
//    [self.thread start];
    
    self.thread = [[GYPermanentThread alloc] init];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    //让存货的线程去做事情
    //waitUntilDone： 如果是YES： 表示需要等到子线程执行完成，在往下执行   NO： 表示不等待 继续往下执行
    //[self performSelector:@selector(run) onThread:self.thread withObject:nil waitUntilDone:NO];
    [self.thread executeTask:^{
        NSLog(@"currentThread=====%@",[NSThread currentThread]);
    }];
}
- (void)run {
    NSLog(@"methodName====%s  currentThread=====%@",__func__,[NSThread currentThread]);
}
- (IBAction)stopBtnClick:(UIButton *)sender {
    [self.thread stop];
//    if (!self.thread) return;
//    //停止runLoop
//    [self performSelector:@selector(stop) onThread:self.thread withObject:nil waitUntilDone:NO];
    
}

- (void)stop {
    //设置标记
//    self.stop = YES;
//
//    //停止RunLoop
//    CFRunLoopStop(CFRunLoopGetCurrent());
//
//    NSLog(@"---%s----",__func__);
//    self.thread = nil;
}


/// 该方法目的：线程保活
- (void)threadTest {
    NSLog(@"methodName====%s  currentThread=====%@",__func__,[NSThread currentThread]);
    //保持线程活下来，我们可以启动当前线程的RunLoop
    
    //但是线程还是立即死亡， 前面我们讲过，当RunLoop中当前执行的Model中没有任何`Source0/Source1/Timer/Observer`，`RunLoop`会立马退出‘
    //虽然我们调用run方法，底层调用- (BOOL)runMode:(NSRunLoopMode)mode beforeDate:(NSDate *)limitDate;方法并传入一个默认的模式，但是该模式下没有任何`Source0/Source1/Timer/Observer` ，所以Runloop会立刻退出
    //解决这个问题，我们需要往RunLoop中添加Source0/Source1/Timer/Observer
    [[NSRunLoop currentRunLoop] addPort:[[NSPort alloc] init] forMode:NSDefaultRunLoopMode];
    [[NSRunLoop currentRunLoop] run];//这个方法用来开启一个无线的循环，里面在循环调用- (BOOL)runMode:(NSRunLoopMode)mode beforeDate:(NSDate *)limitDate;方法 如果你调用CFRunLoopStop(CFRunLoopGetCurrent()),停止的只是其中一次循环
    //[[NSRunLoop currentRunLoop] run];是无法停止的，它专门用于开启一个永不停止的线程（NSRunLoop）
    /**
     run方法底层类似：
     
        while(1) {
     [[NSRunLoop currentRunLoop] runMode:(NSRunLoopMode)mode beforeDate:(NSDate *)limitDate];
    这个方法开启的runloop在被唤醒之后，执行一个任务完成之后，就退出了Runloop
     为了保证RunLoop的不退出，我们需要开启一个外循环，来不断的进入runloop，根据需要来进入和结束runloop的循环
     }
     */
    
    NSLog(@"END--------");
    
}

- (void)dealloc {
    //停止runLoop
//    if (self.thread) {
//        [self performSelector:@selector(stop) onThread:self.thread withObject:nil waitUntilDone:YES];
//    }
    NSLog(@"%s",__func__);
}


// 解决NSTimer在滑动状态下通知工作的问题
- (void)timerTest {
    
    //该方法创建定时器，系统默认直接添加到NSDefaultRunLoopMode 模式下 ，所以在滑动状态下是无法执行定时器的任务的
    [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
        NSLog(@"123");
    }];
    
    NSTimer *timer = [NSTimer timerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
        NSLog(@"123");
    }];
    //把timer对象添加到NSRunLoopCommonModes下
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    
}

@end
