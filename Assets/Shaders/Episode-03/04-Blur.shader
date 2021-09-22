// [Shader Journey] My exploration of the world of shaders!
// (Implementing various VFX and rendering styles in Unity)
//
// Mina Pêcheux - Since September 2021
// ========================================================
// Episode 03: Basic Post Processing
// --------------------------------------------------------
// Shader n°4: "Blur"
//    A Post Processing shader that applie box blur on the
//    image (+ some slight surexposition) to create a
//    "fuzzy" vision effect.
//
//    Adapted from this article by Santosh Nalla,
//    at: https://www.santoshnalla.com/post/post-processing-effect-blur-effect

Shader "Custom/Episode 3/Blur"
{
    Properties
    {
        [NoScaleOffset] _MainTex ("Render Image", 2D) = "black" {}
        _BlurStrength ("Blur Strength", Range(0, 1)) = 0.5
        _BlurAccuracy ("Blur Accuracy", Float) = 10
        _BlurSurexposition ("Blur Surexposition", Range(0, 1)) = 0
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float _BlurStrength;
            float _BlurAccuracy;
            float _BlurSurexposition;

            float4 frag (v2f_img i) : SV_Target
            {
                float4 col = 0;
                // sum the neighbour pixels
                // to get a box blur effect
                for (int x=0; x<_BlurAccuracy; x++)
                {
                    for (int y=0; y<_BlurAccuracy; y++)
                    {
                        float2 uv = i.uv + float2( x / ( _BlurAccuracy - 1 ) - 0.5, y / ( _BlurAccuracy - 1 ) - 0.5 ) * _BlurStrength;
                        col += tex2D( _MainTex, uv );
                    }
                }

                // get a surexposition coefficient
                float m = _BlurAccuracy * _BlurAccuracy * (1 - _BlurSurexposition);
                // use this coefficient to compute the average
				return col / m;
            }
            ENDCG
        }
    }
}
