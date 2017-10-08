//
//  Text03Multi-Texture.m
//  com.alan.OpenGLES_01
//
//  Created by 王可成 on 2017/10/8.
//  Copyright © 2017年 王可成. All rights reserved.
//

#import "Test03Multi-Texture.h"
#import "AGLKTextureLoader.h"

@interface Test03Multi_Texture ()

@end

@implementation Test03Multi_Texture

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CGImageRef image = [[UIImage imageNamed:@"beetle"] CGImage];
    NSError *error;
    _textureInfo_1 = [AGLKTextureLoader textureWithCGImage:image
                                                   options:nil
                                                     error:&error];
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    [self.baseEffect prepareToDraw];
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
    self.baseEffect.texture2d0.target = _textureInfo_1.target;
    self.baseEffect.texture2d0.name = _textureInfo_1.name;
}

@end
