Shader "Apple/SimpleWireframe"
{
    // apple_blossom's simple wireframes!~
    // instead of complicated math, i just assign each vertex of each triangle to one of three floats in a vector3
    // then, once that vector3 is interpolated, the maximum value is the distance to each edge. this works surprisingly
    // well to create wireframes.
    //
    // note: currently, the backface is rendered, and then the front face, to give darker wires on the back. this could
    // be accomplished with SV_FACING, but I wanted the transparency to blend well.

    Properties
    {
        [HDR] _Color("Wire Color", Color) = (.54,1,.85,1)
        [HDR] _BackfaceColor("Backface Wire Color", Color) = (.125,.25,.25,1)

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

        Pass
        {
            Cull Front
            CGPROGRAM
            #pragma vertex vert
            #pragma geometry geom
            #pragma fragment frag

            #define _BACKFACE

            #include "UnityCG.cginc"
            #include "wireframe.cginc"


            ENDCG
        }

        Pass
        {
            Cull Back
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
