// [Shader Journey] My exploration of the world of shaders!
// (Implementing various VFX and rendering styles in Unity)
//
// Mina Pêcheux - Since September 2021
// ========================================================
// Episode 02: Holograms
// --------------------------------------------------------
// Shader n°1: "Hologram Basic"
//    A basic hologram shader with a Fresnel effect and
//    transparency - using the additive blend mode to get
//    a nicer VFX.
//
//    The shader also has some vertex displacement to
//    periodically moving the hologram object up and down.

Shader "Custom/Episode 2/Hologram Basic"
{
    Properties
    {
        // base props
        _Color ("Color", Color) = (1, 1, 1, 1)
        // hovering props
        _HoveringAmplitude ("Hovering Amplitude", Range(0, 1)) = 0.3
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
            ZWrite Off
            Blend One One

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            float4 _Color;
            float _HoveringAmplitude;
            float _FresnelIntensity;
            float4 _FresnelColor;

            struct MeshData
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
            };

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                v.vertex.y += pow( _HoveringAmplitude, 2 ) * cos( _Time.y );
                o.vertex = UnityObjectToClipPos(v.vertex);
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

                float fresnelMask = 1 - dot( V, N );
                float3 fresnel = _FresnelColor * fresnelMask;

                return float4( _Color.xyz + fresnel * _FresnelIntensity, 1 );
            }
            ENDCG
        }
    }
}
