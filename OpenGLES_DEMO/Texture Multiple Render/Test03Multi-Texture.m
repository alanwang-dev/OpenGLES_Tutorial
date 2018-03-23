//
//  Text03Multi-Texture.m
//  com.alan.OpenGLES_01
//
//  Created by 王可成 on 2017/10/8.
//  Copyright © 2017年 王可成. All rights reserved.
//

#import "Test03Multi-Texture.h"

typedef struct {
    GLKVector3 positionCoords;
    GLKVector2 textureCoords;
}SceneVector;

static const SceneVector vertices[] = {
    {{-0.5, -0.5, 0}, {0, 0}},
    {{-0.5,  0.5, 0}, {0, 1}},
    {{ 0.5,  0.5, 0}, {1, 1}},
    {{ 0.5, -0.5, 0}, {1, 0}},
};

@interface Test03Multi_Texture ()
@property (nonatomic) GLKBaseEffect *baseEffect;
@property (nonatomic) GLKTextureInfo *textureInfo_0;
@property (nonatomic) GLKTextureInfo *textureInfo_1;
@end

@implementation Test03Multi_Texture

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupContex];
    [self setupVBO];
    [self setupEffect];
    [self loadTexture];
}

- (void)dealloc{
    [EAGLContext setCurrentContext:nil];
}

- (void)setupContex{
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [(GLKView *)self.view setContext:context];
    [EAGLContext setCurrentContext:context];
}

- (void)setupVBO{
    GLuint buffers;
    glGenBuffers(1, &buffers);
    glBindBuffer(GL_ARRAY_BUFFER, buffers);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
}

- (void)setupEffect{
    _baseEffect = [[GLKBaseEffect alloc] init];
    _baseEffect.useConstantColor = GL_TRUE;
    _baseEffect.constantColor = GLKVector4Make(1, 1, 1, 1);
}

- (void)loadTexture{
    NSDictionary *options = @{
                              GLKTextureLoaderOriginBottomLeft : @(YES),
                              };
    CGImageRef image0 = [[UIImage imageNamed:@"leaves.gif"] CGImage];
    _textureInfo_0 = [GLKTextureLoader textureWithCGImage:image0
                                                   options:options
                                                     error:nil];
    
    CGImageRef image1 = [[UIImage imageNamed:@"beetle"] CGImage];
    _textureInfo_1 = [GLKTextureLoader textureWithCGImage:image1
                                                   options:options
                                                     error:nil];
    
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    glClearColor(0, 0, 0, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition,
                          3,
                          GL_FLOAT,
                          GL_FALSE,
                          sizeof(SceneVector),
                          NULL + offsetof(SceneVector, positionCoords));
    
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0,
                          2,
                          GL_FLOAT,
                          GL_FALSE,
                          sizeof(SceneVector),
                          NULL + offsetof(SceneVector, textureCoords));
    
    /* multi-pip rendering*/
    
    // firest texture
    self.baseEffect.texture2d0.target = _textureInfo_0.target;
    self.baseEffect.texture2d0.name = _textureInfo_0.name;
    [self.baseEffect prepareToDraw];
    glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
    
    // second texture
    self.baseEffect.texture2d0.target = _textureInfo_1.target;
    self.baseEffect.texture2d0.name = _textureInfo_1.name;
    [self.baseEffect prepareToDraw];
    glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
}

@end
