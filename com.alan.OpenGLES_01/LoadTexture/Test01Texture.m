//
//  Test01VC.m
//  com.alan.OpenGLES_01
//
//  Created by 王可成 on 2017/9/24.
//  Copyright © 2017年 王可成. All rights reserved.
//

#import "Test01Texture.h"

@interface Test01Texture ()
@property (nonatomic) GLKBaseEffect *effect;
@end

typedef struct {
    GLKVector3 positionCoords;
    GLKVector2 textureCoords;
}SceneVertex;

static const SceneVertex vertices[] = {
    {{-0.5, -0.5, 0}, {0, 0}},
    {{-0.5,  0.5, 0}, {0, 1}},
    {{ 0.5,  0.5, 0}, {1, 1}},
    {{ 0.5, -0.5, 0}, {1, 0}},
};

@implementation Test01Texture
- (void)viewDidLoad{
    [super viewDidLoad];
    
    EAGLContext *ctx = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [(GLKView *)self.view setContext:ctx];
    [EAGLContext setCurrentContext:ctx];
    
    [self setupVBO];
    [self setupEffect];
    [self setupTexture];
}

- (void)setupVBO{
    GLuint buffers;
    glGenBuffers(1, &buffers);
    glBindBuffer(GL_ARRAY_BUFFER, buffers);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
}

- (void)setupEffect{
    _effect = [[GLKBaseEffect alloc] init];
    _effect.useConstantColor = GL_TRUE;
    _effect.constantColor = GLKVector4Make(1, 1, 1, 1);
}

- (void)setupTexture{
    CGImageRef image = [UIImage imageNamed:@"bbc"].CGImage;
    NSError *error;
    //GLKTextureLoaderOriginBottomLeft 纹理坐标系是相反的
    NSDictionary *options = @{
                              GLKTextureLoaderOriginBottomLeft : @(YES),
                              };
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithCGImage:image options:options error:&error];
    _effect.texture2d0.name = textureInfo.name;
    _effect.texture2d0.target = textureInfo.target;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    [_effect prepareToDraw];
    glClearColor(0, 0, 0, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(SceneVertex), NULL + offsetof(SceneVertex, positionCoords));
    
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(SceneVertex), NULL + offsetof(SceneVertex, textureCoords));
    
    glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
}

@end
