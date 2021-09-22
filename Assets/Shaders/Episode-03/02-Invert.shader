// [Shader Journey] My exploration of the world of shaders!
// (Implementing various VFX and rendering styles in Unity)
//
// Mina Pêcheux - Since September 2021
// ========================================================
// Episode 03: Basic Post Processing
// --------------------------------------------------------
// Shader n°2: "Invert"
//    A basic Post Processing shader that inverts the
//    colors of the render image.

Shader "Custom/Episode 3/Invert"
{
    Properties
    {
        [NoScaleOffset] _MainTex ("Render Image", 2D) = "black" {}
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

            float4 frag (v2f_img i) : SV_Target
            {
                float4 col = tex2D( _MainTex, i.uv );
				return 1 - col;
            }
            ENDCG
        }
    }
}
