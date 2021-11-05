#import "AAPLMathUtilities.h"

//----------------------------------------------------------------------------------------

struct Camera {
    vector_float3 position;
    vector_float3 target;
    float rotation;
    float aspectRatio;      // width/height
    float fovVert_Half;     // 垂直视场的一半，以弧度表示
    float distanceNear;
    float distanceFar;
    
    /// 世界坐标系到观察坐标系的转换
    matrix_float4x4 GetViewMatrix () const {
        return matrix_look_at_left_hand(position, target, (vector_float3){0,1,0});
    }
    
    /// 左手坐标系的透视投影：观察坐标系到视景体的转换
    matrix_float4x4 GetProjectionMatrix_LH () const {
        return matrix_perspective_left_hand (
            fovVert_Half * 2.f,
            aspectRatio,
            distanceNear,
            distanceFar);
    }
};

//----------------------------------------------------------------------------------------

struct CameraProbe {
    vector_float3 position;
    float distanceNear;
    float distanceFar;

    // 为X轴、Y轴、Z轴填充视图矩阵
    matrix_float4x4 GetViewMatrixForFace_LH (int faceIdx) const
    {
        static const vector_float3 directions [6] =
        {
            { 1,  0,  0}, // Right
            {-1,  0,  0}, // Left
            { 0,  1,  0}, // Top
            { 0, -1,  0}, // Down
            { 0,  0,  1}, // Front
            { 0,  0, -1}  // Back
        };

        static const vector_float3 ups [6] =
        {
            {0, 1,  0},
            {0, 1,  0},
            {0, 0, -1},
            {0, 0,  1},
            {0, 1,  0},
            {0, 1,  0}
        };

        return matrix_look_at_left_hand(position, position + directions[faceIdx], ups[faceIdx]);
    }

    matrix_float4x4 GetProjectionMatrix_LH () const
    {
        return matrix_perspective_left_hand (
            M_PI_2,
            1.f,
            distanceNear,
            distanceFar);
    }
};

//----------------------------------------------------------------------------------------

//  视景体和参数形状之间的交集
struct FrustumCuller {
    /// 观察点位置
    vector_float3 position;
    
    /// 平面法向量
    vector_float3 norm_NearPlane;
    vector_float3 norm_LeftPlane;
    vector_float3 norm_RightPlane;
    vector_float3 norm_BottomPlane;
    vector_float3 norm_TopPlane;

    float         dist_Near; /// 观察点与近平面的距离
    float         dist_Far;  /// 观察点与远平面的距离

    /// 初始化数据，以便调用透视矩阵 (左手坐标系)
    void Reset_LH ( const matrix_float4x4 viewMatrix,
                    const vector_float3   viewPosition,
                    const float           aspect,
                    const float           halfAngleApertureHeight, // 弧度
                    const float           nearPlaneDistance,
                    const float           farPlaneDistance ) {
        position  = viewPosition;
        dist_Near = nearPlaneDistance;
        dist_Far  = farPlaneDistance;

        const float halfAngleApertureWidth = halfAngleApertureHeight * aspect;
        const matrix_float3x3 cameraRotationMatrix = matrix_invert (matrix3x3_upper_left (viewMatrix));

        norm_NearPlane = matrix_multiply (
            cameraRotationMatrix,
            (vector_float3) {0.0, 0.0, 1.0} );
        
        norm_LeftPlane = matrix_multiply (
            cameraRotationMatrix,
            (vector_float3) {cosf(halfAngleApertureWidth), 0.f, sinf(halfAngleApertureWidth)} );

        norm_BottomPlane = matrix_multiply (
            cameraRotationMatrix,
            (vector_float3) {0.f, cosf(halfAngleApertureHeight), sinf(halfAngleApertureHeight)} );

        // 将左平面法线沿视图方向反射(norm_NearPlane)以得到右平面法线:
        norm_RightPlane  = (- norm_LeftPlane)   + norm_NearPlane * (vector_dot(norm_NearPlane, norm_LeftPlane)   * 2.f);
        // 同样的，从底部平面得到顶部平面的法线:
        norm_TopPlane    = (- norm_BottomPlane) + norm_NearPlane * (vector_dot(norm_NearPlane, norm_BottomPlane) * 2.f);
    }

