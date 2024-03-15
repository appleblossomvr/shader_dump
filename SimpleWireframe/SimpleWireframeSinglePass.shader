Shader "Apple/SimpleWireframeSinglePass"
{
    // apple_blossom's simple wireframes!~
    // instead of complicated math, i just assign each vertex of each triangle to one of three floats in a vector3
    // then, once that vector3 is interpolated, the maximum value is the distance to each edge. this works surprisingly
    // well to create wireframes.
    //
    // this version renders the front and back at the same time.
    

    Properties
    {
        [HDR] _Color("Wire Color", Color) = (.54,1,.85,1)

        _Thickness ("Thickness", Range(0, .05)) = 0
        _CutoffFalloff ("Thickness Falloff over Distance", Range(0.0, .25)) = 0.033
        _CutoffSmoothing ("Line Smoothness", Range(0.0, 0.5)) = 0.0025
        _BackfaceBrightness ("Backface Brightness", Range(0.0, 1.0)) = 0.15
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue" = "Transparent"}
        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off
        Cull Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma geometry geom
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "wireframe.cginc"

            ENDCG
        }
    }
}
