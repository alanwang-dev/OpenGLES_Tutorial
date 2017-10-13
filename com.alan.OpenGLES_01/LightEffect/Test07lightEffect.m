//
//  Test07lightEffect.m
//  com.alan.OpenGLES_01
//
//  Created by iVermisseDich on 2017/10/11.
//  Copyright © 2017年 王可成. All rights reserved.
//

#import "Test07lightEffect.h"

#define kTrianglesCount 8
#define kNormalVerticesCount 48
// vertex
typedef struct {
    GLKVector3 positionCoords;
    GLKVector3 normal;
    GLKVector2 textureCoords;
}SceneVertex;

// triangle
typedef struct {
    SceneVertex vertices[3];
}SceneTriangle;

static const SceneVertex vertexA = {{-0.5,  0.5, -0.5}, {0.0, 0.0, 1.0}, {0.0, 1.0}};
static const SceneVertex vertexB = {{-0.5,  0.0, -0.5}, {0.0, 0.0, 1.0}, {0.0, 0.5}};
static const SceneVertex vertexC = {{-0.5, -0.5, -0.5}, {0.0, 0.0, 1.0}, {0.0, 0.0}};
static const SceneVertex vertexD = {{ 0.0,  0.5, -0.5}, {0.0, 0.0, 1.0}, {0.5, 1.0}};
static const SceneVertex vertexE = {{ 0.0,  0.0, -0.5}, {0.0, 0.0, 1.0}, {0.5, 0.5}};
static const SceneVertex vertexF = {{ 0.0, -0.5, -0.5}, {0.0, 0.0, 1.0}, {0.5, 0.0}};
static const SceneVertex vertexG = {{ 0.5,  0.5, -0.5}, {0.0, 0.0, 1.0}, {1.0, 1.0}};
static const SceneVertex vertexH = {{ 0.5,  0.0, -0.5}, {0.0, 0.0, 1.0}, {1.0, 0.5}};
static const SceneVertex vertexI = {{ 0.5, -0.5, -0.5}, {0.0, 0.0, 1.0}, {1.0, 0.0}};

SceneTriangle SceneTriangleMake(SceneVertex v1, SceneVertex v2, SceneVertex v3){
    SceneTriangle triangle;
    triangle.vertices[0] = v1;
    triangle.vertices[1] = v2;
    triangle.vertices[2] = v3;
    return triangle;
}


@interface Test07lightEffect (){
    // triangles
    SceneTriangle triangles[kTrianglesCount];
    GLKVector3 normalVertices[kNormalVerticesCount];
    GLuint buffers;
    GLuint lineBuffers;
}

// base effect
@property (nonatomic, strong) GLKBaseEffect *effect;
@property (nonatomic, strong) GLKBaseEffect *extraEffect;
@end

@implementation Test07lightEffect

- (void)viewDidLoad {
    [super viewDidLoad];
    
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [(GLKView *)self.view setContext:context];
    [EAGLContext setCurrentContext:context];
    
    triangles[0] = SceneTriangleMake(vertexA, vertexB, vertexD);
    triangles[1] = SceneTriangleMake(vertexB, vertexC, vertexF);
    triangles[2] = SceneTriangleMake(vertexD, vertexB, vertexE);
    triangles[3] = SceneTriangleMake(vertexE, vertexB, vertexF);
    triangles[4] = SceneTriangleMake(vertexD, vertexE, vertexH);
    triangles[5] = SceneTriangleMake(vertexE, vertexF, vertexH);
    triangles[6] = SceneTriangleMake(vertexG, vertexD, vertexH);
    triangles[7] = SceneTriangleMake(vertexH, vertexF, vertexI);

    GLint verticesCount = sizeof(triangles) / sizeof(SceneVertex) * 2;
    [self updateNormalLineVertices:normalVertices count:verticesCount];

    [self initVBO];
    [self setupEffect];
    
    [self updateVertexEHeight:0];
    [self updateNormalAndReinitVBO];
}