    /// cachedViewMatrix 是观察点矩阵，作为一个参数给出、而非直接从摄像机获取它；
    void Reset_LH (const matrix_float4x4 cachedViewMatrix, const Camera camera) {
        Reset_LH (cachedViewMatrix, camera.position, camera.aspectRatio, camera.fovVert_Half, camera.distanceNear, camera.distanceFar);
    }

    void Reset_LH (const matrix_float4x4 cachedViewMatrix, const CameraProbe camera) {
        Reset_LH (cachedViewMatrix, camera.position, 1.f, M_PI_4, camera.distanceNear, camera.distanceFar);
    }

    /// 为了测试视景体和球体之间的交点，通过包围球体的半径来“膨胀”视景体;然后测试球体中心是否在这个扩展的截锥内。
    bool Intersects (const vector_float3 actorPosition, vector_float4 bSphere) const
    {
        const vector_float4 position_f4 = (vector_float4) {actorPosition.x, actorPosition.y, actorPosition.z, 0.f};
        bSphere += position_f4;

        const float         bSphereRadius    = bSphere.w;
        const vector_float3 camToSphere      = bSphere.xyz - position;

        if (vector_dot (camToSphere + norm_NearPlane * (bSphereRadius-dist_Near), norm_NearPlane)   < 0) { return false; }
        if (vector_dot (camToSphere - norm_NearPlane * (bSphereRadius+dist_Far),  -norm_NearPlane)  < 0) { return false; }

        if (vector_dot (camToSphere + norm_LeftPlane  * bSphereRadius,            norm_LeftPlane)   < 0) { return false; }
        if (vector_dot (camToSphere + norm_RightPlane * bSphereRadius,            norm_RightPlane)  < 0) { return false; }

        if (vector_dot (camToSphere + norm_BottomPlane * bSphereRadius,           norm_BottomPlane) < 0) { return false; }
        if (vector_dot (camToSphere + norm_TopPlane    * bSphereRadius,           norm_TopPlane)    < 0) { return false; }

        return true;
    }
};

//----------------------------------------------------------------------------------------

/// 枚举处理类型
enum EPassFlags : uint8_t {
    Reflection = 1 << 0, /// 映射
    Render     = 1 << 1, /// 渲染
    ALL_PASS = (uint8_t) ~(uint8_t(0))
};

//----------------------------------------------------------------------------------------

// Data describing each 'object' the world will contain.
@interface AAPLActorData : NSObject

    // Metal pipeline used to render this actor
    @property (nonatomic) id<MTLRenderPipelineState>  gpuProg;

    // pointer to meshes used by this actor
    @property (nonatomic, copy)  NSArray <AAPLMesh*>*  meshes;

    // bounding sphere. position is stored in xyz, radius is stored in w.
    @property (nonatomic)  vector_float4               bSphere;

    // multiplier used in shading to color actors using the same mesh differently
    @property (nonatomic)  vector_float3               diffuseMultiplier;

    // translation away from rotation point
    @property (nonatomic)  vector_float3               translation;

    // Position around which we rotate the object
    @property (nonatomic)  vector_float3               rotationPoint;

    // current rotation angle (in radians) around rotationAxis at rotationPoint
    @property (nonatomic)  float                       rotationAmount;

    // per-actor multiplier for rotation
    @property (nonatomic)  float                       rotationSpeed;

    // per-actor axis for rotation
    @property (nonatomic)  vector_float3               rotationAxis;

    // actor's position in the scene
    @property (nonatomic)  vector_float4               modelPosition;

    // passes this actor must be rendered to
    @property (nonatomic)  EPassFlags                  passFlags;

    // number of instances with which we must draw this actor in the reflection pass
    @property (nonatomic)  uint8_t                     instanceCountInReflection;

    // Whether this actor is visible in the final pass
    @property (nonatomic)  BOOL                        visibleInFinal;
@end
@implementation AAPLActorData
@end

//----------------------------------------------------------------------------------------

/// 内存地址对齐
template <size_t align>
constexpr size_t Align (size_t value)
{
    static_assert (
        align == 0 || (align & (align-1)) == 0,
        "align must 0 or a power of two" );

    if (align == 0)
    {
        return value;
    }
    else if ((value & (align-1)) == 0)
    {
        return value;
    }
    else
    {
        return (value+align) & ~(align-1);
    }
}
