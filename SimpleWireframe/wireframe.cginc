#pragma once

// apple_blossom's wireframe cginc
// this is the meat of the shader

struct appdata
{
    float4 vertex : POSITION;
    float2 uv : TEXCOORD0;
};

struct v2g
{
    float4 vertex : SV_POSITION;
    float2 uv : TEXCOORD0;
};

struct g2f
{
    float4 vertex : SV_POSITION;
    float2 uv : TEXCOORD0;
    float3 triangleValue : TEXCOORD1;
    float distance : TEXCOORD2;
};

sampler2D _MainTex;
float4 _MainTex_ST;
float4 _Color, _BackfaceColor, _BackgroundColor;
float _Thickness, _CutoffFalloff, _CutoffSmoothing;
float _BackfaceBrightness;

//each vertex of the triangle will be assigned one of these three values.
static const float3 triangleValues[3] = {
    float3(1, 0, 0),
    float3(0, 1, 0),
    float3(0, 0, 1)
};


v2g vert (appdata v)
{
    v2g o;
    o.vertex = v.vertex;
    o.uv = v.uv;

    return o;
}

[maxvertexcount(3)]
void geom(triangle v2g input[3], inout TriangleStream<g2f> triStream){
    g2f o;

    [unroll(3)]
    for(int i=0; i<3; i++){
        o.vertex = UnityObjectToClipPos(input[i].vertex);
        o.uv = TRANSFORM_TEX(input[i].uv, _MainTex);
        o.triangleValue = triangleValues[i];
        o.distance =  lerp(1, max(.1, distance(mul(unity_ObjectToWorld, input[i].vertex), _WorldSpaceCameraPos)), _CutoffFalloff);

        triStream.Append(o);
    }

    triStream.RestartStrip();
    
}

float4 frag (g2f i) : SV_Target
{
    // after interpolation, (1 - [minimum triangle value]) will represent the distance to the nearest edge.
    float cutoff = (1 - _Thickness);
    
    float edgeDistance = (1 - min(min(i.triangleValue.x, i.triangleValue.y), i.triangleValue.z))/i.distance;
    float dDis = fwidth(edgeDistance);
    float aaDis = smoothstep(cutoff - _CutoffSmoothing - dDis, cutoff, edgeDistance);

    //clip(edgeDistance - (1 - _Thickness) + dDis);

    //the backface pass can be disabled in favor of just a single pass with no culling, using SV_FACING.
#ifdef _BACKFACE
    float4 color = _BackfaceColor;
#else
    float4 color = _Color;
#endif
    color.a *= saturate(aaDis);


    return color;
}