Shader "Apple/ColorspaceDither"
{
    Properties
    {
        _Hues ("Hues", Integer) = 8
        _Saturations ("Saturation Levels", Integer) = 2
        _Values ("Value Levels", Integer) = 2

        [KeywordEnum(RGB, HSV, OKLAB)] _ColorSpace ("Color Space", Float) = 0
    }
    SubShader
    {
        Tags { "Queue" = "Overlay" }

        // No culling or depth
        Cull Off 
        ZWrite Off
        ZTest Always

        Offset -1,-1

        GrabPass { } 

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "colorspace.cginc"

            #pragma multi_compile _COLORSPACE_RGB _COLORSPACE_HSV _COLORSPACE_OKLAB

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 grabPos : TEXCOORD0;
                float4 screenPos : TEXCOORD1;
            };

            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.grabPos = ComputeGrabScreenPos(o.pos);
                o.screenPos = ComputeScreenPos(o.pos);
                return o;
            }

            sampler2D _GrabTexture;
            float _Hues, _Saturations, _Values;

            static const float DITHER_THRESHOLDS[16] =
            {
                1.0 / 17.0,  9.0 / 17.0,  3.0 / 17.0, 11.0 / 17.0,
                13.0 / 17.0,  5.0 / 17.0, 15.0 / 17.0,  7.0 / 17.0,
                4.0 / 17.0, 12.0 / 17.0,  2.0 / 17.0, 10.0 / 17.0,
                16.0 / 17.0,  8.0 / 17.0, 14.0 / 17.0,  6.0 / 17.0
            };

            float4 frag (v2f i) : SV_Target
            {
                static const float3 levels = float3(_Hues, _Saturations, _Values);
                static const float3 levels_reciprocal = 1. / levels;

                float4 grabColor = tex2Dproj(_GrabTexture, i.grabPos);

            #ifdef _COLORSPACE_HSV
                float3 hsvColor = RGBtoHSV(grabColor.rgb);
            #elif _COLORSPACE_LAB
                float3 hsvColor = linear_srgb_to_oklab(grabColor.rgb);
            #else
                float3 hsvColor = grabColor.rgb;
            #endif

                float3 hsvDiff = smoothstep(0, 1, frac(hsvColor * levels));

                //screenspace dither
                float2 screenPos = (i.screenPos.xy / i.screenPos.w) * (_ScreenParams.xy);
                uint index = (uint(screenPos.x) % 4) * 4 + uint(screenPos.y) % 4;
                float3 dither = step(DITHER_THRESHOLDS[index], hsvDiff);

                hsvColor = floor(hsvColor * levels + dither) * levels_reciprocal;

            #ifdef _COLORSPACE_HSV
                grabColor.rgb = HSVtoRGB(hsvColor.rgb);
            #elif _COLORSPACE_LAB
                grabColor.rgb = oklab_to_linear_srgb(hsvColor.rgb);
            #else
                grabColor.rgb = hsvColor.rgb;
            #endif

                return grabColor;
            }
            ENDCG
        }
    }
}
