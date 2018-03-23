//
//  AGLKView.h
//  com.alan.OpenGLES_01
//
//  Created by iVermisseDich on 2017/10/13.
//  Copyright © 2017年 王可成. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AGLKViewDelegate;

@interface AGLKView : UIView
{
    EAGLContext *context;
    GLuint defaultFrameBuffer;
    GLuint colorRenderBuffer;
    GLuint drawableWidth;
    GLuint drawableHeight;
}

@property (nonatomic, weak) id <AGLKViewDelegate>delegate;

@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, readonly) NSUInteger drawableWidth;
@property (nonatomic, readonly) NSUInteger drawableHeight;

- (void)display;

@end

@protocol AGLKViewDelegate <NSObject>
@required
- (void)glkView:(AGLKView *)view drawInRect:(CGRect)rect;

@end


