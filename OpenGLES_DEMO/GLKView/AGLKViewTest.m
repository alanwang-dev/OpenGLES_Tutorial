//
//  AGLKViewTest.m
//  com.alan.OpenGLES_01
//
//  Created by iVermisseDich on 2017/10/13.
//  Copyright © 2017年 王可成. All rights reserved.
//

#import "AGLKViewTest.h"
#import "AGLKView.h"
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <GLKit/GLKit.h>

typedef struct {
    GLKVector3 positionCoords;
} SceneVertex;

static const SceneVertex vertices[] = {
    {0.5, -0.5, 0},     // right down
    {0.5, 0.5, 0},      // right top
    {-0.5, 0.5, 0},     // left top
    {-0.5, -0.5, 0},    // left down
};

@interface AGLKViewTest ()<AGLKViewDelegate>
@property (nonatomic) GLKBaseEffect *baseEffect;
@property (nonatomic) CADisplayLink *link;
@end


@implementation AGLKViewTest

- (void)loadView{
    AGLKView *view = [[AGLKView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.view = view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.opaque = YES;
    ((AGLKView *)self.view).delegate = self;
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [(AGLKView *)self.view setContext:context];
    [EAGLContext setCurrentContext:context];
    
    [self setupBaseEffect];
    
    glClearColor(0, 0, 0, 1);
    
    [self setupVBO];
    [self link];
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

- (void)glkView:(AGLKView *)view drawInRect:(CGRect)rect{
    [_baseEffect prepareToDraw];
    glClear(GL_COLOR_BUFFER_BIT);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(SceneVertex), NULL);
    glDrawArrays(GL_TRIANGLES, 0, 3);
}

- (CADisplayLink *)link{
    if (!_link) {
        _link = [CADisplayLink displayLinkWithTarget:self selector:@selector(drawView:)];
        [_link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
    return _link;
}

- (void)drawView:(id)sender{
    [(AGLKView *)self.view display];
}

@end
