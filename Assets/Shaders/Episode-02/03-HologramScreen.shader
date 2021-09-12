// [Shader Journey] My exploration of the world of shaders!
// (Implementing various VFX and rendering styles in Unity)
//
// Mina Pêcheux - Since September 2021
// ========================================================
// Episode 02: Holograms
// --------------------------------------------------------
// Shader n°3: "Hologram Screen"
//    A hologram screen shader using signed distance funcs
//    (SDFs) to create rounded corners, a border and even
//    an inner lighting effect.
//
//    The shader also adds grid and animated band VFX to
//    make an old-TV screen effect (using basic masks).

Shader "Custom/Episode 2/Hologram Screen"
{
    Properties
    {
        // base props
        _Color ("Color", Color) = (1, 1, 1, 1)
        _MainTex ("Texture", 2D) = "gray" {}
        // border props
        _BorderColor ("Border Color", Color) = (1, 1, 1, 1)
        _CornerRadius ("Corner Radius", Range(0, 1)) = 0.5
        _BorderThickness ("Border Thickness", Range(0, 1)) = 0.1
        // grid props
        _GridThickness ("Grid Thickness", Range(0, 1)) = 0.2
        _GridSubdivisions ("Grid Subdivisions", Float) = 10
        // band props
        _BandWidth ("Band Width", Range(0, 0.5)) = 0.2
        _BandSpeed ("Band Speed", Float) = 0.2
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            //"Queue" = "Transparent"
        }

        Pass
        {
            //ZWrite Off
            //Blend One One

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            float4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _BorderColor;
            float _CornerRadius;
            float _BorderThickness;
            float _GridThickness;
            float _GridSubdivisions;
            float _BandWidth;
            float _BandSpeed;

            struct MeshData
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos( v.vertex );
                o.uv = TRANSFORM_TEX( v.uv, _MainTex );
                return o;
            }

            float RoundedRectangle( float2 uv, float2 pos, float2 size, float borderTickness ) {
                // (adapted from: https://stackoverflow.com/questions/43970170/bordered-rounded-rectangle-in-glsl)
                return length( max( abs( uv - pos ), size ) - size ) - ( 1 - borderTickness );
            }

            float4 frag (Interpolators i) : SV_Target
            {
                float texMask = tex2D( _MainTex, i.uv );

                // prepare grid
                float gridMask =
                    smoothstep( 1 - _GridThickness, 1, frac( i.uv.x * _GridSubdivisions - 1 - _GridThickness * 0.25 ) ) +
                    smoothstep( 1 - _GridThickness, 1, frac( i.uv.y * _GridSubdivisions - 1 - _GridThickness * 0.25 ) );
                float3 gridColor = saturate( _Color.xyz * 0.2 );

                // prepare band
                float bandMask = 1 - smoothstep( 0, _BandWidth, abs( i.uv.y - frac( _Time.y * _BandSpeed ) ) );
                float3 bandColor = saturate( _Color.xyz * 0.6 );

                // get a rounded border mask
                float s = (1 - _CornerRadius) / 2;
                float2 size = float2( s, s );
                float thickness = pow( _BorderThickness, 0.25 );
                float borderSdf = RoundedRectangle( i.uv, float2( 0.5, 0.5 ), size, thickness );
                // (step it with antialiasing)
                float pd = fwidth(borderSdf);
                float borderMask = saturate( borderSdf / pd );

                float inScreenMask = 1 - borderMask;

                float innerLight = RoundedRectangle( i.uv, float2( 0.5, 0.5 ), size - thickness / 8, thickness ) * inScreenMask;

                return
                    float4( _Color.xyz * texMask * inScreenMask, 1 ) +
                    float4( _BorderColor.xyz * borderMask, 1 ) +
                    float4( bandColor * bandMask * inScreenMask, 1 ) +
                    float4( gridColor * gridMask * inScreenMask, 1 ) +
                    saturate( innerLight * _Color * 2 );
            }
            ENDCG
        }
    }
}
