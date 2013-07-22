interface VSOutput
{                                                                                    
    vec2 TexCoord;                                                                 
    vec3 Normal;                                                                   
    vec3 WorldPos;                                                                 
    vec4 LightSpacePos;
};

struct VSOutput1
{                                                                                    
    vec2 TexCoord;                                                                 
    vec3 Normal;                                                                   
    vec3 WorldPos;
	vec4 LightSpacePos;
};

uniform mat4 gWVP;                                                  
uniform mat4 gLightWVP;
uniform mat4 gWorld;                                                
                                                                                    
shader VSmain(in vec3 Position, in vec2 TexCoord, in vec3 Normal, out VSOutput VSout)
{                                                                                   
    gl_Position      = gWVP * vec4(Position, 1.0);                                        
    VSout.TexCoord      = TexCoord;                                                         
    VSout.Normal        = (gWorld * vec4(Normal, 0.0)).xyz;                                  
    VSout.WorldPos      = (gWorld * vec4(Position, 1.0)).xyz;                                
	VSout.LightSpacePos = gLightWVP * vec4(Position, 1.0);
}
                                                                                 
const int MAX_POINT_LIGHTS = 2;                                                     
const int MAX_SPOT_LIGHTS = 2;                                                      
                                                                                                                                                                      
                                                                                   
struct BaseLight                                                                    
{                                                                                   
    vec3 Color;                                                                     
    float AmbientIntensity;                                                         
    float DiffuseIntensity;                                                         
};                                                                                  
                                                                                    
struct DirectionalLight                                                             
{                                                                                   
    BaseLight Base;                                                          
    vec3 Direction;                                                                 
};                                                                                  
                                                                                    
struct Attenuation                                                                  
{                                                                                   
    float Constant;                                                                 
    float Linear;                                                                   
    float Exp;                                                                      
};                                                                                  
                                                                                    
struct PointLight                                                                           
{                                                                                           
    BaseLight Base;                                                                  
    vec3 Position;                                                                          
    Attenuation Atten;                                                                      
};                                                                                          
                                                                                            
struct SpotLight                                                                            
{                                                                                           
    PointLight Base;                                                                 
    vec3 Direction;                                                                         
    float Cutoff;                                                                           
};                                                                                          
                                                                                            
uniform int gNumPointLights;                                                                
uniform int gNumSpotLights;                                                                 
uniform DirectionalLight gDirectionalLight;                                                 
uniform PointLight gPointLights[MAX_POINT_LIGHTS];                                          
uniform SpotLight gSpotLights[MAX_SPOT_LIGHTS];                                             
uniform sampler2D gColorMap;                                                                
uniform sampler2D gShadowMap;
uniform vec3 gEyeWorldPos;
uniform float gMatSpecularIntensity;
uniform float gSpecularPower;
uniform vec2 gMapSize;

#define EPSILON 0.001

float CalcShadowFactor(vec4 LightSpacePos)
{
    vec3 ProjCoords = LightSpacePos.xyz / LightSpacePos.w;
    vec2 UVCoords;
    UVCoords.x = 0.5 * ProjCoords.x + 0.5;
    UVCoords.y = 0.5 * ProjCoords.y + 0.5;
    float z = 0.5 * ProjCoords.z + 0.5;
  
    float xOffset = 1.0/gMapSize.x;
    float yOffset = 1.0/gMapSize.y;

    vec2 Offsets = vec2(-xOffset, 0);        
    float Depth = texture(gShadowMap, UVCoords/* + Offsets*/).x;   
    float r0 = (Depth >= z + EPSILON) ? 1.0 : 0.0;

    Offsets = vec2(+xOffset, 0);        
    Depth = texture(gShadowMap, UVCoords/* + Offsets*/).x;   
    float r1 = (Depth >= z + EPSILON) ? 1.0 : 0.0;

    vec2 TexelCoords = vec2(UVCoords * gMapSize);
    TexelCoords = fract(TexelCoords);

    float l0 = mix(r0, r1, TexelCoords.x);

    float LightFactor = l0;

    return LightFactor;

#if 0
    vec2 Offsets = vec2(0,0);        
    //vec2 Offsets = vec2(-xOffset, -yOffset);        
    float Depth = texture(gShadowMap, UVCoords + Offsets).x;   
    float r0 = (Depth >= z + EPSILON) ? 1.0 : 0.0;

    Offsets = vec2(xOffset, 0);        
    //Offsets = vec2(+xOffset, -yOffset);        
    Depth = texture(gShadowMap, UVCoords + Offsets).x;   
    float r1 = (Depth >= z + EPSILON) ? 1.0 : 0.0;

    Offsets = vec2(0, yOffset);        
    //Offsets = vec2(-xOffset, +yOffset);        
    Depth = texture(gShadowMap, UVCoords + Offsets).x;   
    float r2 = (Depth >= z + EPSILON) ? 1.0 : 0.0;

    Offsets = vec2(+xOffset, +yOffset);        
    Depth = texture(gShadowMap, UVCoords + Offsets).x;   
    float r3 = (Depth >= z + EPSILON) ? 1.0 : 0.0;

    //vec2 TexelCoords(UVCoords.x * gMapSize.x, 
      //               UVCoords.y * gMapSize.y);

    TexelCoords = fract(TexelCoords);

    float l0 = mix(r0, r1, TexelCoords.x);
    float l1 = mix(r2, r3, TexelCoords.x);

    float l2 = mix(l0, l1, TexelCoords.y);

    float LightFactor = 0.5 + l2 * 0.5;

    return LightFactor;
#endif
}

