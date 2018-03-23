//
//  FrameBuffer&Renderbuffer.m
//  OpenGLES_DEMO
//
//  Created by iVermisseDich on 2018/3/23.
//  Copyright © 2018年 王可成. All rights reserved.
//

#import "FrameBuffer&Renderbuffer.h"
#import <OpenGLES/ES3/glext.h>

typedef struct {
    GLKVector3 positionCoords;
    GLKVector2 textureCoords;
} SceneVertex;

static const SceneVertex vertices[] = {
    {{-0.5, -0.5, 0}, {0, 0}},
    {{-0.5,  0.5, 0}, {0, 1}},
    {{ 0.5,  0.5, 0}, {1, 1}},
    {{ 0.5, -0.5, 0}, {1, 0}},
};


@interface FrameBuffer_Renderbuffer ()
{
    GLuint framebuffer;
    GLuint colorRenderbuffer;
    GLuint depthRenderbuffer;
    
    GLuint texture;
    
    GLsizei drableWidth;
    GLsizei drableHeight;
    GLKBaseEffect *_effect;
}
@property (nonatomic) EAGLContext *context;
@end

@implementation FrameBuffer_Renderbuffer

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 2. configure context
    GLKView *__view = (GLKView *)self.view;
    _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    __view.context = _context;
    [EAGLContext setCurrentContext:_context];
    
    ((CAEAGLLayer *)__view.layer).drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                                        [NSNumber numberWithBool:YES],
                                                        kEAGLDrawablePropertyRetainedBacking,
                                                        kEAGLColorFormatRGBA8,
                                                        kEAGLDrawablePropertyColorFormat,
                                                        nil];
    ((CAEAGLLayer *)__view.layer).opaque = YES;
    
    // 3. create framebuffer
    glClearColor(0.7, 0.7, 0.7, 1);
    glGenFramebuffers(1, &framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
    
    // 4. VBO
    GLuint buffers;
    glGenBuffers(1, &buffers);
    glBindBuffer(GL_ARRAY_BUFFER, buffers);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    _effect = [[GLKBaseEffect alloc] init];
    _effect.useConstantColor = GL_TRUE;
    _effect.constantColor = GLKVector4Make(1, 1, 1, 1);
    
#if 0
    // 4. create renderbuffer
    glGenRenderbuffers(1, &colorRenderbuffer);
    glGenRenderbuffers(1, &depthRenderbuffer);

    // it can also create multi buffers a time
    /**
        GLuint renderBuffers[2];
        glGenRenderbuffers(2, renderBuffers)
        colorRenderbuffer = renderBuffers[0];
        depthRenderbuffer = renderBuffers[1];
    */
    
    glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, depthRenderbuffer);
    
    glRenderbufferStorage(colorRenderbuffer, GL_FLOAT, drableWidth, drableHeight);
    glRenderbufferStorage(depthRenderbuffer, GL_DEPTH_COMPONENT16, drableWidth, drableHeight);
    
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorRenderbuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthRenderbuffer);
#else
    UIImage *img = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"abc" ofType:@"png"]];
    GLubyte *textureData = (GLubyte *)malloc(CGImageGetBytesPerRow(img.CGImage) * img.size.height);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(textureData, CGImageGetWidth(img.CGImage), CGImageGetHeight(img.CGImage), CGImageGetBitsPerComponent(img.CGImage), CGImageGetBytesPerRow(img.CGImage), colorSpace, CGImageGetBitmapInfo(img.CGImage));
    CGColorSpaceRelease(colorSpace);

    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(img.CGImage), CGImageGetHeight(img.CGImage)), img.CGImage);

    CGContextRelease(context);
    glGenTextures(1, &texture);
    glBindTexture(GL_TEXTURE_2D, texture);
    BOOL attach = [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)__view.layer];
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (int)CGImageGetWidth(img.CGImage), (int)CGImageGetHeight(img.CGImage), 0, GL_RGBA, GL_UNSIGNED_BYTE, textureData);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, texture, 0);

    /** 使用GLKTextureLoader加载texture
         //GLKTextureLoaderOriginBottomLeft 纹理坐标系是相反的
         NSDictionary *options = @{
         GLKTextureLoaderOriginBottomLeft : @(YES),
         };
         GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithCGImage:image options:options error:&error];
         _effect.texture2d0.name = textureInfo.name;
         _effect.texture2d0.target = textureInfo.target;
     */
#endif
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    [EAGLContext setCurrentContext:_context];
    [_effect prepareToDraw];
    glClear(GL_COLOR_BUFFER_BIT| GL_DEPTH_BUFFER_BIT);
    
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(SceneVertex), NULL+offsetof(SceneVertex, positionCoords));
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(SceneVertex), NULL+offsetof(SceneVertex, textureCoords));
    glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
    
    
    
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (GLuint)drableWidth{
    GLint width;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &width);
    return width;
}

- (GLuint)drableHeight{
    GLint height;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &height);
    return height;
}

@end