- (void)initVBO{
    glGenBuffers(1, &buffers);
    glBindBuffer(GL_ARRAY_BUFFER, buffers);
    glBufferData(GL_ARRAY_BUFFER, sizeof(triangles), triangles, GL_DYNAMIC_DRAW);
    
    glGenBuffers(2, &lineBuffers);
    glBindBuffer(GL_ARRAY_BUFFER, lineBuffers);
    glBufferData(GL_ARRAY_BUFFER, sizeof(normalVertices), normalVertices, GL_DYNAMIC_DRAW);
    
    glClearColor(0, 0, 0, 1);
}

- (void)reinitVBO{
    glBindBuffer(GL_ARRAY_BUFFER, buffers);
    glBufferData(GL_ARRAY_BUFFER, sizeof(triangles), triangles, GL_DYNAMIC_DRAW);
}

- (void)setupEffect{
    _effect = [[GLKBaseEffect alloc] init];
    _effect.useConstantColor = GL_TRUE;
    _effect.constantColor = GLKVector4Make(1, 0, 0, 1);// red
    
    // light effect (must have normal)
    _effect.light0.enabled = GL_TRUE;
    _effect.light0.diffuseColor = GLKVector4Make(0.5, 0.5, 0.5, 1); // gray
    _effect.light0.position = GLKVector4Make(1, 1, 0.5, 0);
    
    CGImageRef img = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"LightingDetail256x256.png" ofType:@""]].CGImage;
    GLKTextureInfo *texture =
    [GLKTextureLoader textureWithCGImage:img
                                 options:@{GLKTextureLoaderOriginBottomLeft:@(YES)}
                                   error:nil];
    _effect.texture2d0.target = texture.target;
    _effect.texture2d0.name = texture.name;
    
    
    _extraEffect = [[GLKBaseEffect alloc] init];
    _extraEffect.useConstantColor = GL_TRUE;
    _extraEffect.constantColor = GLKVector4Make(
                                                    0.0f, // Red
                                                    1.0f, // Green
                                                    0.0f, // Blue
                                                    1.0f);// Alpha
    
    {// transform
        GLKMatrix4 modelViewMatrix = GLKMatrix4MakeRotation(GLKMathDegreesToRadians(-60.0f),
                                                            1.0f,
                                                            0.0f,
                                                            0.0f);
        modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix,
                                           GLKMathDegreesToRadians(-30.0f),
                                           0.0f,
                                           0.0f,
                                           1.0f);
        
        modelViewMatrix = GLKMatrix4Translate(modelViewMatrix,
                                              0.0f,
                                              0.0f,
                                              0.25f);
        _effect.transform.modelviewMatrix = modelViewMatrix;
        _extraEffect.transform.modelviewMatrix = modelViewMatrix;
    }
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    glClear(GL_COLOR_BUFFER_BIT);
    // enable positon
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition,
                          3,
                          GL_FLOAT,
                          GL_FALSE,
                          sizeof(SceneVertex),
                          NULL + offsetof(SceneVertex, positionCoords));
    // enable normal
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal,
                          3,
                          GL_FLOAT,
                          GL_FALSE,
                          sizeof(SceneVertex),
                          NULL + offsetof(SceneVertex, normal));
    // draw texture
//    [self enableTexture];
    
    [_effect prepareToDraw];
    glDrawArrays(GL_TRIANGLES,
                 0,
                 sizeof(triangles) / sizeof(SceneVertex));
    
    // draw normal lines
//    [self drawNormalLine];
}

- (void)drawNormalLine{
    // prepare to draw
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition,
                          3,
                          GL_FLOAT,
                          GL_FALSE,
                          sizeof(GLKVector3),
                          NULL);
    
    [_extraEffect prepareToDraw];
    glDrawArrays(GL_LINES,
                 0,
                 sizeof(kNormalVerticesCount)/sizeof(GLKVector3));
}

- (void)enableTexture{
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0,
                          2,
                          GL_FLOAT,
                          GL_FALSE,
                          sizeof(SceneVertex),
                          NULL + offsetof(SceneVertex, textureCoords));
}

