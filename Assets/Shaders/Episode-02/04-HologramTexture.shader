// [Shader Journey] My exploration of the world of shaders!
// (Implementing various VFX and rendering styles in Unity)
//
// Mina Pêcheux - Since September 2021
// ========================================================
// Episode 02: Holograms
// --------------------------------------------------------
// Shader n°4: "Hologram Texture"
//    A simple hologram shader that uses a 2D texture as a
//    a mask and shows it as a one-color additive-blended
//    (and double-sided) object.

Shader "Custom/Episode 2/Hologram Texture"
{
    Properties
    {
        // base props
        _Color ("Color", Color) = (1, 1, 1, 1)
        _MainTex ("Texture", 2D) = "white" {}
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
            Cull Off
            ZWrite Off
            Blend One One

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            float4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;

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

            float4 frag (Interpolators i) : SV_Target
            {
                float texMask = tex2D( _MainTex, i.uv );
                return float4( _Color.xyz * texMask, 1 );
            }
            ENDCG
        }
    }
}
