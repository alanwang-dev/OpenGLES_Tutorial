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

typedef enum
{
    AGLK1 = 1,
    AGLK2 = 2,
    AGLK4 = 4,
    AGLK8 = 8,
    AGLK16 = 16,
    AGLK32 = 32,
    AGLK64 = 64,
    AGLK128 = 128,
    AGLK256 = 256,
    AGLK512 = 512,
    AGLK1024 = 1024,
}
AGLKTPowerOf2;

static AGLKTPowerOf2 AGLKCalculatePowerOf2ForDimension(GLuint dimension)
{
    AGLKTPowerOf2 result = AGLK1;
    if (dimension > (GLuint)AGLK512){
        result  = AGLK1024;
    }else if(dimension > (GLuint)AGLK256){
        result = AGLK512;
    }else if(dimension > (GLuint)AGLK128){
        result = AGLK256;
    }else if(dimension > (GLuint)AGLK64){
        result = AGLK128;
    }else if(dimension > (GLuint)AGLK32){
        result = AGLK64;
    }else if(dimension > (GLuint)AGLK16){
        result = AGLK32;
    }else if(dimension > (GLuint)AGLK8){
        result = AGLK16;
    }else if(dimension > (GLuint)AGLK4){
        result = AGLK8;
    }else if(dimension > (GLuint)AGLK2){
        result = AGLK4;
    }else if(dimension > (GLuint)AGLK1){
        result = AGLK2;
    }
    
    return result;
}


@implementation AGLKTextureInfo
- (instancetype)initWithName:(GLuint)name
                      target:(GLenum)target
                       width:(GLuint)width
                      height:(GLuint)height{
    if (self = [super init]){
        _name = name;
        _target = target;
        _width = width;
        _height = height;
    }
    return self;
}
@end


#pragma mark - AGLKTextureLoader
@implementation AGLKTextureLoader

+ (nullable AGLKTextureInfo *)textureWithCGImage:(CGImageRef _Nullable)cgImage
                                         options:(nullable NSDictionary<NSString*, NSNumber*> *)options
                                           error:(NSError * __nullable * __nullable)outError{
    if (!cgImage) {
        return nil;
    }
    
    GLuint width, height;
    NSData *data = [self AGLKDataWithResizedCGImageByte:cgImage width:&width height:&height];
    
    GLuint textureBufferID;
    // 1. generate texture id
    glGenTextures(1, &textureBufferID);
    // 2. bind texture type
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
    
    // 3. copy pixel color to texture buffer
    glTexImage2D(GL_TEXTURE_2D,
                 0,                 // MIP 贴图等级，不适用MIP贴图则必须为0
                 GL_RGBA,           // internalFormat 图片颜色信息存储方式
                 (GLuint)width,     // image texture width (需要是2的幂次方)
                 (GLuint)height,    // image texture height (需要是2的幂次方)
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

+ (NSData *)AGLKDataWithResizedCGImageByte:(CGImageRef)cgImage width:(GLuint *)widthPtr height:(GLuint *)heightPtr {
    NSCParameterAssert(NULL != cgImage);
    NSCParameterAssert(NULL != widthPtr);
    NSCParameterAssert(NULL != heightPtr);

    GLuint imgWidth = (GLuint)CGImageGetWidth(cgImage);
    GLuint imgHeight = (GLuint)CGImageGetHeight(cgImage);

    /******************** resize dimension to power of 2 ********************/
    GLuint width = AGLKCalculatePowerOf2ForDimension(imgWidth);
    GLuint height = AGLKCalculatePowerOf2ForDimension(imgHeight);
    
    *widthPtr = width;
    *heightPtr = height;

    NSMutableData *imgData = [NSMutableData dataWithLength:width * height * 4];

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    // create bitmap context
    CGContextRef context = CGBitmapContextCreate([imgData mutableBytes],          //
                                                 width,                           // image width
                                                 height,                          // image height
                                                 8,                               // bits per component
                                                 4 * width,                       // bytes per row
                                                 colorSpace,                      // color space ref
                                                 kCGImageAlphaPremultipliedLast); // bitmap info
    CGColorSpaceRelease(colorSpace);

    // context transform
    CGContextTranslateCTM(context, 0, height);
    CGContextScaleCTM(context, 1.0, -1.0);

    // draw image
    CGContextDrawImage(context,
                       CGRectMake(0, 0, width, height),
                       cgImage);

    // release
    CGContextRelease(context);

    return imgData;
}

@end
