//
//  GYPermanentThread.h
//  RunLoop-线程保活
//
//  Created by admin on 2020/10/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GYPermanentThread : NSObject

/// 开始一个可控制生命周期的线程
- (void)start;

/// 停止线程
- (void)stop;

/// 执行任务
/// @param block <#block description#>
- (void)executeTask:(void(^)(void))block;
@end

NS_ASSUME_NONNULL_END