- (void)updateVertexEHeight:(GLfloat)height{
    SceneVertex newVertexE = vertexE;
    newVertexE.positionCoords.z = height;
    
    triangles[2] = SceneTriangleMake(vertexD, vertexB, newVertexE);
    triangles[3] = SceneTriangleMake(newVertexE, vertexB, vertexF);
    triangles[4] = SceneTriangleMake(vertexD, newVertexE, vertexH);
    triangles[5] = SceneTriangleMake(newVertexE, vertexF, vertexH);
}

- (void)updateFaceNormal:(SceneTriangle [])someTriangles count:(GLint)count{
    for (GLint i = 0; i < count; ++i) {
        SceneTriangle triangle = someTriangles[i];
        GLKVector3 faceNormal = [self calculateFaceNormal:triangle];
        triangle.vertices[0].normal = faceNormal;
        triangle.vertices[1].normal = faceNormal;
        triangle.vertices[2].normal = faceNormal;
    }
}

- (void)updateVertexNormals:(SceneTriangle [])someTriangles count:(GLint)count
{
    SceneVertex newVertexA = vertexA;
    SceneVertex newVertexB = vertexB;
    SceneVertex newVertexC = vertexC;
    SceneVertex newVertexD = vertexD;
    SceneVertex newVertexE = someTriangles[3].vertices[0];
    SceneVertex newVertexF = vertexF;
    SceneVertex newVertexG = vertexG;
    SceneVertex newVertexH = vertexH;
    SceneVertex newVertexI = vertexI;
    GLKVector3 faceNormals[count];
    
    // Calculate the face normal of each triangle
    for (int i=0; i < count; i++)
    {
        faceNormals[i] = [self calculateFaceNormal:someTriangles[i]];
    }
    
    // Average each of the vertex normals with the face normals of
    // the 4 adjacent vertices
    newVertexA.normal = faceNormals[0];
    newVertexB.normal = GLKVector3MultiplyScalar(
                                                 GLKVector3Add(
                                                               GLKVector3Add(
                                                                             GLKVector3Add(
                                                                                           faceNormals[0],
                                                                                           faceNormals[1]),
                                                                             faceNormals[2]),
                                                               faceNormals[3]), 0.25);
    newVertexC.normal = faceNormals[1];
    newVertexD.normal = GLKVector3MultiplyScalar(
                                                 GLKVector3Add(
                                                               GLKVector3Add(
                                                                             GLKVector3Add(
                                                                                           faceNormals[0],
                                                                                           faceNormals[2]),
                                                                             faceNormals[4]),
                                                               faceNormals[6]), 0.25);
    newVertexE.normal = GLKVector3MultiplyScalar(
                                                 GLKVector3Add(
                                                               GLKVector3Add(
                                                                             GLKVector3Add(
                                                                                           faceNormals[2],
                                                                                           faceNormals[3]),
                                                                             faceNormals[4]),
                                                               faceNormals[5]), 0.25);
    newVertexF.normal = GLKVector3MultiplyScalar(
                                                 GLKVector3Add(
                                                               GLKVector3Add(
                                                                             GLKVector3Add(
                                                                                           faceNormals[1],
                                                                                           faceNormals[3]),
                                                                             faceNormals[5]),
                                                               faceNormals[7]), 0.25);
    newVertexG.normal = faceNormals[6];
    newVertexH.normal = GLKVector3MultiplyScalar(
                                                 GLKVector3Add(
                                                               GLKVector3Add(
                                                                             GLKVector3Add(
                                                                                           faceNormals[4],
                                                                                           faceNormals[5]),
                                                                             faceNormals[6]),
                                                               faceNormals[7]), 0.25);
    newVertexI.normal = faceNormals[7];
    
    // Recreate the triangles for the scene using the new
    // vertices that have recalculated normals
    someTriangles[0] = SceneTriangleMake(
                                         newVertexA,
                                         newVertexB,
                                         newVertexD);
    someTriangles[1] = SceneTriangleMake(
                                         newVertexB,
                                         newVertexC,
                                         newVertexF);
    someTriangles[2] = SceneTriangleMake(
                                         newVertexD,
                                         newVertexB,
                                         newVertexE);
    someTriangles[3] = SceneTriangleMake(
                                         newVertexE,
                                         newVertexB,
                                         newVertexF);
    someTriangles[4] = SceneTriangleMake(
                                         newVertexD,
                                         newVertexE,
                                         newVertexH);
    someTriangles[5] = SceneTriangleMake(
                                         newVertexE,
                                         newVertexF,
                                         newVertexH);
    someTriangles[6] = SceneTriangleMake(
                                         newVertexG,
                                         newVertexD,
                                         newVertexH);
    someTriangles[7] = SceneTriangleMake(
                                         newVertexH,
                                         newVertexF,
                                         newVertexI);
}

