//
//  ATextureLoader.h
//  com.alan.OpenGLES_01
//
//  Created by iVermisseDich on 2017/9/30.
//  Copyright © 2017年 王可成. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

#pragma mark - AGLKTextureInfo
@interface AGLKTextureInfo : NSObject
{
@private
    GLuint                      name;
    GLenum                      target;
    GLuint                      width;
    GLuint                      height;
}

@property (readonly) GLuint                     name;
@property (readonly) GLenum                     target;
@property (readonly) GLuint                     width;
@property (readonly) GLuint                     height;

- (instancetype)initWithName:(GLuint)name
                      target:(GLenum)target
                       width:(GLuint)width
                      height:(GLuint)height;

@end


#pragma mark - AGLKTextureLoader
@interface AGLKTextureLoader : NSObject

+ (nullable AGLKTextureInfo *)textureWithCGImage:(CGImageRef _Nullable)cgImage
                                         options:(nullable NSDictionary<NSString*, NSNumber*> *)options
                                           error:(NSError * __nullable * __nullable)outError;


@end
