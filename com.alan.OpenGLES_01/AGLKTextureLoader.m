//
//  ATextureLoader.m
//  com.alan.OpenGLES_01
//
//  Created by iVermisseDich on 2017/9/30.
//  Copyright © 2017年 王可成. All rights reserved.
//

#import "AGLKTextureLoader.h"

@interface AGLKTextureInfo ()
@property (assign, nonatomic) GLuint name;
@property (assign, nonatomic) GLenum target;
@property (assign, nonatomic) GLuint width;
@property (assign, nonatomic) GLuint height;
@end

@implementation AGLKTextureInfo
- (instancetype)initWithName:(GLuint)name
                      target:(GLenum)target
                       width:(GLuint)width
                      height:(GLuint)height{
    if (self = [super init]){
        self.name = name;
        self.target = target;
        self.width = width;
        self.height = height;
    }
    return self;
}
@end



static NSData * AGLKDataWithResizedCGImageByte(CGImageRef cgImage, size_t *width, size_t *height) {
    
    return nil;
}

@implementation AGLKTextureLoader

+ (nullable AGLKTextureInfo *)textureWithCGImage:(CGImageRef _Nullable)cgImage
                                         options:(nullable NSDictionary<NSString*, NSNumber*> *)options
                                           error:(NSError * __nullable * __nullable)outError{
    if (!cgImage) {
        return nil;
    }
    
    GLuint width, height;
    NSData *data = AGLKDataWithResizedCGImageByte(cgImage, &width, &height);
    
    GLuint textureBufferID;
    glGenTextures(1, &textureBufferID);
    glBindTexture(GL_TEXTURE_2D, textureBufferID);
    
    /*
     位编码类型介绍
     - GL_UNSIGNED_BYTE
         会提供最佳色彩，但是每个纹素中的每个颜色元素都需要一个字节的存储空间
         读取一个RGB类型的纹素，至少读取3字节（24位）
         读取一个RGBA类型的纹素，至少读取4字节（32位）
     
     以下类型的编码方式会把每个纹素的所有颜色元素信息保存在2个字节中
     - GL_UNSIGNED_SHORT_5_6_5
         5位用于red，6位用于green，5位用于blue 没有alpha信息
     - GL_UNSIGNED_SHORT_4_4_4_4
         r g b a 均使用4位保存
     - GL_UNSIGNED_SHORT_5_5_5_1
         r g b 均使用5位保存，a 使用1位保存(透明/不透明)
     */
    
    // copy pixel color to texture buffer
    glTexImage2D(GL_TEXTURE_2D,
                 0,                 // MIP 贴图等级，不适用MIP贴图则必须为0
                 GL_RGBA,           // internalFormat 图片颜色信息存储方式
                 (int)width,        // image texture width (需要是2的幂次方)
                 (int)height,       // image texture height (需要是2的幂次方)
                 0,                 // border : 围绕纹理的纹素的边界大小，一般设置为0
                 GL_RGBA,           // 初始化 texture buffer 所使用的图像数据中的每个像素所要保存的信息（一般与internalFormat 保持一致）
                 GL_UNSIGNED_BYTE,  // 缓存中的纹素数据使用的位编码类型
                 [data bytes]);     // texture buffer data
    
    
    // set texture for bound
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    
    // create textureInfo
    AGLKTextureInfo *textureInfo = [[AGLKTextureInfo alloc] initWithName:textureBufferID
                                                                  target:GL_TEXTURE_2D
                                                                   width:(GLuint)width
                                                                  height:(GLuint)height];
    
    return textureInfo;
}

@end
