//
//  Test00GLKVC.m
//  com.alan.OpenGLES_01
//
//  Created by 王可成 on 2017/9/26.
//  Copyright © 2017年 王可成. All rights reserved.
//

#import "Test00GLKVC.h"

@interface Test00GLKVC ()
@property (nonatomic) GLKBaseEffect *baseEffect;
@end
typedef struct {
    GLKVector3 positionCoords;
} SceneVertex;
static const SceneVertex vertices[] = {
    {0.5, -0.5, 0},     // right down
    {0.5, 0.5, 0},      // right top
    {-0.5, 0.5, 0},     // left top
    {-0.5, -0.5, 0},    // left down
};

@implementation Test00GLKVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [(GLKView *)self.view setContext:context];
    [EAGLContext setCurrentContext:context];
    
    [self setupBaseEffect];
    
    glClearColor(0, 0, 0, 1);
    
    [self setupVBO];
}

- (void)dealloc{
    [EAGLContext setCurrentContext:nil];
}

- (void)setupBaseEffect{
    _baseEffect = [[GLKBaseEffect alloc] init];
    _baseEffect.useConstantColor = GL_TRUE;
    _baseEffect.constantColor = GLKVector4Make(1.f, 1.f, 1.f, 1.f);
}

- (void)setupVBO{
    GLuint buffers;
    glGenBuffers(1, &buffers);
    glBindBuffer(GL_ARRAY_BUFFER, buffers);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    [_baseEffect prepareToDraw];
    glClear(GL_COLOR_BUFFER_BIT);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(SceneVertex), NULL);
    glDrawArrays(GL_TRIANGLES, 0, 3);
}

@end
