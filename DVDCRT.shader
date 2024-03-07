Shader "Apple/DVDCRT"
{
    //
    // DVD-Logo Custom Render Texture shader by apple_blossom
    //
    // Make a Custom Render Texture, set it to update realtime, and add a material with this shader. 
    // Then use that texture wherever you'd like:)
    //

    Properties
    {
        [NoScaleOffset] _MainTex ("Texture", 2D) = "white" {}
        _MainTex_Scale ("Texture Scale", Vector) = (.5, .5, 0, 0) //x and y scale the logo, you'll likely want this to be equal and (0-1)
        _Speed ("Movement Pattern", Vector) = (2, 3, 1, 0) //x and y are movement patterns, z and w are movement offests. 
    }

    SubShader
    {
        Blend One Zero

        Pass
        {
            Name "DVDCRT"

            CGPROGRAM
            #include "UnityCustomRenderTexture.cginc"

            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment frag
            #pragma target 3.0

            uniform sampler2D _MainTex;
            uniform float4 _MainTex_ST;
            uniform float4 _MainTex_Scale;
            uniform float4 _Speed;

            float4 frag(v2f_customrendertexture IN) : SV_Target {
                float2 uv = IN.globalTexcoord.xy;
                
                //scale uv from (0-1) to (-1, 1)
                uv = uv * 2 - 1;

                //take in time, and modulo by the current "speed" values, using abs to make it ping-pong across each axis
                float2 time = abs(((_Time.y + _Speed.zw) % (_Speed.xy * 2)) - _Speed.xy) / _Speed.xy - .5;
                uv += time;
                uv /= _MainTex_Scale.xy;

                //scale uv back to (0-1)
                uv = uv * .5 + .5;
                
                //sample texture with modified UV
                float4 color = tex2D(_MainTex, uv);

                //remove color outside boundary, can also be done by different sampler settings but w/e
                color *= all(uv.xy > 0 && uv.xy < 1);

                return color;
            }
            ENDCG
        }
    }
}
