#pragma once

// apple_blossom's wireframe cginc
// this is the meat of the shader

struct appdata
{
    float4 vertex : POSITION;
};

struct v2g
{
    float4 vertex : SV_POSITION;
};

struct g2f
{
    float4 vertex : SV_POSITION;
    float3 triangleValue : TEXCOORD1;
    float distance : TEXCOORD2;
};

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
    o.vertex = mul(unity_ObjectToWorld, v.vertex);

    return o;
}

[maxvertexcount(3)]
void geom(triangle v2g input[3], inout TriangleStream<g2f> triStream){
    g2f o;

    [unroll(3)]
    for(int i=0; i<3; i++){
        o.distance =  lerp(1, max(.1, distance(input[i].vertex.xyz, _WorldSpaceCameraPos.xyz)), _CutoffFalloff);
        o.vertex = mul(UNITY_MATRIX_VP, input[i].vertex);
        o.triangleValue = triangleValues[i];

        triStream.Append(o);
    }

    triStream.RestartStrip();
    
}

float4 frag (g2f i) : SV_Target
{
    float edgeDistance = _Thickness + (1 - min(min(i.triangleValue.x, i.triangleValue.y), i.triangleValue.z))/i.distance;
    float aaDis = smoothstep(1 - _CutoffSmoothing - fwidth(edgeDistance), 1, edgeDistance);

    //clip(aaDis);

#ifdef _BACKFACE
    float4 color = _BackfaceColor;
#else
    float4 color = _Color;
#endif

    color.a *= saturate(aaDis);


    return color;
}