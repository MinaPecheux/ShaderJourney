// [Shader Journey] My exploration of the world of shaders!
// (Implementing various VFX and rendering styles in Unity)
//
// Mina Pêcheux - Since September 2021
// ========================================================
// Episode 03: Basic Post Processing
// --------------------------------------------------------
// Shader n°3: "Night Vision"
//    A Post Processing shader that creates a night-vision
//    green-light effect. The grid effect is based on
//    texture sampling and the vignette uses a simple
//    radial signed-distance function.
//
//    The lens deformation effect is adapted from this
//    tutorial by Alan Zucconi
//    at: https://www.alanzucconi.com/2015/07/08/screen-shaders-and-postprocessing-effects-in-unity3d/

Shader "Custom/Episode 3/Night Vision"
{
    Properties
    {
        [NoScaleOffset] _MainTex ("Main Texture", 2D) = "black" {}
        [NoScaleOffset] _DisplacementTex ("Displacement Texture", 2D) = "black" {}
        _DeformationStrength ("Deformation Strength", Range(0, 1)) = 1.0

        // grid props
        [NoScaleOffset] _GridTex ("Grid Texture", 2D) = "black" {}
        _GridSubdivisions ("Grid Subdivisions", Float) = 10
        _GridOpacity ("Grid Opacity", Range(0, 1)) = 0.35
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
            //<SamplerName>_TexelSize is a float2 that says how much screen space a texel occupies.
            float2 _MainTex_TexelSize;

            sampler2D _DisplacementTex;
            float _DeformationStrength;

            sampler2D _GridTex;
            float _GridSubdivisions;
            float _GridOpacity;

            float4 frag(v2f_img i) : SV_Target
            {
                // lens deformation
                float2 n = tex2D( _DisplacementTex, i.uv );
                i.uv += -n * 0.05 * _DeformationStrength;
                i.uv = saturate( i.uv );

                // reproject UVs
                float2 adjustedUvs = UnityStereoTransformScreenSpaceTex( i.uv );

                // get initial render image as grayscale
                float4 renderTex = tex2D( _MainTex, adjustedUvs );
                float grayscale = ( renderTex.x + renderTex.y + renderTex.z ) / 3;

                // create grid
                float2 x = adjustedUvs * _GridSubdivisions;
                x.y -= frac( _Time.y * 0.5 );
                float grid = tex2D( _GridTex, x );

                // prepare dark vignette
                float vignette = 1 - length( adjustedUvs * 2 - 1 ) / 2;

                // apply varying green tint
                float tint = cos( _Time.y * 0.75 ) * 0.1;
                float3 col = float3( tint + 0.6, 1, tint + 0.6 );

                // compute final mask
                float mask = (grayscale + grid * _GridOpacity) * vignette * 2;

                return saturate( float4( 0.05 + col * mask, 1 ) );
            }
             
            ENDCG
 
        }  
    }
}
