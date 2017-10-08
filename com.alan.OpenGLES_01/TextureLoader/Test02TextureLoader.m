//
//  Test02TextureLoader.m
//  com.alan.OpenGLES_01
//
//  Created by iVermisseDich on 2017/9/30.
//  Copyright © 2017年 王可成. All rights reserved.
//

#import "Test02TextureLoader.h"

@implementation Test02TextureLoader

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.layer.backgroundColor = [[UIColor blackColor] CGColor];
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [(GLKView *)self.view setContext:context];
    [EAGLContext setCurrentContext:context];
    
    [self setupBufferWithTarget:GL_ARRAY_BUFFER size:sizeof(vertices) data:vertices];
    [self setupEffect];
    [self setupTextureBuffer];
}

// setup vertices buffer
- (void)setupBufferWithTarget:(GLenum)target size:(GLsizeiptr)size data:(const GLvoid *)data {
    GLuint buffers;
    glGenBuffers(1, &buffers);
    glBindBuffer(target, buffers);
    glBufferData(target, size, data, GL_STATIC_DRAW);
}

- (void)setupEffect{
    _baseEffect = [[GLKBaseEffect alloc] init];
    _baseEffect.useConstantColor = GL_TRUE;
    _baseEffect.constantColor = GLKVector4Make(1, 1, 1, 1);
}

- (void)setupTextureBuffer{
    CGImageRef image = [UIImage imageNamed:@"leaves.gif"].CGImage;
    NSError *error;
    
    NSDictionary *options = @{GLKTextureLoaderOriginBottomLeft : @(YES)};
    _textureInfo = [AGLKTextureLoader textureWithCGImage:image
                                                 options:options
                                                   error:&error];
    
    _baseEffect.texture2d0.name = _textureInfo.name;
    _baseEffect.texture2d0.target = _textureInfo.target;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    [_baseEffect prepareToDraw];
    glClearColor(0, 0, 0, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition,
                          3,
                          GL_FLOAT,
                          GL_FALSE,
                          sizeof(SceneVector),
                          NULL + offsetof(SceneVector, colorVector));
    
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0,
                          2,
                          GL_FLOAT,
                          GL_FALSE,
                          sizeof(SceneVector),
                          NULL + offsetof(SceneVector, posVector));
    glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
}

@end