vec4 CalcLightInternal(BaseLight Light, vec3 LightDirection, VSOutput1 In, float ShadowFactor)           
{                                                                                           
    vec4 AmbientColor = vec4(Light.Color, 1.0f) * Light.AmbientIntensity;                   
    float DiffuseFactor = dot(In.Normal, -LightDirection);                                     
                                                                                            
    vec4 DiffuseColor  = vec4(0, 0, 0, 0);                                                  
    vec4 SpecularColor = vec4(0, 0, 0, 0);                                                  
                                                                                            
    if (DiffuseFactor > 0) {                                                                
        DiffuseColor = vec4(Light.Color, 1.0f) * Light.DiffuseIntensity * DiffuseFactor;    
                                                                                            
        vec3 VertexToEye = normalize(gEyeWorldPos - In.WorldPos);                             
        vec3 LightReflect = normalize(reflect(LightDirection, In.Normal));                     
        float SpecularFactor = dot(VertexToEye, LightReflect);                              
        SpecularFactor = pow(SpecularFactor, gSpecularPower);                               
        if (SpecularFactor > 0) {                                                           
            SpecularColor = vec4(Light.Color, 1.0f) *                                       
                            gMatSpecularIntensity * SpecularFactor;                         
        }                                                                                   
    }                                                                                       
                                                                                            
    return (AmbientColor + ShadowFactor * (DiffuseColor + SpecularColor));                                   
}                                                                                           
                                                                                            
vec4 CalcDirectionalLight(VSOutput1 In)                                                      
{                                                                                           
    return CalcLightInternal(gDirectionalLight.Base, gDirectionalLight.Direction, In, 1.0);
}                                                                                           
                                                                                            
vec4 CalcPointLight(PointLight l, VSOutput1 In)                       
{                                                                                           
    vec3 LightDirection = In.WorldPos - l.Position;                                           
    float Distance = length(LightDirection);                                                
    LightDirection = normalize(LightDirection);                    
    float ShadowFactor = CalcShadowFactor(In.LightSpacePos);
                                                                                            
    vec4 Color = CalcLightInternal(l.Base, LightDirection, In, ShadowFactor);
    float Attenuation =  l.Atten.Constant +                                                 
                         l.Atten.Linear * Distance +                                        
                         l.Atten.Exp * Distance * Distance;                                 
                                                                                            
    return Color / Attenuation;                                                             
}                                                                                           
                                                                                            
vec4 CalcSpotLight(SpotLight l, VSOutput1 In)
{                                                                                           
    vec3 LightToPixel = normalize(In.WorldPos - l.Base.Position);                             
    float SpotFactor = dot(LightToPixel, l.Direction);                                      
                                                                                            
    if (SpotFactor > l.Cutoff) {                                                            
        vec4 Color = CalcPointLight(l.Base, In);                                        
        return Color * (1.0 - (1.0 - SpotFactor) * 1.0/(1.0 - l.Cutoff));                   
    }                                                                                       
    else {                                                                                  
        return vec4(0,0,0,0);                                                               
    }                                                                                       
}                                                                                           
                                                                                            
shader FSmain(in VSOutput FSin, out vec4 FragColor)
{                                    
    VSOutput1 In;
    In.TexCoord      = FSin.TexCoord;
    In.Normal        = normalize(FSin.Normal);
    In.WorldPos      = FSin.WorldPos;                                                                 
    In.LightSpacePos = FSin.LightSpacePos;
  
    vec4 TotalLight = CalcDirectionalLight(In);                                         
                                                                                            
    for (int i = 0 ; i < gNumPointLights ; i++) {                                           
        TotalLight += CalcPointLight(gPointLights[i], In);                              
    }                                                                                       
                                                                                            
    for (int i = 0 ; i < gNumSpotLights ; i++) {                                            
        TotalLight += CalcSpotLight(gSpotLights[i], In);                                
    }                                                                                       
                                                                                            
    FragColor = texture(gColorMap, In.TexCoord.xy) * TotalLight;     
}

program ShadowsPCF
{
    vs(330)=VSmain();
    fs(330)=FSmain();
};