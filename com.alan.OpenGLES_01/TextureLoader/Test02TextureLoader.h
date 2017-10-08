//
//  Test02TextureLoader.h
//  com.alan.OpenGLES_01
//
//  Created by iVermisseDich on 2017/9/30.
//  Copyright © 2017年 王可成. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "AGLKTextureLoader.h"

typedef struct {
    GLKVector3 colorVector;
    GLKVector2 posVector;
}SceneVector;

const static SceneVector vertices[] = {
    {{-0.5, -0.5, 0}, {0, 0}},
    {{-0.5,  0.5, 0}, {0, 1}},
    {{ 0.5,  0.5, 0}, {1, 1}},
    {{ 0.5, -0.5, 0}, {1, 0}},
};

@interface Test02TextureLoader : GLKViewController

@property (nonatomic) AGLKTextureInfo *textureInfo;
@property (nonatomic) AGLKTextureLoader *textureLoader;

@property (nonatomic) GLKBaseEffect *baseEffect;

@end
