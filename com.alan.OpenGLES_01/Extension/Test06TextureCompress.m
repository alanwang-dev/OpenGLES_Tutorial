//
//  Test06TextureCompress.m
//  com.alan.OpenGLES_01
//
//  Created by iVermisseDich on 2017/10/9.
//  Copyright © 2017年 王可成. All rights reserved.
//

#import "Test06TextureCompress.h"
#import <OpenGLES/ES2/glext.h>
@interface Test06TextureCompress ()

@end

@implementation Test06TextureCompress

- (void)viewDidLoad {
    [super viewDidLoad];
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
    [(GLKView *)self.view setContext:context];
    [EAGLContext setCurrentContext:context];
    
    if ([self checkForExtension:@"GL_IMG_texture_compression_pvrtc"]){
        NSLog(@"the compress extension is avaliable");
    }else{
        NSLog(@"the compress extension is avaliable");
    }
}

- (BOOL)checkForExtension:(NSString *)exten{
    // 需要切换上下文
    const GLubyte* extensions = glGetString(GL_EXTENSIONS);
    NSString *extensionStr = [NSString stringWithCString:extensions encoding:NSUTF8StringEncoding];
    NSArray *extensionName = [extensionStr componentsSeparatedByString:@" "];
    return [extensionName containsObject:exten];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
