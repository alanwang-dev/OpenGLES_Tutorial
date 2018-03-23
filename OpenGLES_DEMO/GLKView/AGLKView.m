//
//  AGLKView.m
//  com.alan.OpenGLES_01
//
//  Created by iVermisseDich on 2017/10/13.
//  Copyright © 2017年 王可成. All rights reserved.
//

#import "AGLKView.h"
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@implementation AGLKView
@synthesize drawableWidth = _drawableWidth;
@synthesize drawableHeight = _drawableHeight;

+ (Class)layerClass{
    return [CAEAGLLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        CAEAGLLayer *layer = (CAEAGLLayer *)self.layer;
        layer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithBool:YES],
                                    kEAGLDrawablePropertyRetainedBacking,
                                    kEAGLColorFormatRGBA8,
                                    kEAGLDrawablePropertyColorFormat,
                                    nil];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    // 1. Attaches an CAEAGLLayer as storage for the OpenGL ES renderbuffer object bound to GL_FRAMEBUFFER
    [context renderbufferStorage:GL_FRAMEBUFFER fromDrawable:(CAEAGLLayer *)self.layer];
    
    // 2. make color render buffer the current buffer for display
    glBindRenderbuffer(GL_RENDERBUFFER, colorRenderBuffer);
    
    // 3. check frame buffer status
    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    if (status != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"frame buffer status:%x", status);
    }
}

- (void)drawRect:(CGRect)rect{
    if ([self.delegate respondsToSelector:@selector(glkView:drawInRect:)]) {
        [self.delegate glkView:self drawInRect:self.bounds];
    }
}

- (void)display{
    [EAGLContext setCurrentContext:context];
    glViewport(0, 0, drawableWidth, drawableHeight);
    
    [self drawRect:self.bounds];
    [context presentRenderbuffer:GL_RENDERBUFFER];
}

#pragma mark - EAGLContext
- (void)setContext:(EAGLContext *)aContext{
    if (context == aContext) { return; }
    
    if (0 != defaultFrameBuffer) {
        glDeleteFramebuffers(1, &defaultFrameBuffer);
        defaultFrameBuffer = 0;
    }
    
    if (0 != colorRenderBuffer) {
        glDeleteRenderbuffers(1, & colorRenderBuffer);
        colorRenderBuffer = 0;
    }
    
    context = aContext;
    
    [EAGLContext setCurrentContext:context];
    if (context) {
        // frame buffer
        glGenFramebuffers(1, &defaultFrameBuffer);
        glBindFramebuffer(GL_FRAMEBUFFER, defaultFrameBuffer);
        
        // render buffer
        glGenRenderbuffers(1, &colorRenderBuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, colorRenderBuffer);
        
        // attach color render buffer to bound frame buffer
        glFramebufferRenderbuffer(GL_FRAMEBUFFER,
                                  GL_COLOR_ATTACHMENT0,
                                  GL_RENDERBUFFER,
                                  colorRenderBuffer);
        [self layoutSubviews];
    }
}

- (EAGLContext *)context{
    return context;
}

#pragma mark - drawable width & height
- (NSUInteger)drawableWidth{
    GLint width;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER,
                                 GL_RENDERBUFFER_WIDTH,
                                 &width);
    return width;
}

- (NSUInteger)drawableHeight{
    GLint height;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER,
                                 GL_RENDERBUFFER_HEIGHT,
                                 &height);
    return height;
}

- (void)dealloc{
    [EAGLContext setCurrentContext:nil];
    context = nil;
}
@end