- (GLKVector3)calculateFaceNormal:(SceneTriangle)triangle{
    GLKVector3 vector0_1 = GLKVector3Subtract(triangle.vertices[1].positionCoords,
                                              triangle.vertices[0].positionCoords);
    GLKVector3 vector0_2 = GLKVector3Subtract(triangle.vertices[2].positionCoords,
                                              triangle.vertices[0].positionCoords);
    
    return GLKVector3Normalize((GLKVector3CrossProduct(vector0_1, vector0_2)));
}

- (void)updateNormalLineVertices:(GLKVector3 *)vertices count:(GLuint)count{
    
    int trianglesIndex;
    int lineVetexIndex = 0;
    
    // Define lines that indicate direction of each normal vector
    for (trianglesIndex = 0; trianglesIndex < kTrianglesCount; trianglesIndex++)
    {
        vertices[lineVetexIndex++] = triangles[trianglesIndex].vertices[0].positionCoords;
        vertices[lineVetexIndex++] =
        GLKVector3Add(
                      triangles[trianglesIndex].vertices[0].positionCoords,
                      GLKVector3MultiplyScalar(
                                               triangles[trianglesIndex].vertices[0].normal,
                                               0.5));
        vertices[lineVetexIndex++] =
        triangles[trianglesIndex].vertices[1].positionCoords;
        vertices[lineVetexIndex++] =
        GLKVector3Add(
                      triangles[trianglesIndex].vertices[1].positionCoords,
                      GLKVector3MultiplyScalar(
                                               triangles[trianglesIndex].vertices[1].normal,
                                               0.5));
        vertices[lineVetexIndex++] =
        triangles[trianglesIndex].vertices[2].positionCoords;
        vertices[lineVetexIndex++] =
        GLKVector3Add(
                      triangles[trianglesIndex].vertices[2].positionCoords,
                      GLKVector3MultiplyScalar(
                                               triangles[trianglesIndex].vertices[2].normal,
                                               0.5));
    }
    
//    // Add a line to indicate light direction
//    vertices[lineVetexIndex++] =
//    lightPosition;
//
//    vertices[lineVetexIndex] = GLKVector3Make(
//                                                            0.0,
//                                                            0.0,
//                                                            -0.5);
}
#pragma mark - Actions

- (IBAction)switchNormalType:(UISegmentedControl *)sender {
    [self updateNormalAndReinitVBO];
}

- (IBAction)changeVertexEHeight:(UISlider *)sender {
    [self updateVertexEHeight:sender.value];
    [self updateNormalAndReinitVBO];
}

static bool useFaceNormal = false;
- (void)updateNormalAndReinitVBO{
    if (useFaceNormal) {
        [self updateFaceNormal:triangles count:sizeof(triangles)/sizeof(SceneTriangle)];
    }else{
        [self updateVertexNormals:triangles count:sizeof(triangles)/sizeof(SceneTriangle)];
    }
    useFaceNormal = !useFaceNormal;
    // update normal line vertices
    [self updateNormalLineVertices:normalVertices count:kNormalVerticesCount];
    glBindBuffer(GL_ARRAY_BUFFER, lineBuffers);
    glBufferData(GL_ARRAY_BUFFER, sizeof(normalVertices), normalVertices, GL_DYNAMIC_DRAW);

    // update VBO
    [self reinitVBO];
}

@end
