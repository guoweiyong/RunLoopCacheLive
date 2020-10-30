//
//  GYPermanentThread.m
//  RunLoop-线程保活
//
//  Created by admin on 2020/10/30.
//

#import "GYPermanentThread.h"

@interface GYThread : NSThread

@end
@implementation GYThread

- (void)dealloc
{
    NSLog(@"--%s",__func__);
}
@end


@interface GYPermanentThread ()
// 这里声明GYThread是为了打印线程声明周期， 如果不需要刻意换乘NSThread
@property (nonatomic, strong) GYThread *innerThread;

/// OC下使用，在使用C语言时  可能用不到
@property (nonatomic, getter=isStop) BOOL stop;

@end
@implementation GYPermanentThread

#pragma mark --  public method

//OC版实现
//- (instancetype)init
//{
//    self = [super init];
//    if (self) {
//
//        __weak typeof(self) weakSelf = self;
//        self.innerThread = [[GYThread alloc] initWithBlock:^{
//            NSLog(@"begin-----------");
//            [[NSRunLoop currentRunLoop] addPort:[[NSPort alloc] init] forMode:NSDefaultRunLoopMode];
//
//            while (weakSelf && !weakSelf.isStop) {
//                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
//            }
//
//            NSLog(@"end-----------");
//        }];
//
//        //可以直接启动
//        [self.innerThread start];
//    }
//    return self;
//}


//C语言实现 : 使用C语言我们更加灵活的控制RunLoop
- (instancetype)init
{
    self = [super init];
    if (self) {
        __weak typeof(self) weakSelf = self;
        
        self.innerThread = [[GYThread alloc] initWithBlock:^{
            NSLog(@"begin-----------");
            //创建一个context对象 因为这个对象是一个结构体，而且放在栈上， 所以最好初始化，如果不初始划， 当前这个内存可能存在一些垃圾直，导致后面出现问题
            CFRunLoopSourceContext context = {0};
            
            //创建一个source对象
            CFRunLoopSourceRef sourceRef = CFRunLoopSourceCreate(kCFAllocatorDefault, 0, &context);
            
            //添加一个Source对象到RunLoop中
            CFRunLoopAddSource(CFRunLoopGetCurrent(), sourceRef, kCFRunLoopDefaultMode);
            
            //运行RunLoop  returnAfterSourceHandled: true 代表处理一次Source事件之后就返回 false: 表示处理完Soucre事件之后不返回
            
            //如果设置为true, 就需要添加外循环
//            while (weakSelf && !weakSelf.isStop) {
//                CFRunLoopRunInMode(kCFRunLoopDefaultMode, 1.0e10, true);
//            }
            
            //如果参数设置为false
            CFRunLoopRunInMode(kCFRunLoopDefaultMode, 1.0e10, false);
            
            NSLog(@"end-----------");
        }];
        
        //可以直接启动
        [self.innerThread start];
    }
    return self;
}


- (void)start {
    if (!self.innerThread) return;
    [self.innerThread start];
}

- (void)executeTask:(void (^)(void))block {
    if (!self.innerThread || !block) return;
    [self performSelector:@selector(__exectueTask:) onThread:self.innerThread withObject:block waitUntilDone:NO];
}

- (void)stop {
    if (!self.innerThread) return;
    
    [self performSelector:@selector(__stop) onThread:self.innerThread withObject:nil waitUntilDone:YES];
}

- (void)dealloc {
    NSLog(@"---%s---", __func__);
    
    [self stop];
}

#pragma mark --  private method
- (void)__stop {
    self.stop = YES;
    
    //停止RunLoop
    CFRunLoopStop(CFRunLoopGetCurrent());
    
    self.innerThread =  nil;
}

- (void)__exectueTask:(void (^)(void))task {
    task();
}
@end
