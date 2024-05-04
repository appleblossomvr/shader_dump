Shader "Apple/HolographicFXSurface"
{
    ///
    /// by apple_blossom, simple edit to the default surface shader
    ///


    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _Tex0 ("Texture", 2D) = "white" {}
        _Tex1 ("Texture", 2D) = "white" {}
        _BumpMap ("Bumpmap", 2D) = "bump" {}

        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows

        #pragma target 5.0

        sampler2D _Tex0;
        sampler2D _Tex1;
        sampler2D _BumpMap;

        struct Input
        {
            float2 uv_Tex0;
            float2 uv_Tex1;
            float2 uv_BumpMap;
            float3 viewDir;
        };

        half _Glossiness;
        half _Metallic;
        half4 _Color;

        UNITY_INSTANCING_BUFFER_START(Props)

        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            half4 c = tex2D (_Tex0, IN.uv_Tex0);
            half4 c1 = tex2D (_Tex1, IN.uv_Tex1);

            o.Normal = UnpackNormal (tex2D (_BumpMap, IN.uv_BumpMap));

            c = lerp(c, c1, saturate(IN.viewDir.x*.5+.5 + o.Normal.x)) * _Color;
            o.Albedo = c.rgb;
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
