// [Shader Journey] My exploration of the world of shaders!
// (Implementing various VFX and rendering styles in Unity)
//
// Mina Pêcheux - Since September 2021
// ========================================================
// Episode 02: Holograms
// --------------------------------------------------------
// Shader n°2: "Hologram Wireframe"
//    A hologram shader showing a fake (texture-based)
//    wireframe, a Fresnel effect and transparency - using
//    the alpha blend mode and disabled culling to get a
//    "double-sided" shader.

Shader "Custom/Episode 2/Hologram Wireframe"
{
    Properties
    {
        // base props
        _Color ("Color", Color) = (1, 1, 1, 1)
        _FillOpacity ("Fill Opacity", Range(0, 1)) = 0.25
        // wireframe props
        _WireTex ("Wireframe Texture", 2D) = "black" {}
        _WireColor ("Wireframe Color", Color) = (1, 1, 1, 1)
        _WireOpacity ("Wireframe Opacity", Range(0, 1)) = 0.25
        // fresnel props
        _FresnelIntensity ("Fresnel Intensity", Range(0, 1)) = 0.5
        _FresnelColor ("Fresnel Color", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
        }

        Pass
        {
            //Cull Off
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            float4 _Color;
            float _FillOpacity;
            sampler2D _WireTex;
            float4 _WireTex_ST;
            float4 _WireColor;
            float _WireOpacity;
            float _FresnelIntensity;
            float4 _FresnelColor;

            struct MeshData
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
            };

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos( v.vertex );
                o.uv = TRANSFORM_TEX( v.uv, _WireTex );
                o.normal = v.normal;
                o.worldPos = mul( unity_ObjectToWorld, v.vertex );
                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                // get *world* normalized normal for fragment
                // (need world because we are applying rotations, so we want
                // it to be independent of the current state of the object)
                float3 N = normalize( mul(unity_ObjectToWorld, i.normal) );
                // get view vector (from camera)
                float3 V = normalize( _WorldSpaceCameraPos - i.worldPos );

                float fresnelMask = dot( V, N );
                float3 fresnel = _FresnelColor * fresnelMask;

                float wireMask = tex2Dlod( _WireTex, float4( i.uv, 5, 5 ) );

                return
                    float4( _Color.xyz, _FillOpacity ) +
                    float4( wireMask * _WireColor.xyz, wireMask * _WireOpacity ) +
                    float4( fresnel * _FresnelIntensity, fresnelMask * 0.5 );
            }
            ENDCG
        }
    }
}
